`timescale 1ns/1ps

module tb_traffic_light_controller;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic [1:0] ns_light;
    logic [1:0] ew_light;
    logic [1:0] state;

    localparam logic [1:0] RED    = 2'b00;
    localparam logic [1:0] YELLOW = 2'b01;
    localparam logic [1:0] GREEN  = 2'b10;

    always #5 clk = ~clk;

    traffic_light_controller #(
        .GREEN_TICKS(3),
        .YELLOW_TICKS(2),
        .RED_TICKS(3)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ns_light(ns_light),
        .ew_light(ew_light),
        .state(state)
    );

    task automatic check_lights(
        input logic [1:0] expected_ns,
        input logic [1:0] expected_ew,
        input string phase_name
    );
        begin
            if (ns_light !== expected_ns || ew_light !== expected_ew) begin
                $error("FAIL in %s: NS=%b EW=%b", phase_name, ns_light, ew_light);
                $fatal(1);
            end
            $display("PASS: %s", phase_name);
        end
    endtask

    initial begin
        // Assert reset and verify safe outputs.
        #2;
        if (ns_light !== RED || ew_light !== RED)
            $fatal(1, "Reset outputs must both be red");

        // Release reset away from the active clock edge.
        #10 rst_n = 1'b1;
        #1;
        check_lights(GREEN, RED, "NS green / EW red");

        // NS green lasts 3 rising edges, then NS yellow.
        repeat (3) @(posedge clk);
        #1;
        check_lights(YELLOW, RED, "NS yellow / EW red");

        // Yellow lasts 2 rising edges, then EW green.
        repeat (2) @(posedge clk);
        #1;
        check_lights(RED, GREEN, "NS red / EW green");

        // EW green lasts 3 rising edges, then EW yellow.
        repeat (3) @(posedge clk);
        #1;
        check_lights(RED, YELLOW, "NS red / EW yellow");

        // Yellow lasts 2 rising edges, then sequence repeats.
        repeat (2) @(posedge clk);
        #1;
        check_lights(GREEN, RED, "sequence repeats");

        $display("All traffic-light controller checks passed.");
        $finish;
    end

endmodule
