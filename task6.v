module task6(
    input  wire clk,
    input  wire a,
    input  wire b,
    input wire dff_state,
    output q,
    output reg state
);

my_dff dff_inst (
    .clk(clk),
    .d(state),
    .q(dff_state)
);


    assign q = a ^ b ^ dff_state;

    always @(posedge clk) begin
        if (b == a)
            state <= a;
    end
endmodule

module my_dff (
    input clk,
    input d,
    output reg q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule