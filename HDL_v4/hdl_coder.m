% Add script directory to MATLAB path
scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);

% Set up HDL Simulator and Synthesis Tool Path
hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
    'ToolPath', '/opt/Xilinx/Vivado/2023.2/bin/vivado');

% Create configuration for HDL code generation
hdlcfg = coder.config('hdl');
hdlcfg.TestBenchName = 'extractSSBsig_hdl_tb';
hdlcfg.TargetLanguage = 'Verilog';
hdlcfg.GenerateHDLTestBench = true;
hdlcfg.SimulateGeneratedCode = true;
hdlcfg.SimulationTool = 'Xilinx Vivado Simulator';
hdlcfg.SynthesizeGeneratedCode = true;
hdlcfg.SynthesisTool = 'Xilinx Vivado';
hdlcfg.SynthesisToolChipFamily = 'Kintex7';
hdlcfg.SynthesisToolDeviceName = 'xc7k410t';
hdlcfg.SynthesisToolPackageName = 'ffg900';
hdlcfg.SynthesisToolSpeedValue = '-2'; % Updated speed value
hdlcfg.TargetFrequency = 250; % Target frequency for synthesis

hdlcfg.ResourceSharing = true; % Enable resource sharing
hdlcfg.ConstantMultiplierOptimization = 'auto'; % Optimize out any multipliers from interpolation
hdlcfg.AdaptivePipelining = true; % Enable adaptive pipelining
hdlcfg.DistributedPipelining = true; % Enable distributed pipelining
hdlcfg.AllowDelayDistribution = true; % Allow delay distribution
hdlcfg.InputPipeline = 2; % Number of input pipeline registers
hdlcfg.OutputPipeline = 2; % Number of output pipeline registers
hdlcfg.RegisterInputs = true; % Register inputs
hdlcfg.RegisterOutputs = true; % Register outputs

% BRAM Mapping Configuration (Enhanced)
hdlcfg.MapPersistentVarsToRAM = true; % Enable RAM mapping for persistent vars
% hdlcfg.RAMVariableNames = "rxBuffer_re,rxBuffer_im,eventFifo"; % Specify variables as string scalar
% hdlcfg.RAMThreshold = 32; % Threshold for RAM mapping (min array size)

% Entry-point function
entryPointFunction = 'extractSSBsig_hdl';

% Define I/O data types
inRealType    = coder.typeof(fi(0,1,16,15), [1 1]); % Real part Q1.15
inImagType    = coder.typeof(fi(0,1,16,15), [1 1]); % Imag part Q1.15
peakValidType = coder.typeof(false,    [1 1]); % Peak valid flag
peakIdxType   = coder.typeof(uint16(0),[1 1]); % Peak location timestamp
validInType   = coder.typeof(false,    [1 1]); % Input valid flag
args = {inRealType, inImagType, peakValidType, peakIdxType, validInType};

% Generate HDL code
fprintf('Generating HDL Code for %s...\n', entryPointFunction);
if ~exist([entryPointFunction, '.m'], 'file')
    error('Entry-point function file %s.m not found', entryPointFunction);
end

try
    codegen('-config', hdlcfg, entryPointFunction, '-args', args, '-report');
    fprintf('HDL Code Generation Completed Successfully!\n');
catch ex
    fprintf('HDL Code Generation Failed: %s\n', ex.message);
    for k = 1:length(ex.stack)
        s = ex.stack(k);
        fprintf('  File: %s, Line: %d, Function: %s\n', s.file, s.line, s.name);
    end
    error('Code generation aborted');
end

% Display generated files location
if exist('codegen/hdl_prj', 'dir')
    fprintf('Generated HDL files are in: %s\n', fullfile(pwd, 'codegen/hdl_prj'));
else
    fprintf('Check the codegen directory for generated HDL files.\n');
end
