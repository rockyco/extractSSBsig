# Contributing to MATLAB HDL Coder BRAM Analysis

Thank you for your interest in contributing to this project! This document provides guidelines for contributing to the MATLAB HDL Coder BRAM mapping analysis repository.

## 🚀 How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **🔬 Additional Analysis**
   - Testing different FIFO sizes (8, 32, 64 entries)
   - Alternative FPGA targets (Altera, Lattice, Microsemi)
   - Different HDL Coder versions
   - Memory pattern variations

2. **📖 Documentation Improvements**
   - Enhanced explanations
   - Additional diagrams
   - Better examples
   - Language translations

3. **🛠️ Tool Enhancements**
   - Automated test scripts
   - Report parsing tools
   - Visualization improvements
   - Performance benchmarks

4. **🐛 Bug Fixes**
   - Reproduction issues
   - Documentation errors
   - Analysis corrections
   - Tool compatibility

### Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/extractSSBsig.git
   cd extractSSBsig
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Add comprehensive documentation
   - Include validation steps

4. **Test Your Changes**
   - Verify MATLAB scripts run correctly
   - Check HDL generation succeeds
   - Validate synthesis reports

5. **Submit a Pull Request**
   - Provide clear description
   - Include before/after comparisons
   - Reference relevant issues

## 📋 Contribution Guidelines

### Code Standards

- **MATLAB Code**: Follow MathWorks style guidelines
- **Documentation**: Use clear, descriptive language
- **Comments**: Explain WHY, not just WHAT
- **Naming**: Use descriptive variable and function names

### Documentation Standards

- **Markdown**: Follow GitHub Flavored Markdown
- **Diagrams**: Use Mermaid for consistency
- **Tables**: Include units and clear headers
- **Links**: Use relative paths for internal references

### Analysis Standards

- **Reproducibility**: Provide complete reproduction steps
- **Validation**: Include post-synthesis confirmation
- **Evidence**: Support claims with data/reports
- **Methodology**: Document analysis approach clearly

## 🔍 Research Areas

### High-Priority Contributions

1. **FIFO Size Threshold Study**
   - Test sizes: 5, 6, 7, 8, 12, 24, 32, 64 entries
   - Document exact threshold where BRAM fails
   - Analyze intermediate resource usage patterns

2. **Cross-Platform Validation**
   - Intel/Altera Quartus synthesis
   - Lattice Diamond/Radiant tools
   - Microsemi Libero SoC
   - Compare BRAM inference behaviors

3. **HDL Coder Version Analysis**
   - Test R2022b, R2023a, R2023b, R2024a
   - Document version-specific behaviors
   - Track improvement/regression patterns

4. **Memory Pattern Extensions**
   - Ping-pong buffers
   - Multi-port memories
   - Shift registers
   - Custom memory interfaces

### Documentation Improvements

1. **Visual Enhancements**
   - Interactive plots (if possible in GitHub)
   - More detailed flowcharts
   - Architecture diagrams
   - Timeline visualizations

2. **Educational Content**
   - Beginner's guide to BRAM inference
   - Advanced optimization techniques
   - Common pitfall examples
   - Troubleshooting guide

3. **Automation Tools**
   - MATLAB scripts for batch analysis
   - Report parsing utilities
   - Automated validation framework
   - Continuous integration setup

## 🧪 Testing Requirements

### Before Submitting

1. **MATLAB Validation**
   ```matlab
   % Verify all scripts run without errors
   run_all_tests  % If test framework exists
   ```

2. **HDL Generation**
   ```matlab
   % Confirm HDL generation succeeds
   hdlcoder.runQuestasim('testbench_name')
   ```

3. **Documentation Review**
   - Check all links work
   - Verify code examples
   - Test reproduction steps

### Continuous Integration

We aim to implement automated testing for:
- MATLAB script validation
- HDL generation verification
- Documentation link checking
- Report parsing accuracy

## 📞 Communication

### Preferred Channels

1. **GitHub Issues**: Bug reports, feature requests
2. **GitHub Discussions**: Questions, ideas, general discussion
3. **Pull Requests**: Code/documentation contributions
4. **Email**: Collaboration inquiries, research partnerships

### Response Times

- **Issues**: We aim to respond within 48 hours
- **Pull Requests**: Initial review within 1 week
- **Discussions**: Community-driven, no guaranteed response time

## 🏆 Recognition

Contributors will be recognized in:
- **README.md acknowledgments**
- **Commit history preservation**
- **Release notes** for significant contributions
- **Co-authorship** for substantial research contributions

## 📜 License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers the project.

## ❓ Questions?

Don't hesitate to ask questions! We prefer:
1. **Public questions**: Use GitHub Discussions
2. **Private inquiries**: Email the maintainers
3. **Bug reports**: Create detailed GitHub Issues

Thank you for helping improve MATLAB HDL Coder design methodologies! 🎉
