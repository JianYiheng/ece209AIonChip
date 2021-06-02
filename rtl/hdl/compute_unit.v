`timescale 1ns / 1ps

module compute_unit (
    output reg [16*21-1: 0] cu_dout,

    input mode,
    input [16*16*8-1: 0] cu_ifm_in,
    input [16*16*16-1: 0] cu_kernel_in,

    input clk,
    input reset
);

wire [16*20-1: 0] pe_out;

genvar i;
generate
    for (i=0; i<16; i=i+1) begin: pe_unit
        pe_unit u_pe_unit(
            .dout(pe_out[i*20+:20]),
            .ifm_in(cu_ifm_in[i*16*8+:16*8]),
            .kernel_in(cu_kernel_in[i*16*16+:16*16]),
            .mode(mode)
        );
    end
endgenerate

generate
    for (i=0; i<8; i=i+1) begin: cu_adder
        always @(posedge clk) begin
            cu_dout[i*21+:21] <= pe_out[2*i*40+20+:20] + pe_out[2*i*40+:20];
        end
    end
endgenerate

endmodule
