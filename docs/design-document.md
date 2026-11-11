# Design Document: Traffic-Light Controller and Mod-N Counter

**Course:** Digital Electronics  
**Project:** Traffic-Light Controller + Mod-N Counter  
**Author:** Pranay Hajare

## 1. Objective

Design and verify a synchronous finite-state-machine (FSM) traffic-light controller for a simple two-road intersection, and provide a reusable parameterized Mod-N counter. The controller sequences the two directions so that only one direction is green at a time.

## 2. Functional requirements

1. Use a clocked sequential circuit.
2. Provide an active-low asynchronous reset.
3. On reset, show red on both roads as a safe indication.
4. Run the repeating sequence: NS green, NS yellow, EW green, EW yellow.
5. Hold each phase for a configurable number of clock cycles.
6. Provide a reusable counter that counts from 0 through N-1 and then returns to 0.
7. Verify the sequence in simulation.

## 3. Block-level architecture

The traffic-light controller consists of:
- **Clock and reset:** synchronize state progression to the rising clock edge and initialize the circuit.
- **FSM state register:** stores one of four traffic phases.
- **Phase timer:** counts clock cycles spent in the current phase.
- **Next-state logic:** advances to the next phase when the selected duration expires.
- **Output decoder:** maps the current state to the two road signals.

The separate Mod-N counter is a reusable building block for periodic timing and other digital designs.

## 4. State encoding and transition table

| State | Encoding | North-South | East-West | Next state |
|---|---:|---|---|---|
| NS_GO | 00 | Green | Red | NS_WARN |
| NS_WARN | 01 | Yellow | Red | EW_GO |
| EW_GO | 10 | Red | Green | EW_WARN |
| EW_WARN | 11 | Red | Yellow | NS_GO |

The FSM is a Moore machine: outputs depend on the present state. The reset output override forces both lights red while reset is asserted.

## 5. Timing

The phase durations are parameters:
- `GREEN_TICKS`: number of clock cycles for the North-South green phase.
- `YELLOW_TICKS`: number of clock cycles for each yellow phase.
- `RED_TICKS`: number of clock cycles for the East-West green phase (the opposing road remains red).

The example simulation uses GREEN_TICKS=3, YELLOW_TICKS=2, and RED_TICKS=3 to shorten simulation time. In hardware, these parameters can be set according to the clock frequency and required real-time durations.

For a clock frequency (f_{clk}), a phase lasting (T) seconds requires approximately (T \times f_{clk}) clock cycles.

## 6. Mod-N counter operation

The counter has an enable input and an active-low asynchronous reset. When enabled, it increments on each rising clock edge. When the current value is N-1, the next count is zero. Its terminal-count output is high when the current count equals N-1.

For N=10, the sequence is:
`0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, ...`

The minimum width is `ceil(log2(N))` bits, with a one-bit minimum for N=1.

## 7. Verification plan

The supplied testbench checks:
1. Reset forces both outputs red.
2. The controller begins with North-South green and East-West red after reset release.
3. The controller advances to North-South yellow.
4. The controller advances to East-West green.
5. The controller advances to East-West yellow.
6. The controller returns to the initial phase.

The testbench reports a failure and stops if an expected output does not match.

## 8. Expected result

The simulation should display PASS messages for all four phases and the repeated sequence, followed by:

`All traffic-light controller checks passed.`

## 9. Applications and future improvements

- Basic intersection signal sequencing.
- Pedestrian crossing phase support.
- Vehicle-sensor-based adaptive timing.
- Emergency-vehicle priority.
- Fault detection and a hardware fail-safe mode.

A real traffic-control installation requires additional safety analysis, redundant hardware, validated timing, and compliance with applicable road-safety standards. This project is an educational demonstration, not a deployable traffic-control product.

## 10. Conclusion

The project demonstrates finite-state-machine design, sequential logic, clock-based timing, parameterized counters, and simulation-based verification using SystemVerilog.
