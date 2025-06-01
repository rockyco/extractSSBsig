# Makefile for extractSSBsig HDL implementation
# Author: Jie Lei
# Date: 03/28/2025

# MATLAB command configuration
MATLAB = matlab
MATLAB_FLAGS = -nodisplay -nosplash -nodesktop -batch

# Project directories
PROJECT_DIR = $(CURDIR)
HDL_OUTPUT_DIR = $(PROJECT_DIR)/codegen/extractSSBsig_hdl/hdlsrc
RESULTS_DIR = $(PROJECT_DIR)/results

# Target files
HDL_MAIN = extractSSBsig_hdl.m
HDL_TB = extractSSBsig_hdl_tb.m
HDL_CODER = hdl_coder.m

# Generated files
HDL_VERILOG = $(HDL_OUTPUT_DIR)/extractSSBsig_hdl.v
HDL_TB_VERILOG = $(HDL_OUTPUT_DIR)/extractSSBsig_hdl_tb.v
RESOURCE_REPORT = $(HDL_OUTPUT_DIR)/extractSSBsig_hdl_resource.html

# Default target
.PHONY: all
all: test-hdl hdl-workflow

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              - Run complete workflow (original test + HDL test + HDL generation)"
	@echo "  test-hdl         - Run HDL-compatible testbench"
	@echo "  hdl-workflow     - Run complete HDL Coder workflow"
	@echo "  clean            - Clean generated files"
	@echo "  clean-all        - Clean all generated files including HDL output"
	@echo "  check-deps       - Check if required input files exist"
	@echo "  results          - Create results directory and copy outputs"
	@echo "  help             - Show this help message"

# Check dependencies
.PHONY: check-deps
check-deps:
	@echo "Checking required input files..."
	@test -f correlatorIn.mat || (echo "ERROR: correlatorIn.mat not found" && exit 1)
	@test -f selectedPeak.mat || (echo "ERROR: selectedPeak.mat not found" && exit 1)
	@test -f ssbSig.mat || (echo "ERROR: ssbSig.mat not found" && exit 1)
	@test -f ssbNums.mat || (echo "ERROR: ssbNums.mat not found" && exit 1)
	@test -f $(HDL_MAIN) || (echo "ERROR: $(HDL_MAIN) not found" && exit 1)
	@test -f $(HDL_TB) || (echo "ERROR: $(HDL_TB) not found" && exit 1)
	@test -f $(HDL_CODER) || (echo "ERROR: $(HDL_CODER) not found" && exit 1)
	@echo "✓ All required files found"

# Run HDL-compatible testbench
.PHONY: test-hdl
test-hdl: check-deps $(HDL_MAIN) $(HDL_TB)
	@echo "Running HDL-compatible testbench..."
	$(MATLAB) $(MATLAB_FLAGS) "cd('$(PROJECT_DIR)'); extractSSBsig_hdl_tb; exit"
	@echo "✓ HDL testbench completed"

# Run complete HDL Coder workflow
.PHONY: hdl-workflow
hdl-workflow: check-deps $(HDL_CODER)
	@echo "Running complete HDL Coder workflow..."
	$(MATLAB) $(MATLAB_FLAGS) "cd('$(PROJECT_DIR)'); hdl_coder; exit"
	@echo "✓ HDL Coder workflow completed"

# Create results directory and copy outputs
.PHONY: results
results:
	@echo "Creating results directory..."
	@mkdir -p $(RESULTS_DIR)
	@if [ -f rxSig_in.txt ]; then cp rxSig_in.txt $(RESULTS_DIR)/; fi
	@if [ -f selectedPeak_in.txt ]; then cp selectedPeak_in.txt $(RESULTS_DIR)/; fi
	@if [ -f ssbSig_ref.txt ]; then cp ssbSig_ref.txt $(RESULTS_DIR)/; fi
	@if [ -f ssbNums_ref.txt ]; then cp ssbNums_ref.txt $(RESULTS_DIR)/; fi
	@if [ -f ssbSig_hdl_out.txt ]; then cp ssbSig_hdl_out.txt $(RESULTS_DIR)/; fi
	@if [ -f ssbNums_hdl_out.txt ]; then cp ssbNums_hdl_out.txt $(RESULTS_DIR)/; fi
	@if [ -d $(HDL_OUTPUT_DIR) ]; then cp -r $(HDL_OUTPUT_DIR) $(RESULTS_DIR)/hdl_output/; fi
	@echo "✓ Results copied to $(RESULTS_DIR)"

# Clean intermediate files
.PHONY: clean
clean:
	@echo "Cleaning intermediate files..."
	@rm -f *.txt
	@rm -f *.mat~
	@rm -f *_ref.mat
	@rm -f slprj/ -rf
	@echo "✓ Intermediate files cleaned"

# Clean all generated files including HDL output
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning all generated files..."
	@rm -rf codegen/
	@rm -rf $(RESULTS_DIR)
	@echo "✓ All generated files cleaned"

# Individual file targets for dependency tracking
$(HDL_VERILOG): $(HDL_MAIN) hdl-generate

$(HDL_TB_VERILOG): $(HDL_TB) hdl-workflow

$(RESOURCE_REPORT): hdl-workflow

# Verification targets
.PHONY: verify-hdl
verify-hdl: $(HDL_VERILOG)
	@echo "Verifying HDL generation..."
	@test -f $(HDL_VERILOG) || (echo "ERROR: HDL Verilog file not generated" && exit 1)
	@echo "✓ HDL Verilog file exists: $(HDL_VERILOG)"
	@if [ -f $(HDL_TB_VERILOG) ]; then echo "✓ HDL testbench exists: $(HDL_TB_VERILOG)"; fi
	@if [ -f $(RESOURCE_REPORT) ]; then echo "✓ Resource report exists: $(RESOURCE_REPORT)"; fi

# Performance target - run with timing
.PHONY: perf
perf: check-deps
	@echo "Running performance analysis..."
	@echo "Starting at: $$(date)"
	@time $(MAKE) test-original
	@time $(MAKE) test-hdl
	@time $(MAKE) hdl-generate
	@echo "Completed at: $$(date)"

# Development targets
.PHONY: dev-test
dev-test: test-hdl

.PHONY: dev-clean
dev-clean:
	@rm -f *_hdl_out.txt
	@rm -rf codegen/

# Quick test without dependencies check (for development)
.PHONY: quick-test
quick-test:
	@echo "Running quick HDL test (no dependency check)..."
	$(MATLAB) $(MATLAB_FLAGS) "cd('$(PROJECT_DIR)'); extractSSBsig_hdl_tb; exit"

# Show file status
.PHONY: status
status:
	@echo "Project Status:"
	@echo "==============="
	@echo "Project directory: $(PROJECT_DIR)"
	@echo ""
	@echo "Source files:"
	@ls -la *.m 2>/dev/null || echo "  No MATLAB files found"
	@echo ""
	@echo "Input data files:"
	@ls -la *.mat 2>/dev/null || echo "  No MAT files found"
	@echo ""
	@echo "Output files:"
	@ls -la *.txt 2>/dev/null || echo "  No output text files found"
	@echo ""
	@echo "HDL output:"
	@if [ -d $(HDL_OUTPUT_DIR) ]; then ls -la $(HDL_OUTPUT_DIR)/; else echo "  No HDL output directory"; fi
