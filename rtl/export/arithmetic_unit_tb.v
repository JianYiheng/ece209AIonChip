`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// UCLA EDA LAB
// -----------------------------------------------------------------------------
// Engineer       : Chen Wu
// Design Name    : opu series
// Module Name    : arithmetric_unit_tb
// Target Devices : 325t
// Tool Versions  : Vivado 2020.1, Modelsim 2019.4
// Description    : 
//    Testbench for arithmetic_unit
// Revision       :
// Version        Date        Author        Descriptin
// 1.0            2021-04-04  Chen Wu       Initial version
// -----------------------------------------------------------------------------

module arithmetic_unit_tb();

  localparam    TEST_NUM  = 16                            ;

  localparam    CYCLE     = 5.0                           ; 

  wire      [31 : 0]        p           ;
  reg       [15 : 0]        x           ;
  reg       [ 7 : 0]        y           ;
  reg                       mode        ;

  reg                       clk         ;
  reg                       reset       ;
  integer cnt = 0;

  initial begin
      reset = 1;
      #(CYCLE/2);
      reset = 0;
  end

  always begin
      clk = 1'b1;
      #(CYCLE/2);
      clk = 1'b0;
      #(CYCLE/2);
  end

  always @(posedge clk) begin
      if (cnt == TEST_NUM) begin
          x <= 0;
          y <= 0;
          $finish;
      end else begin
          x <= $random % 65536;
          y <= $random % 256;
          mode <= 0;
          cnt <= cnt + 1;
      end
  end

  initial begin
      $dumpfile("icout/arithmetic_unit_wave.lxt");
      $dumpvars(0, arithmetic_unit_tb);
  end

  arithmetic_unit u0_arithmetic_unit (
    .p            ( p                 ),

    .x            ( x                 ),
    .y            ( y                 ),
    .mode         ( mode              ),

    .clk          ( clk               ),
    .reset        ( reset             )
  );

endmodule
