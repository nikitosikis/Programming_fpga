module ram_top#(
    parameter N = 4,
    parameter M = 32
)(
    input  wire              clk,
    input  wire              we,
    input  wire [N-1:0]      adr,
    input  wire [M-1:0]      din,
    output reg  [M-1:0]      dout
);
    reg [M-1:0] mem [0:(1<<N)-1];

    always @(posedge clk) begin
        if (we)
            mem[adr] <= din;
    end    

    always @(*) begin
        dout = mem[adr];
    end
endmodule
