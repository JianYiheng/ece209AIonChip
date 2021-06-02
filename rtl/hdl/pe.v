`timescale 1ns / 1ps

module pe_unit (
    output reg [20-1: 0] dout,

    input [16*8-1: 0] ifm_in,
    input [16*16-1:  0] kernel_in,
    input mode,

    input clk,
    input reset
);

wire [16*32-1: 0] ofm;

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

reg [16*17-1: 0] adder_16_res;
generate
    for (i=0; i<16; i=i+1) 
    begin: adder_8
        always @(posedge clk) begin
            adder_16_res[i*17+:17] <= ofm[i*32+16+:16] + ofm[i*32+:16];
        end
    end
endgenerate

reg [8*18-1: 0] adder_8_res;
generate
    for (i=0; i<8; i=i+1) 
    begin: adder_4
        always @(posedge clk) begin
            adder_8_res[i*18+:18] <= adder_16_res[i*34+17+:17] + adder_16_res[i*34+:17];
        end
    end
endgenerate

reg [4*19-1: 0] adder_4_res;
generate
    for (i=0; i<4; i=i+1) 
    begin: adder_2
        always @(posedge clk) begin
            adder_4_res[i*19+:19] <= adder_8_res[i*36+18+:18] + adder_8_res[i*36+:18];
        end
    end
endgenerate

reg [2*20-1: 0] adder_2_res;
always @(posedge clk) begin
    dout <= adder_4_res[0+:20] <= adder_4_res[19+:19] + adder_4_res[0+:19];
end

endmodule
