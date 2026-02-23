`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2026 00:23:05
// Design Name: 
// Module Name: DECODE
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


module DECODE(
    input [31:0] V,
    input [5:0]ctrl,
    output [31:0] Vr

    );
    wire [15:0] exp;
    wire [31:0] fraction;
    wire signed [31:0] sf1;
    wire [31:0] v2c;
    wire [31:0] vi;
    FieldExtract FE(.V(V),.exp(exp),.fraction(fraction),.pres(ctrl[5:4]),.vec(ctrl[3]));
    VectorSubtract VS(.exp(exp),.pres(ctrl[5:4]),.vec(ctrl[3]),.sf(sf1));
    Vector2sComp V2C(.vin(V),.p_m(ctrl[5:4]),.vout(v2c));
    vector_inverter vinv(.vin(v2c),.p_m(ctrl[5:4]),.vout(vi));
endmodule
