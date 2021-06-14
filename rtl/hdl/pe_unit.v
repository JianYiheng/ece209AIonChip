`timescale 1ns / 1ps

module pe_unit (
    output reg [21-1: 0] pe_ofm0,
    output reg [21-1: 0] pe_ofm1,

    input [32*8-1: 0] pe_ifm,
    input [32*16-1:  0] pe_kernel,
    input [1: 0] mode,

    input clk,
    input reset
);

wire [16*32-1: 0] ofm;
reg   [32*8-1: 0] pe_ifm_in;
reg  [32*16-1: 0] pe_kernel_in;
reg     [21-1: 0] pe_ofm_out;

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
for(i=0 ; i<32; i=i+1) 
begin: arithmetic_unit_ins
    arithmetic_unit u_arithmetic_unit(
        .p({ofm0[i*16+:16], ofm1[i*16+:16]}),

        .x(kernel_in[i*16+:16]),
        .y(ifm_in[i*8+:8]),
        .mode(mode),
        .clk(clk),
        .reset(reset)
   );
end 
endgenerate

reg [17*16-1: 0] ofm0_lv0=0;
reg [17*16-1: 0] ofm1_lv0=0;
generate
    for(i=0; i<16; i=i+1)
    begin: at_lv0_ins
        always @(posedge clk) begin
            if (reset) begin
                ofm0_lv0[17*i-1: 0] <= 0;
                ofm1_lv0[17*i-1: 0] <= 0;
            end else begin
                ofm0_lv0[17*i-1: 0] <= ofm0[2*i*16+:16] + ofm0[2*i*16+16+:16];
                ofm1_lv0[17*i-1: 0] <= ofm1[2*i*16+:16] + ofm1[2*i*16+16+:16];
            end
        end
    end
endgenerate

reg [18*8-1: 0] ofm0_lv1=0;
reg [18*8-1: 0] ofm1_lv1=0;
generate
    for(i=0; i<8; i=i+1)
    begin: at_lv0_ins
        always @(posedge clk) begin
            if (reset) begin
                ofm0_lv1[18*i-1: 0] <= 0;
                ofm1_lv1[18*i-1: 0] <= 0;
            end else begin
                ofm0_lv1[18*i-1: 0] <= ofm0_lv0[2*i*17+:17] + ofm0_lv0[2*i*17+17+:17];
                ofm1_lv1[18*i-1: 0] <= ofm1_lv0[2*i*17+:17] + ofm1_lv0[2*i*17+17+:17];
            end
        end
    end
endgenerate

reg [19*4-1: 0] ofm0_lv2=0;
reg [19*4-1: 0] ofm1_lv2=0;
generate
    for(i=0; i<4; i=i+1)
    begin: at_lv0_ins
        always @(posedge clk) begin
            if (reset) begin
                ofm0_lv2[19*i-1: 0] <= 0;
                ofm1_lv2[19*i-1: 0] <= 0;
            end else begin
                ofm0_lv2[19*i-1: 0] <= ofm0_lv1[2*i*18+:18] + ofm0_lv1[2*i*18+18+:18];
                ofm1_lv2[19*i-1: 0] <= ofm1_lv1[2*i*18+:18] + ofm1_lv1[2*i*18+18+:18];
            end
        end
    end
endgenerate

reg [20*2-1: 0] ofm0_lv3=0;
reg [20*2-1: 0] ofm1_lv3=0;
generate
    for(i=0; i<2; i=i+1)
    begin: at_lv0_ins
        always @(posedge clk) begin
            if (reset) begin
                ofm0_lv3[20*i-1: 0] <= 0;
                ofm1_lv3[20*i-1: 0] <= 0;
            end else begin
                ofm0_lv3[20*i-1: 0] <= ofm0_lv2[2*i*19+:19] + ofm0_lv2[2*i*19+19+:19];
                ofm1_lv3[20*i-1: 0] <= ofm1_lv2[2*i*19+:19] + ofm1_lv2[2*i*19+19+:19];
            end
        end
    end
endgenerate

reg [21-1: 0] ofm0_lv4=0;
reg [21-1: 0] ofm1_lv4=0;
always @(posedge clk) begin
    if (reset) begin
        ofm0_lv4 <= 0;
        ofm1_lv4 <= 0;
    end else begin
        ofm0_lv4 <= ofm0_lv3[2*20+:20] + ofm0_lv3[2*20+20+:20];
        ofm1_lv4 <= ofm1_lv3[2*20+:20] + ofm1_lv3[2*20+20+:20];
    end
end

always @(posedge clk) begin
    if (reset) begin
        pe_ofm0_out <= 0;
        pe_ofm1_out <= 0;
    end else begin
        pe_ofm0_out <= ofm0_lv4;
        pe_ofm1_out <= ofm1_lv4;
    end
end

endmodule
