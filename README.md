# Traffic-Light Controller + Mod-N Counter

**Digital Electronics Capstone Project**

This repository contains a parameterized SystemVerilog traffic-light controller and a reusable Mod-N counter.

## Project contents

- `rtl/mod_n_counter.sv` — synchronous Mod-N counter with enable and active-low asynchronous reset.
- `rtl/traffic_light_controller.sv` — four-state controller for a two-road intersection.
- `tb/tb_traffic_light_controller.sv` — simple self-checking simulation testbench.
- `docs/design-document.md` — design description, state table, timing, and verification plan.

## Traffic-light sequence

1. North-South green; East-West red.
2. North-South yellow; East-West red.
3. North-South red; East-West green.
4. North-South red; East-West yellow.
5. Repeat from step 1.

The durations are configurable through the `GREEN_TICKS`, `YELLOW_TICKS`, and `RED_TICKS` parameters. Each duration is measured in rising clock edges.

## Interface

### Traffic-light controller

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock |
| `rst_n` | Input | Active-low asynchronous reset |
| `ns_light` | Output [1:0] | North-South signal |
| `ew_light` | Output [1:0] | East-West signal |
| `state` | Output [1:0] | Current FSM state, for observation |

Light encoding: `2'b00` = red, `2'b01` = yellow, `2'b10` = green.

### Mod-N counter

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Clock |
| `rst_n` | Input | Active-low asynchronous reset |
| `enable` | Input | Enables counting |
| `count` | Output | Current count |
| `terminal_count` | Output | High when count is N-1 |

## Run a simulation

Using Icarus Verilog with SystemVerilog support:

```sh
iverilog -g2012 -s tb_traffic_light_controller -o sim.out rtl/traffic_light_controller.sv tb/tb_traffic_light_controller.sv
vvp sim.out
```

The testbench uses short timing parameters so the full sequence can be checked quickly.

## Design notes

- The FSM changes state only on a rising clock edge.
- Reset immediately places the controller in the safe state: both roads red (the initial FSM state is NS green/EW red after reset deassertion; while reset is asserted the combinational outputs are both red).
- The controller uses a counter to hold each phase for its configured number of clock cycles.
- This is an educational synchronous model. A real road installation needs sensor handling, fail-safe hardware, pedestrian phases, and safety certification.

## Author

Pranay Hajare
