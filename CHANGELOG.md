# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-01

### Added
- Initial comprehensive analysis of MATLAB HDL Coder BRAM mapping
- Four complete HDL implementations (HDL_v1 through HDL_v4)
- Systematic resource utilization comparison
- Post-synthesis validation using Xilinx Vivado 2023.2
- Interactive Mermaid diagrams for visualization
- Complete documentation with best practices
- Reproducible methodology with validation steps
- Evidence of 72× resource improvement through FIFO optimization

### Key Findings
- **Root Cause Identification**: FIFO size ≥16 entries prevents BRAM mapping system-wide
- **Resource Impact**: Large FIFOs cause 66,302+ flip-flop usage vs 914 with small FIFOs
- **Buffer Size Independence**: 512, 2048, and 4096 sample buffers all work with proper FIFO sizing
- **Timing Consistency**: All optimized versions achieve ~186 MHz performance

### Documentation
- Comprehensive README.md with step-by-step analysis
- Contributing guidelines for community involvement
- MIT license for open source usage
- GitHub issue and PR templates
- Detailed directory structure explanation

### Validation
- HDL Coder resource reports for all implementations
- Vivado post-synthesis confirmation
- Generated BRAM files as proof of successful inference
- Clock frequency analysis showing consistent performance

### Research Impact
- Systematic methodology for MATLAB HDL Coder memory optimization
- Evidence-based design guidelines for FPGA implementations
- Cross-tool validation (HDL Coder + Vivado)
- Reproducible results across multiple design configurations

## [Unreleased]

### Planned
- Additional FIFO size threshold testing (8, 32, 64 entries)
- Cross-platform validation (Altera, Lattice, Microsemi)
- HDL Coder version comparison study
- Automated testing framework
- Interactive web-based result explorer

---

## Legend

- **Added**: New features
- **Changed**: Changes in existing functionality  
- **Deprecated**: Soon-to-be removed features
- **Removed**: Now removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes
