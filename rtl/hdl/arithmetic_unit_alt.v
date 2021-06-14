`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// UCLA EDA LAB
// -----------------------------------------------------------------------------
// Engineer       : Chen Wu
// Design Name    : opu series
// Module Name    : arithmetic_unit
// Target Devices : 325t
// Tool Versions  : Vivado 2020.1, Modelsim 2019.4
// Description    : 
//    In general, it performs p = x * y, for more than one multipliers, 
//    y is shared;
//
//    Compact different number of low precision multiplications into one dsp.
//    one DSP48E1 is configured as (A+D)*B+C, assign different A,B,C,D to have:
//      mixed precision, support both 2 int8*int8 and 4 int4*int3
//    
//    For int8*int8, x is [x0(int8), x1(int8)], and for int4*int3, 
//
//    Delay: 4 cycles
// Revision       :
// Version        Date        Author        Descriptin
// 1.0            2021-04-22  Chen Wu       Initial version
// -----------------------------------------------------------------------------


module arithmetic_unit (
  output  reg    [31 : 0]       p                         ,

  input           [15 : 0]      x                         ,
  input           [ 7 : 0]      y                         ,
  input           [ 1 : 0 ]      mode                      ,

  input                         clk                       ,
  input                         reset                     
  );

  reg             [24 : 0]      dsp_a = 0                 ;
  reg             [17 : 0]      dsp_b = 0                 ;
  reg             [47 : 0]      dsp_c = 0                 ;
  reg             [24 : 0]      dsp_d = 0                 ;
//  reg             [47:  0]      dsp_p;
  wire            [47 : 0]      dsp_p                     ;

  wire            [ 6 : 0]      dsp_a_part0               ;
  wire            [ 6 : 0]      dsp_a_part1               ;
  wire            [ 6 : 0]      dsp_a_part2               ;

  wire            [ 2 : 0]      dsp_a_part3               ;
  wire            [ 2 : 0]      dsp_a_part4               ;
  wire            [ 2 : 0]      dsp_a_part5               ;
  wire            [ 2 : 0]      dsp_a_part6               ;
  wire            [ 2 : 0]      dsp_a_part7               ;
  wire            [ 2 : 0]      dsp_a_part8               ;
  wire            [ 2 : 0]      dsp_a_part9               ;

  wire            [ 7 : 0]      dsp_c_flag_2bit;

  wire            [ 2 : 0]      dsp_c_flag                ;
  wire            [47 : 0]      dsp_c_nd                  ;

  reg             [15 : 0]      x_s                       ; 
  reg             [7  : 0]      y_s                       ;
  reg             [31:  0]      p_s                       ;

  always @(posedge clk) begin
      if (reset) begin
          x_s <= 0;
          y_s <= 0;
      end else begin
          x_s <= x;
          y_s <= y;
      end
  end

  assign dsp_a_part0  = $signed(x_s[3 : 0]);
  assign dsp_a_part1  = {{(3){x_s[7]}}, x_s[7 : 4]} - {6'h0, x_s[3]};
  assign dsp_a_part2  = {{(3){x_s[11]}}, x_s[11 : 8]} - {6'h0, dsp_a_part1[6]};

  assign dsp_a_part3  = $signed(x_s[1 : 0]);
  assign dsp_a_part4  = {x_s[3], x_s[3: 2]} - {2'h0, x_s[1]};
  assign dsp_a_part5  = {x_s[5], x_s[5: 4]} - {2'h0, dsp_a_part4[2]};
  assign dsp_a_part6  = {x_s[7], x_s[7: 6]} - {2'h0, dsp_a_part5[2]};
  assign dsp_a_part7  = {x_s[9], x_s[9: 8]} - {2'h0, dsp_a_part6[2]};
  assign dsp_a_part8  = {x_s[11], x_s[11: 10]} - {2'h0, dsp_a_part7[2]};
  assign dsp_a_part9  = {x_s[13], x_s[13: 12]} - {2'h0, dsp_a_part8[2]};

  assign  dsp_c_flag[0] = (x_s[3] ^ y_s[3]) & (|x_s[3 : 0]) & (|y_s[3 : 0]);
  assign  dsp_c_flag[1] = (x_s[7] ^ y_s[3]) & (|x_s[7 : 4]) & (|y_s[3 : 0]);
  assign  dsp_c_flag[2] = (x_s[11] ^ y_s[3]) & (|x_s[11 : 8]) & (|y_s[3 : 0]);

  assign dsp_c_flag_2bit[0] = (x_s[1] ^ y_s[1]) & (|x_s[1: 0]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[1] = (x_s[3] ^ y_s[1]) & (|x_s[3: 2]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[2] = (x_s[5] ^ y_s[1]) & (|x_s[5: 4]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[3] = (x_s[7] ^ y_s[1]) & (|x_s[7: 6]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[4] = (x_s[9] ^ y_s[1]) & (|x_s[9: 8]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[5] = (x_s[11] ^ y_s[1]) & (|x_s[11: 10]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[6] = (x_s[13] ^ y_s[1]) & (|x_s[13: 12]) & (|y_s[1: 0]);
  assign dsp_c_flag_2bit[7] = (x_s[15] ^ y_s[1]) & (|x_s[15: 14]) & (|y_s[1: 0]);

  assign  dsp_c_nd  =  ((x_s[7] ^ y_s[7]) & 
                   (|x_s[7 : 0]) & 
                   (|y_s[7 : 0])) ? 48'h0000_0001_0000 : 48'h0          ;

  always @(posedge clk) begin
    if ( mode[1] )
        dsp_a <= $signed({dsp_a_part9, dsp_a_part8, dsp_a_part7, dsp_a_part6, dsp_a_part5, dsp_a_part4, dsp_a_part3});
    else if (mode[0])
      dsp_a <= $signed({dsp_a_part2, dsp_a_part1, dsp_a_part0})         ;
    else
      dsp_a <= $signed(x_s[7 : 0])                                      ;
  end

  always @(posedge clk) begin
      if (mode[1])
          dsp_b <= $signed(y_s[1: 0]);
      else if ( mode [0])
          dsp_b <= $signed(y_s[3 : 0])                                      ;
      else
          dsp_b <= $signed(y_s)                                             ;
  end

  always @(posedge clk) begin
      if (mode[1])
          dsp_d <= $signed(x_s[15: 14]) << 21;
      else if ( mode[0] )
          dsp_d <= $signed(x_s[15 : 12]) << 21                              ;
      else
          dsp_d <= $signed(x_s[15 : 8]) << 16                               ;
  end

  always @(posedge clk) begin
    if ( mode[0] == 1 ) 
        case ( dsp_c_flag )
            3'h0  : dsp_c <=  {26'h0, 22'h00_0000}    ;
            3'h1  : dsp_c <=  {26'h0, 22'h00_0080}    ;
            3'h2  : dsp_c <=  {26'h0, 22'h00_4000}    ;
            3'h3  : dsp_c <=  {26'h0, 22'h00_4080}    ;
            3'h4  : dsp_c <=  {26'h0, 22'h20_0000}    ;
            3'h5  : dsp_c <=  {26'h0, 22'h20_0080}    ;
            3'h6  : dsp_c <=  {26'h0, 22'h20_4000}    ;
            3'h7  : dsp_c <=  {26'h0, 22'h20_4080}    ;
        endcase
    else if (mode[1] == 1) begin
        dsp_c[3]  <= dsp_c_flag_2bit[0]?1: 0;
        dsp_c[6]  <= dsp_c_flag_2bit[1]?1: 0;
        dsp_c[9]  <= dsp_c_flag_2bit[2]?1: 0;
        dsp_c[12] <= dsp_c_flag_2bit[3]?1: 0;
        dsp_c[15] <= dsp_c_flag_2bit[4]?1: 0;
        dsp_c[18] <= dsp_c_flag_2bit[5]?1: 0;
        dsp_c[21] <= dsp_c_flag_2bit[6]?1: 0;
    end else
        dsp_c   <=  dsp_c_nd;
  end
  
  wire [47: 0] dsp_c_zero;
  assign dsp_c_zero = 0;

  (*use_dsp48 = "yes"*) dsp_mac u0_dsp_mac (
    .CLK    ( clk         ),
    .SCLR   ( reset       ),
    .A      ( dsp_a       ),
    .B      ( dsp_b       ),
    .C      ( dsp_c       ),
    .D      ( dsp_d       ),
    .P      ( dsp_p       ) 
  );

//     xbip_dsp48_macro_0 u0_dsp_mac (
//     .CLK    ( clk         ),
//     .SCLR   ( reset       ),
//     .A      ( dsp_a       ),
//     .B      ( dsp_b       ),
//     .C      ( dsp_c       ),
//     .D      ( dsp_d       ),
//     .P      ( dsp_p       ) 
//   );


    reg             [ 7 : 0]      dsp_c_flag_2bit_s0;
    reg             [ 7 : 0]      dsp_c_flag_2bit_s1;
    reg             [ 7 : 0]      dsp_c_flag_2bit_s2;
    reg             [ 7 : 0]      dsp_c_flag_2bit_s3;
    reg             [ 7 : 0]      dsp_c_flag_2bit_s4;
    wire            [ 7 : 0]      dsp_c_flag_2bit_s;

    always @(posedge clk) begin
        if (reset) begin
            dsp_c_flag_2bit_s0 <= 0;
            dsp_c_flag_2bit_s1 <= 0;
            dsp_c_flag_2bit_s2 <= 0;
            dsp_c_flag_2bit_s3 <= 0;
            dsp_c_flag_2bit_s4 <= 0;
        end else begin
            dsp_c_flag_2bit_s0 <= dsp_c_flag_2bit;
            dsp_c_flag_2bit_s1 <= dsp_c_flag_2bit_s0;
            dsp_c_flag_2bit_s2 <= dsp_c_flag_2bit_s1;
            dsp_c_flag_2bit_s3 <= dsp_c_flag_2bit_s2;
            dsp_c_flag_2bit_s4 <= dsp_c_flag_2bit_s3;
        end
    end

    assign dsp_c_flag_2bit_s = dsp_c_flag_2bit_s4;

    assign p_s = mode[1] ? {
          dsp_c_flag_2bit_s[7], dsp_p[23: 21],
          dsp_c_flag_2bit_s[6], dsp_p[20: 18],
          dsp_c_flag_2bit_s[5], dsp_p[17: 15],
          dsp_c_flag_2bit_s[4], dsp_p[14: 12],
          dsp_c_flag_2bit_s[3], dsp_p[11: 9],
          dsp_c_flag_2bit_s[2],  dsp_p[8: 6],
          dsp_c_flag_2bit_s[1],  dsp_p[5: 3],
          dsp_c_flag_2bit_s[0],  dsp_p[2: 0]
        }: mode[0] ? {
          dsp_p[27], dsp_p[27:21],
          dsp_p[20], dsp_p[20:14],
          dsp_p[13], dsp_p[13: 7],
          dsp_p[ 6], dsp_p[ 6: 0]} :
          dsp_p[31:0];
  
    always @(posedge clk) begin
        if (reset) begin
            p <= 0;
        end else begin
            p <= p_s;
        end
    end
  
    initial begin
        $dumpfile("arithmetic_unit.vcd");
        $dumpvars(0, arithmetic_unit);
    end

endmodule
