`timescale 1ns/1ps

module tb;

reg  [31:0] V;
reg  [5:0]  ctrl;
wire [31:0] Vr;

// Instantiate DUT
DECODE uut (
    .V(V),
    .ctrl(ctrl),
    .Vr(Vr)
);

initial begin

    $display("===== DECODE TEST START =====");

    // ---------------------------
    // 32-bit scalar test
    // pres = 2'b10
    // vec  = 0
    // ctrl[5:4] = pres
    // ctrl[3]   = vec
    // ---------------------------
    ctrl = 6'b10_0_000;  
    V    = 32'h41200000;  // Example FP32 value
    #10;
    $display("32-bit scalar: V=%h Vr=%h", V, Vr);

    // ---------------------------
    // 16-bit vector test
    // pres = 2'b01
    // vec  = 1
    // ---------------------------
    ctrl = 6'b01_1_000;
    V    = 32'h1234ABCD;
    #10;
    $display("16-bit vector: V=%h Vr=%h", V, Vr);

    // ---------------------------
    // 8-bit vector test
    // pres = 2'b00
    // vec  = 1
    // ---------------------------
    ctrl = 6'b00_1_000;
    V    = 32'hA1B2C3D4;
    #10;
    $display("8-bit vector: V=%h Vr=%h", V, Vr);

    $display("===== TEST COMPLETE =====");
    $stop;

end

endmodule