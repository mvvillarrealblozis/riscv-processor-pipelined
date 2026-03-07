# RISC-V Processor in Verilog

A single-cycle RISC-V processor implementation in Verilog, with plans to evolve into a pipelined design.

## Current Status
- [ ] Single-cycle implementation
- [ ] RV32I base instruction set
- [ ] Basic testing

## Architecture
(Coming soon)

## How to Run
(Coming soon)

```mermaid
graph LR
    %% Global Signals
    clk((clk)) -.-> PC
    reset((reset)) -.-> PC

    subgraph "Fetch & Decode"
        PC[program_counter] -->|pc_out| IMEM[instruction_memory]
        IMEM -->|Instruction| ID[instruction_decoder]
    end

    subgraph "Control Unit"
        ID -->|opcode/funct3/funct7| CU[control_unit]
        CU -->|alu_op| ALU
        CU -->|alu_src| ALU_MUX{ }
        CU -->|reg_write| REGF
        CU -->|mem_read/write| DMEM
    end

    subgraph "Execution & Memory"
        ID -->|rs1/rs2/rd| REGF[register_file]
        ID -->|Imm_I/S/B/U/J| IMM_GEN[Immediate Gen]
        REGF -->|rdata1| ALU[alu]
        REGF -->|rdata2| BU[branch_unit]
        IMM_GEN --> ALU_MUX
        ALU_MUX --> ALU
        ALU -->|result| DMEM[data_memory]
    end

    subgraph "Feedback"
        BU -->|branch_taken| PC
        ALU -->|branch_target| PC
        DMEM -->|read_data| REGF
    end

    %% Styling for a Professional Look
    style CU fill:#f9f,stroke:#333,stroke-width:2px
    style ALU fill:#bbf,stroke:#333,stroke-width:2px
    style REGF fill:#bfb,stroke:#333,stroke-width:2px
    style ID fill:#fff4dd,stroke:#d4a017,stroke-width:2px
```

## Resources
- RISC-V ISA Spec: https://riscv.org/technical/specifications/
- RISC-V Card: https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
- RISC-V Reader

Cool Encoder Website I found: 
https://luplab.gitlab.io/rvcodecjs/#q=BEQ+x1,+x1,+-12&abi=false&isa=AUTO