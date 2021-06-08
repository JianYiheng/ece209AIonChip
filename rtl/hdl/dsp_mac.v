`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2021 06:57:18 AM
// Design Name: 
// Module Name: dsp_mac
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dsp_mac(
    output signed [47: 0] P,
    
    input signed [24: 0] A,
    input signed [17: 0] B,
    input signed [47: 0] C,
    input signed [24: 0] D,
    
    input CLK,
    input SCLR
    );

    reg signed [24: 0] A_s;
    reg signed [17: 0] B_s, B_s1;
    reg signed [47: 0] C_s, C_s1, C_s2;
    reg signed [24: 0] D_s;

    reg signed [25: 0] dsp_inter_0;
    reg signed [43: 0] dsp_inter_1;
    reg signed [47: 0] dsp_out;

    always @(posedge CLK) begin
        A_s <= A;
        B_s <= B;
        C_s <= C;
        D_s <= D;
        B_s1 <= B_s;
        C_s1 <= C_s;
        C_s2 <= C_s1;
    end
    
    always @(posedge CLK) begin
        if (SCLR) begin
            dsp_inter_0 <= 0;
            dsp_inter_1 <= 0;
            dsp_out <= 0;
        end else begin
            dsp_inter_0 <= A_s + D_s;
            dsp_inter_1 <= dsp_inter_0 * B_s1;
            dsp_out <= dsp_inter_1 + C_s2;
        end
    end
    
    assign P = dsp_out;
endmodule
