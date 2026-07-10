# RISC-V Five-Stage Pipelined Processor

A fully functional five-stage pipelined RISC-V processor implementing the RV32I base integer instruction set, with forwarding, hazard detection, and branch flush control.

## Overview

This processor implements a traditional five-stage pipeline (IF → ID → EX → MEM → WB) with full hazard handling. All three types of pipeline hazards are addressed: structural hazards (avoided by design), data hazards (forwarding + stalling), and control hazards (flushing). This project extends a prior [single-cycle RISC-V implementation](https://github.com/mvvillarrealblozis/riscv-processor) with a pipelined microarchitecture for improved throughput.

## Architecture

### Pipeline Stages

| Stage | Function |
|---|---|
| **IF** | Fetch instruction from memory, update PC |
| **ID** | Decode instruction, read registers, generate control signals |
| **EX** | ALU operations, branch comparison, address calculation |
| **MEM** | Load/store data memory access |
| **WB** | Write results back to register file |

### Pipeline Diagram

![RISC-V Pipeline Architecture](docs/images/cpu_pipeline.svg)

*Figure: Five-stage pipeline showing all modules, forwarding paths, and control hazard handling.*

### Hazard Handling

**Data Hazards:**
- EX/MEM → EX and MEM/WB → EX forwarding paths resolve most RAW dependencies with zero-cycle penalty
- Load-use hazard detection inserts a one-cycle stall when a load result is immediately consumed

**Control Hazards:**
- Branch resolution in EX stage with a 2-cycle penalty
- IF/ID and ID/EX pipeline registers flushed on taken branches and jumps

**Structural Hazards:**
- Avoided by design via separate instruction and data memories and write-before-read register file

### Key Design Decisions

- **Branch resolution in EX, not ID:** Branch resolution requires the ALU for comparison and address calculation. Keeping it in EX simplifies the ID stage and balances the critical path, at the cost of a 2-cycle branch penalty.
- **Two-stage flush on taken branch:** When a branch resolves in EX, two wrong-path instructions are already in IF and ID. Both must be converted to NOPs to maintain correctness.
- **MEM-stage forwarding:** Forwarding from MEM rather than waiting for WB reduces data hazard latency by one cycle when data is available earlier.

## Parameters

This is a fixed RV32I implementation. Key sizing constants:

| Constant | Value | Description |
|---|---|---|
| Register file | 32 × 32-bit | General-purpose registers |
| Data memory | 256 × 32-bit | RAM for loads and stores |

## Repository Structure

```
riscv-processor-pipelined/
├── rtl/
│   ├── top/
│   │   └── cpu.v
│   ├── core/
│   │   ├── alu.v
│   │   ├── control_unit.v
│   │   ├── instruction_decoder.v
│   │   ├── register_file.v
│   │   ├── branch_unit.v
│   │   ├── forwarding_unit.v
│   │   ├── hazard_detection_unit.v
│   │   └── program_counter.v
│   ├── memory/
│   │   ├── instruction_memory.v
│   │   └── data_memory.v
│   └── pipeline/
│       ├── if_id.v
│       ├── id_ex.v
│       ├── ex_mem.v
│       └── mem_wb.v
└── testbench/
    └── top/
        └── cpu_testbench.v
```

## Simulation

### Requirements

- Icarus Verilog with `-g2012` flag
- GTKWave for waveform viewing

### Run

```bash
iverilog -o cpu_test -s cpu_testbench \
    rtl/core/*.v rtl/memory/*.v rtl/pipeline/*.v rtl/top/*.v \
    testbench/top/cpu_testbench.v

vvp cpu_test
gtkwave cpu_testbench.vcd
```

## Results

8/8 directed tests passing covering all major pipeline scenarios.

| Test | Validates |
|---|---|
| EX Hazard | EX-to-EX forwarding |
| MEM Hazard | MEM-to-EX forwarding |
| Load-Use | Stall insertion + forwarding |
| Complex Dependencies | Multiple simultaneous forwarding paths |
| Branch Taken | Pipeline flush on taken branch |
| Branch Not Taken | No flush when branch not taken |
| JAL | Unconditional jump with return address |
| JALR | Register-indirect jump |

```
Test 1 (EX Hazard):      x1=5, x2=15               ✓
Test 2 (MEM Hazard):     x3=5, x4=15               ✓
Test 3 (Load-Use):       x5=32, x6=42              ✓
Test 4 (Complex):        x7=5, x8=15, x9=20        ✓
Test 5 (Branch Taken):   x10=5, x11=5, x12=0       ✓
Test 6 (Branch Not Taken): x15=5, x16=10, x17=1   ✓
Test 7 (JAL):            x25=0x88, x19=0, x20=0   ✓
Test 8 (JALR):           x25=0x88, x22=16, x23=0  ✓
ALL TESTS PASSED
```

## Synthesis

RTL was synthesized using Yosys targeting the Sky130 open-source standard-cell library. Estimated operating frequency ~100 MHz. Dominant timing path through decode-stage register file muxing. 466 pipeline flip-flops total across all four pipeline registers.

## Background

This project is part of an ASIC digital design portfolio targeting roles in RTL design and digital verification. It demonstrates pipelined processor microarchitecture, hazard detection and resolution, and RTL design discipline directly applicable to industry roles in CPU and SoC design.
