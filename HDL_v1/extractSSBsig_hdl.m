% This function extracts the SSB signal from the received
% signal in a sample-by-sample streaming manner.
%--------------------------------------------------------------------------
% Author: Jie Lei
% Date: 05/22/2025
% Revision: 0.1
%--------------------------------------------------------------------------
function [ssbSig_re_out, ssbSig_im_out, validOut, ssbNumOut, ssbNumsValidOut] = extractSSBsig_hdl(rxSig_re_in, rxSig_im_in, peakValid, peakLoc, validIn)
% Stream-based fixed-point implementation for SSB extraction
% 
% Inputs:
%   rxSig_re_in: Real part of the received signal sample
%   rxSig_im_in: Imaginary part of the received signal sample
%   peakValid: Validity flag for peakLoc
%   peakLoc: Location of detected peak in the signal
%   validIn: Validity flag for input signal
%
% Outputs:
%   ssbSig_re_out: Real part of the SSB signal sample
%   ssbSig_im_out: Imaginary part of the SSB signal sample
%   validOut: Validity flag for output
%   ssbNumOut: Number of SSB signals extracted
%--------------------------------------------------------------------------

% Define constants directly (not as persistent)
NFFT = uint16(256);  % FFT size

CP_LEN = uint16(18); % Cyclic prefix length
SYMBOL_LEN = uint16(NFFT + CP_LEN); % OFDM symbol length
NUM_SYMBOLS = uint16(4); % Number of OFDM symbols in SSB
SSB_LENGTH = uint16(NUM_SYMBOLS * SYMBOL_LEN); % Total SSB length

% Define buffer size as power of 2 (greater than SSB length)
BUFFER_BIT = uint16(9);  % 2^9 = 512 > SSB_LENGTH (1096)
BUFFER_SIZE = uint16(2^BUFFER_BIT);
BUFFER_MASK = uint16(BUFFER_SIZE - 1);

% Define event FIFO size
EVENT_FIFO_BIT = uint16(1);  % 2^1 = 2
EVENT_FIFO_SIZE = uint16(2^EVENT_FIFO_BIT);
EVENT_FIFO_MASK = uint16(EVENT_FIFO_SIZE - 1);

% Define states for FSM
IDLE = uint8(0);
CHECK_EVENT = uint8(1);
WAITING_FOR_DATA = uint8(2);
PROCESSING_DATA = uint8(3);

% Fixed-point type definitions for signal data only
rxSigType = numerictype(true, 16, 15);
ssbSigType = numerictype(true, 16, 15);

% Counters and indices as native uint16
persistent state;
if isempty(state)
    state = IDLE;
end
persistent sampleCounter;
if isempty(sampleCounter)
    sampleCounter = uint16(0);
end
persistent bufferWritePtr;
if isempty(bufferWritePtr)
    bufferWritePtr = uint16(1);
end
persistent bufferReadPtr;
if isempty(bufferReadPtr)
    bufferReadPtr = uint16(1);
end
persistent eventFifoWritePtr;
if isempty(eventFifoWritePtr)
    eventFifoWritePtr = uint16(1);
end
persistent eventFifoReadPtr;
if isempty(eventFifoReadPtr)
    eventFifoReadPtr = uint16(1);
end
persistent eventFifoCount;
if isempty(eventFifoCount)
    eventFifoCount = uint16(0);
end
persistent oldSampleBase;
if isempty(oldSampleBase)
    oldSampleBase = uint16(0);
end
persistent processCounter;
if isempty(processCounter)
    processCounter = uint16(0);
end
persistent ssbCount;
if isempty(ssbCount)
    ssbCount = uint16(0);
end
persistent currentOutputSample;
if isempty(currentOutputSample)
    currentOutputSample = uint16(0);
end

% Initialize buffers
persistent rxBuffer_re rxBuffer_im eventFifo;
if isempty(rxBuffer_re)
    % Preallocate fixed-size buffers
    rxBuffer_re = fi(zeros(BUFFER_SIZE,1), rxSigType);
    rxBuffer_im = fi(zeros(BUFFER_SIZE,1), rxSigType);
    eventFifo = zeros(EVENT_FIFO_SIZE,1,'uint16');
end

% Initialize outputs
ssbSig_re_out = fi(0, ssbSigType);
ssbSig_im_out = fi(0, ssbSigType);
validOut = false;
ssbNumOut = uint16(0);
ssbNumsValidOut = false;

% Step 1: Handle input data - store in circular buffer if valid
if validIn
    % Store sample in buffer
    rxBuffer_re(bufferWritePtr) = fi(rxSig_re_in, rxSigType);
    rxBuffer_im(bufferWritePtr) = fi(rxSig_im_in, rxSigType);
    
    % Increment sample counter
    % Check if we've wrapped around the buffer
    if bufferWritePtr >= BUFFER_SIZE
        % Buffer is full, wrap around
        bufferWritePtr = uint16(1);
    else
        % Buffer is not full, just increment
        bufferWritePtr = bufferWritePtr + uint16(1);
    end
    
    % Increment global sample counter
    sampleCounter = sampleCounter + uint16(1);
end

% Step 2: Handle peak event - store in event FIFO if valid
if peakValid
    % Check if FIFO has space
    if eventFifoCount < EVENT_FIFO_SIZE
        % Store peak location in FIFO
        eventFifo(eventFifoWritePtr) = peakLoc;
        
        % Check if we've wrapped around the FIFO
        if eventFifoWritePtr >= EVENT_FIFO_SIZE
            % FIFO is full, wrap around
            eventFifoWritePtr = uint16(1);
        else
            % FIFO is not full, just increment
            eventFifoWritePtr = eventFifoWritePtr + uint16(1);
        end
        
        % Increment count
        eventFifoCount = eventFifoCount + uint16(1);
    end
end

% Step 3: Process state machine
switch state
    case IDLE
        % Reset outputs
        ssbSig_re_out = fi(0, ssbSigType);
        ssbSig_im_out = fi(0, ssbSigType);
        validOut = false;
        ssbNumsValidOut = false;
        
        % Check if there's an event to process
        if eventFifoCount > 0
            % Transition to CHECK_EVENT
            state = CHECK_EVENT;
        end
        
    case CHECK_EVENT
        % Read peak location from FIFO
        peakLoc = eventFifo(eventFifoReadPtr);
        
        % Check if we've wrapped around the FIFO
        if eventFifoReadPtr >= EVENT_FIFO_SIZE
            eventFifoReadPtr = uint16(1);
        else
            eventFifoReadPtr = eventFifoReadPtr + uint16(1);
        end
        
        % Decrement count
        eventFifoCount = eventFifoCount - uint16(1);
        
        % Calculate oldest sample needed directly
        oldSampleBase = peakLoc - uint16(NFFT + CP_LEN - 1);
        
        % Check if data is stale (already overwritten in buffer)
        if sampleCounter >= BUFFER_SIZE + oldSampleBase
            % Data is stale, discard event and continue checking
            state = IDLE;
        else
            state = WAITING_FOR_DATA;
        end
        
    case WAITING_FOR_DATA
        if sampleCounter >= oldSampleBase
            state = PROCESSING_DATA;
            processCounter = uint16(0);
            currentOutputSample = oldSampleBase;
            bufferStartIdx = bitand(oldSampleBase, BUFFER_MASK);
            % Update buffer read pointer
            bufferReadPtr = bufferStartIdx + uint16(1);
        end
        
    case PROCESSING_DATA
        % We're processing data - output one sample per function call
        % Check if we've processed all samples for this SSB
        if processCounter < SSB_LENGTH
            % We still have samples to process
            % Check if this sample is valid
            if (currentOutputSample <= sampleCounter)
                % Read sample from buffer
                ssbSig_re_out = rxBuffer_re(bufferReadPtr);
                ssbSig_im_out = rxBuffer_im(bufferReadPtr);
                validOut = true;
                processCounter = processCounter + uint16(1);
                currentOutputSample = currentOutputSample + uint16(1);
                % Update buffer read pointer
                if bufferReadPtr >= BUFFER_SIZE
                    % Buffer is full, wrap around
                    bufferReadPtr = uint16(1);
                else
                    % Buffer is not full, just increment
                    bufferReadPtr = bufferReadPtr + uint16(1);
                end
            else
                validOut = false;
            end
        else
            % We've processed all samples for this SSB
            % Increment SSB count
            ssbCount = ssbCount + uint16(1);
            % Output SSB count
            ssbNumOut = ssbCount;
            ssbNumsValidOut = true;
            % Reset outputs
            ssbSig_re_out = fi(0, ssbSigType);
            ssbSig_im_out = fi(0, ssbSigType);
            validOut = false;
            % Go back to IDLE
            state = IDLE;
        end
end
end
