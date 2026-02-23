`timescale 1ns/1ps

module tb;

logic [31:0] V;
logic [5:0]  ctrl;
logic [31:0] Vr;

DECODE uut (
    .V(V),
    .ctrl(ctrl),
    .Vr(Vr)
);

initial begin
    $display("===== DECODE TEST START =====");

    ctrl = 6'b10_0_000;
    V    = 32'h41200000;
    #10;
    $display("32-bit scalar: V=%h Vr=%h", V, Vr);

    ctrl = 6'b01_1_000;
    V    = 32'h1234ABCD;
    #10;
    $display("16-bit vector: V=%h Vr=%h", V, Vr);

    ctrl = 6'b00_1_000;
    V    = 32'hA1B2C3D4;
    #10;
    $display("8-bit vector: V=%h Vr=%h", V, Vr);

    $display("===== TEST COMPLETE =====");
    $finish;
end

endmodule