`timescale 1ns/1ps

module tb_lab6;

  // ускоренная симуляция
  localparam integer CLK_HZ = 10_000_000;

  reg clk = 0;
  always #50 clk = ~clk; // 10 MHz

  reg rst_n = 0;

  // линии между ПЛИС и моделями DAC/ADC
  wire dac_sync_n, dac_sclk, dac_din;
  wire adc_cs_n, adc_sclk, adc_din;
  reg  adc_dout = 1'b0;
  wire uart_tx;

  // DUT
  lab6_top #(
    .CLK_HZ(CLK_HZ),
    .SPI_HZ(1_000_000),
    .BAUD(1_000_000),
    .SAMPLE_HZ(2000),
    .UART_DECIM(1),
    .ADC_MSB_SHIFT(4),
    .DAC_CPHA(1),
    .ADC_CPHA(0)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),

    .dac_sync_n(dac_sync_n),
    .dac_sclk(dac_sclk),
    .dac_din(dac_din),

    .adc_cs_n(adc_cs_n),
    .adc_sclk(adc_sclk),
    .adc_din(adc_din),
    .adc_dout(adc_dout),

    .uart_tx(uart_tx)
  );

  // ----------------- модель DAC -----------------
  reg [15:0] dac_shift_in;
  integer dac_cnt;
  reg [11:0] last_dac_code;

  always @(negedge dac_sync_n) begin
    dac_shift_in = 16'h0;
    dac_cnt = 0;
  end

  always @(posedge dac_sclk) begin
    if (!dac_sync_n) begin
      dac_shift_in = {dac_shift_in[14:0], dac_din};
      dac_cnt = dac_cnt + 1;
    end
  end

  always @(posedge dac_sync_n) begin
    if (dac_cnt == 16) begin
      last_dac_code <= dac_shift_in[11:0];
    end
  end

  // ----------------- модель ADC -----------------
  reg [15:0] adc_shift_out;

  always @(negedge adc_cs_n) begin
    adc_shift_out = {last_dac_code, 4'b0000};
    adc_dout = adc_shift_out[15];
  end

  always @(negedge adc_sclk) begin
    if (!adc_cs_n) begin
      adc_shift_out = {adc_shift_out[14:0], 1'b0};
      adc_dout = adc_shift_out[15];
    end
  end

  // ----------------- reset + stop -----------------
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_lab6);

    repeat(20) @(posedge clk);
    rst_n = 1;

    // подождём немного работы
    repeat(50000) @(posedge clk);

    $display("TB finished");
    $finish;
  end

endmodule

// ============================================================
// STUB DDS_II_Top (без Gowin)
// ============================================================
module DDS_II_Top(
  input  wire       clk_i,
  input  wire       rst_n_i,
  output reg [26:0] phase_out_o,
  output reg [11:0] cosine_o,
  output reg [11:0] sine_o,
  output reg        data_valid_o
);
  reg [11:0] cnt;

  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      cnt <= 12'h800;
      sine_o <= 12'h800;
      cosine_o <= 12'h800;
      phase_out_o <= 27'd0;
      data_valid_o <= 1'b0;
    end else begin
      cnt <= cnt + 12'd17;
      sine_o <= cnt;
      cosine_o <= ~cnt;
      phase_out_o <= phase_out_o + 1;
      data_valid_o <= 1'b1;
    end
  end
endmodule
