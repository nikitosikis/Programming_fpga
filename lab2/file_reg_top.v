module file_reg_top (       
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    output reg  [31:0] rdata1,
    output reg  [31:0] rdata2
);
    reg [31:0] regs [0:31];

    always @(posedge clk) begin
        if (we)
            regs[waddr] <= wdata;
        rdata1 <= regs[raddr1];
        rdata2 <= regs[raddr2];
    end
endmodule
