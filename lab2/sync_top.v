module sync_top(
    input  wire clk,
    input  wire signal,
    output wire signal_sync
);
    reg s1, s2;
    always @(posedge clk) begin
        s1 <= signal;
        s2 <= s1;
    end
    assign signal_sync = s2;
endmodule
