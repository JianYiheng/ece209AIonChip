`timescale 1ns / 1ps

module pe_unit (
    output reg [20-1: 0] pe_ofm0,
    output reg [20-1: 0] pe_ofm1,

    input [16*8-1: 0] pe_ifm,
    input [16*16-1:  0] pe_kernel,
    input [1: 0] mode,

    input clk,
    input reset
);

wire [16*32-1: 0] ofm;
reg   [16*8-1: 0] pe_ifm_in;
reg  [16*16-1: 0] pe_kernel_in;
reg     [20-1: 0] pe_ofm_out;

always @(posedge clk) begin
    if (rst) begin
        ifm_in <= 0;
        kernel_in <= 0;
    end else begin
        ifm_in <= ifm;
        kernel_in <= kernel;
    end
end

always @(posedge clk) begin
    pe_ofm0 <= pe_ofm0_out;
    pe_ofm1 <= pe_ofm1_out;
end

genvar i;
generate
for(i=0 ; i<16; i=i+1) 
begin: arithmetic_unit_instance
    arithmetic_unit u_arithmetic_unit(
        .p(ofm[i*32+:32]),

        .x(kernel_in[i*16+:16]),
        .y(ifm_in[i*8+:8]),
        .mode(mode),
        .clk(clk),
        .reset(reset)
   );
end 
endgenerate

always @(posedge clk) begin
end

endmodule
