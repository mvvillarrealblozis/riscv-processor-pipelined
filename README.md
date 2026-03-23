# RISC-V Five-Stage Pipelined Processor

[![Status](https://img.shields.io/badge/status-in%20development-yellow)]()
[![ISA](https://img.shields.io/badge/ISA-RV32I-blue)]()
[![Language](https://img.shields.io/badge/HDL-Verilog-orange)]()

> **Work in Progress:** This is the pipelined version of my [single-cycle RISC-V processor](https://github.com/mvvillarrealblozis/riscv-processor). Currently implementing five-stage pipeline with hazard detection and forwarding.

## Overview

This project extends my single-cycle RISC-V processor with a classic five-stage pipeline architecture (IF, ID, EX, MEM, WB) to achieve higher throughput through instruction-level parallelism.

**Target Features:**
- [ ] Five-stage pipeline (IF, ID, EX, MEM, WB)
- [ ] Data hazard detection
- [ ] Data forwarding (bypass paths)
- [ ] Load-use hazard stalling
- [ ] Control hazard handling (branch prediction)
- [ ] Pipeline register modules
- [ ] Flushing on mispredicted branches

## Pipeline Stages

### IF (Instruction Fetch)
Fetches instruction from memory using current PC value.

### ID (Instruction Decode)
Decodes instruction, reads registers, and generates control signals.

### EX (Execute)
Performs ALU operations, branch comparisons, and address calculations.

### MEM (Memory)
Accesses data memory for loads/stores.

### WB (Write Back)
Writes results back to register file.

## Performance Goals

**Single-Cycle Baseline:**
- CPI: 1.0
- Clock: ~125 MHz
- Throughput: 125 MIPS

**Pipelined Target:**
- CPI: ~1.0 (ideal, closer to 1.2-1.4 with hazards)
- Clock: ~250 MHz (shorter critical path)
- Throughput: ~200 MIPS (1.6x improvement)

## Project Structure
```
riscv-processor-pipelined/
├── rtl/
│   ├── cpu.v                      # Top-level pipelined CPU
│   ├── pipeline_registers/
│   │   ├── if_id.v                # IF/ID pipeline register
│   │   ├── id_ex.v                # ID/EX pipeline register
│   │   ├── ex_mem.v               # EX/MEM pipeline register
│   │   └── mem_wb.v               # MEM/WB pipeline register
│   ├── hazard_unit.v              # Hazard detection and forwarding
│   └── ... (single-cycle modules)
└── testbench/
    └── ... (updated testbenches)
```

## Development Log

### Completed
- ✅ Single-cycle processor (see [base repo](https://github.com/mvvillarrealblozis/riscv-processor))

### In Progress
- Pipeline register design
- Hazard detection unit
- Forwarding paths

### Planned
- Branch prediction
- Performance benchmarking
- FPGA synthesis

## Background: Single-Cycle Processor

This pipelined processor is based on my fully functional single-cycle RISC-V implementation. See the [single-cycle version](https://github.com/mvvillarrealblozis/riscv-processor) for:
- Complete RV32I ISA support
- Detailed architecture documentation
- Module descriptions and testing methodology

## Getting Started

*Instructions will be added as pipeline is implemented.*

## Author

Max Villarreal-Blozis  
UC Davis - M.S. Electrical and Computer Engineering  
[GitHub](https://github.com/mvvillarrealblozis)