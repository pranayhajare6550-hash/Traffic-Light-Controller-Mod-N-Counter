// Parameterized synchronous Mod-N counter.
// Active-low asynchronous reset; count advances when enable is high.
module mod_n_counter #(
    parameter integer N = 10,
    parameter integer WIDTH = (N <= 1) ? 1 : $clog2(N)
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 enable,
    output logic [WIDTH-1:0]     count,
    output logic                 terminal_count
);

    // N must be at least 1. For N=1, the counter remains at zero.
    assign terminal_count = (count == N-1);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (enable) begin
            if (count == N-1)
                count <= '0;
            else
                count <= count + 1'b1;
        end
    end

endmodule
