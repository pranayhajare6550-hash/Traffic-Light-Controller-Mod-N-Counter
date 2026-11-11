// Two-road traffic-light controller using a four-state Moore FSM.
// Durations are expressed in clock cycles.
module traffic_light_controller #(
    parameter integer GREEN_TICKS  = 10,
    parameter integer YELLOW_TICKS = 3,
    parameter integer RED_TICKS    = 10
) (
    input  logic       clk,
    input  logic       rst_n,
    output logic [1:0] ns_light,
    output logic [1:0] ew_light,
    output logic [1:0] state
);

    localparam logic [1:0] RED    = 2'b00;
    localparam logic [1:0] YELLOW = 2'b01;
    localparam logic [1:0] GREEN  = 2'b10;

    localparam logic [1:0] NS_GO   = 2'd0;
    localparam logic [1:0] NS_WARN = 2'd1;
    localparam logic [1:0] EW_GO   = 2'd2;
    localparam logic [1:0] EW_WARN = 2'd3;

    logic [31:0] phase_count;
    logic [31:0] phase_limit;

    // Moore output logic. During reset, force both roads to red.
    always_comb begin
        ns_light = RED;
        ew_light = RED;

        if (rst_n) begin
            case (state)
                NS_GO: begin
                    ns_light = GREEN;
                    ew_light = RED;
                end
                NS_WARN: begin
                    ns_light = YELLOW;
                    ew_light = RED;
                end
                EW_GO: begin
                    ns_light = RED;
                    ew_light = GREEN;
                end
                EW_WARN: begin
                    ns_light = RED;
                    ew_light = YELLOW;
                end
                default: begin
                    ns_light = RED;
                    ew_light = RED;
                end
            endcase
        end
    end

    // Duration associated with the current phase.
    always_comb begin
        case (state)
            NS_GO:   phase_limit = GREEN_TICKS;
            NS_WARN: phase_limit = YELLOW_TICKS;
            EW_GO:   phase_limit = RED_TICKS;
            EW_WARN: phase_limit = YELLOW_TICKS;
            default: phase_limit = 1;
        endcase
    end

    // State and timer registers.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= NS_GO;
            phase_count <= 32'd0;
        end else begin
            if (phase_count >= phase_limit - 1) begin
                phase_count <= 32'd0;
                case (state)
                    NS_GO:   state <= NS_WARN;
                    NS_WARN: state <= EW_GO;
                    EW_GO:   state <= EW_WARN;
                    EW_WARN: state <= NS_GO;
                    default: state <= NS_GO;
                endcase
            end else begin
                phase_count <= phase_count + 1'b1;
            end
        end
    end

endmodule
