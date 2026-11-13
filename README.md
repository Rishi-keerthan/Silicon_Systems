# Low Power ALU using Operand Isolation

A 4-bit ALU in Verilog, written in two versions: a baseline and one with operand isolation. The project compares the switching activity and dynamic power of the two.

## Designs

| File | Module | Description |
|---|---|---|
| `rtl/ALU.v` | `alu` | Baseline 4-bit ALU, no isolation |
| `rtl/Iso_ALU.v` | `alu_isolated` | Same ALU with operand isolation and an `enable` input |
| `tb/LP_ALU_tb.v` | `LP_ALU_tb` | Testbench that drives both ALUs with the same inputs and counts output transitions |

**Operations** (selected by the 2-bit `op` input):

| `op` | Operation |
|---|---|
| `00` | A + B |
| `01` | A - B |
| `10` | A & B |
| `11` | A \| B |

The output `Y` is 5 bits wide. For ADD, `Y[4]` is the carry out. For SUB, the result is a 5-bit two's-complement value.

## How operand isolation works

In `alu_isolated`, the operands are gated before they reach the ALU logic:

```verilog
assign A_iso = enable ? A : 4'b0000;
assign B_iso = enable ? B : 4'b0000;
```

When `enable = 0`, both operands are forced to zero, so changes on `A` and `B` no longer propagate through the adder, subtractor, and logic units. When `enable = 1`, the behavior matches the baseline.

## Testbench and switching activity

The testbench applies 16 input vectors, one every 10 ns. The first 7 vectors run with `enable = 1`. After that `enable` is set to 0, so `alu_isolated` is idle while `alu` keeps receiving changing inputs. Switching activity is measured as transitions on output `Y` divided by the number of input vectors (16).

## Results

| Metric | Baseline `alu` | `alu_isolated` | Reduction |
|---|---|---|---|
| Switching activity factor (ModelSim) | 0.8125 (13/16) | 0.375 (6/16) | ~54% |
| Dynamic power, logic and signal (Vivado) | 0.595 W | 0.359 W | ~39.7% |

Dynamic power follows P = α C V² f, so the lower activity factor leads to lower dynamic power.

## Notes

- The ALU is purely combinational.
- Power savings appear only while the ALU is idle (`enable = 0`), and the stimulus has the ALU idle for more than half of the vectors.
- Activity is counted on the output `Y` only.

## How to run

Compile and simulate with ModelSim (or any Verilog simulator). Testbench top module: `LP_ALU_tb`.

```
vlog rtl/ALU.v rtl/Iso_ALU.v tb/LP_ALU_tb.v
vsim LP_ALU_tb
run -all
```

Transition counts are printed at the end of the run. The testbench also writes a waveform dump, `alu_compare.vcd`.

## Repository structure

```
rtl/        ALU.v, Iso_ALU.v
tb/         LP_ALU_tb.v
reports/    Vivado power reports and screenshots
README.md
```
