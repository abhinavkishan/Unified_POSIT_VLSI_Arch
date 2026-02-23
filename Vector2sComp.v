`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2026 17:00:30
// Design Name: 
// Module Name: Vector2sComp
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


module Vector2sComp(
    input  wire [31:0] vin,
    input  wire [1:0]  p_m,
    output wire [31:0] vout
);

always @(*) begin
    case (p_m)

    2'b00: begin
        integer i;
        for (i = 0; i < 4; i = i + 1) begin
            if (vin[i*8 + 7])
                vout[i*8 +: 8] = (~vin[i*8 +: 8]) + 8'd1;
            else
                vout[i*8 +: 8] = vin[i*8 +: 8];
        end
    end

    2'b01: begin
        if (vin[15])
            vout[15:0] = (~vin[15:0]) + 16'd1;
        else
            vout[15:0] = vin[15:0];

        if (vin[31])
            vout[31:16] = (~vin[31:16]) + 16'd1;
        else
            vout[31:16] = vin[31:16];
    end

    2'b10: begin
        if (vin[31])                 
            vout = (~vin) + 32'd1;
        else
            vout = vin;
    end

    default: vout = vin;

    endcase
end

endmodule
