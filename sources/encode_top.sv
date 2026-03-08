`timescale 1ns / 1ps

// =============================================================================
// ENCODE — Unified Posit / IEEE-754 Vector Encode Stage  (top-level mux)
//
// Pipeline stage 6 of the VMAC unit described in:
//   "Unified Posit/IEEE-754 Vector MAC Unit for Transprecision Computing"
//   Crespo et al., IEEE TCSII, Vol. 69, No. 5, May 2022  (Fig. 2, Fig. 3B)
//
// -----------------------------------------------------------------------------
// ARCHITECTURE OVERVIEW
// -----------------------------------------------------------------------------
//  The Encode stage (Fig. 3B) receives the normalised internal vector
//  {s, sf, f} from the Normalise stage and encodes it to either the
//  Posit or IEEE-754 output format, independently of the input format.
//  This enables the inter-format conversion described in Section III-A.5.
//
//  The module instantiates one IEEE encoder and one Posit encoder per
//  active SIMD lane, then muxes the correct output based on ctrl.
//
// -----------------------------------------------------------------------------
// CONTROL SIGNAL MAPPING  (identical convention to DECODE.sv)
// -----------------------------------------------------------------------------
//  ctrl[5:4]  pres   — precision / vector mode
//                        2'b10 : 1 × 32-bit  scalar
//                        2'b01 : 2 × 16-bit  SIMD
//                        2'b00 : 4 ×  8-bit  SIMD
//  ctrl[3:2]  es     — Posit runtime exponent size (Section III-A.3)
//                        Ignored for IEEE output lanes.
//  ctrl[1]    fmt    — output format:  1 = IEEE-754 ,  0 = Posit
//  ctrl[0]    unused / reserved
//
// -----------------------------------------------------------------------------
// INPUT BUSES  (unified internal format, paper Fig. 1C)
// -----------------------------------------------------------------------------
//  s   [3:0]  — per-lane sign bits.  Bit index = lane index (lane0=s[0]).
//  sf  [31:0] — packed signed scale factors, lane-width matches pres:
//                  pres=10 : sf[31:0]  = one 32-bit signed sf
//                  pres=01 : sf[31:16] = lane1 sf (signed 16-bit)
//                            sf[15:0]  = lane0 sf (signed 16-bit)
//                  pres=00 : sf[31:24..7:0] = lanes 3..0 (signed 8-bit each)
//  f   [31:0] — packed fractions, same lane packing as sf.
//                  MSB of each lane segment = implicit leading 1.
//                  Bits below that = fraction bits.
//                  Bits below the fraction field = rounding (guard/round) bits.
//  sticky_bits   [3:0] — per-lane accumulated sticky bit (lane0=bit0)
//  exception_bits[3:0] — per-lane exception flag: NaN (IEEE) / NaR (Posit)
//
// -----------------------------------------------------------------------------
// OUTPUT
// -----------------------------------------------------------------------------
//  Vr [31:0] — encoded result, lane-packed identically to the input buses:
//                  pres=10 : Vr[31:0]            = 32-bit result
//                  pres=01 : Vr[31:16]/Vr[15:0]  = lane1/lane0 (16-bit each)
//                  pres=00 : Vr[31:24..7:0]       = lanes 3..0 (8-bit each)
// =============================================================================

module ENCODE (
    input  logic        [3:0]  s,
    input  logic signed [31:0] sf,
    input  logic        [31:0] f,
    input  logic        [3:0]  sticky_bits,
    input  logic        [3:0]  exception_bits,
    input  logic        [5:0]  ctrl,

    output logic        [31:0] Vr
);

// ---------------------------------------------------------------------------
// 0. Unpack control fields
// ---------------------------------------------------------------------------
logic [1:0] pres;
logic [1:0] es;
logic       fmt;

assign pres = ctrl[5:4];
assign es   = ctrl[3:2];
assign fmt  = ctrl[1];   // 1 = IEEE-754,  0 = Posit

// ---------------------------------------------------------------------------
// 1. Unpack per-lane sign, sf, f from the packed input buses
//
//    All lanes are sign-extended to 32 bits so the encoding sub-modules,
//    which always take 32-bit sf/f, receive correctly sign-extended values.
//    Unused lanes are tied to zero.
// ---------------------------------------------------------------------------

// --- Signs ---
logic s_l0, s_l1, s_l2, s_l3;
assign s_l0 = s[0];
assign s_l1 = s[1];
assign s_l2 = s[2];
assign s_l3 = s[3];

// --- Scale factors (sign-extended to 32 bits) ---
logic signed [31:0] sf_l0, sf_l1, sf_l2, sf_l3;

always_comb begin
    sf_l0 = '0;  sf_l1 = '0;  sf_l2 = '0;  sf_l3 = '0;
    unique case (pres)
        2'b10: begin
            sf_l0 = sf;                             // full 32-bit sf
        end
        2'b01: begin
            sf_l0 = {{16{sf[15]}},  sf[15:0]};      // lane0: sign-extend 16→32
            sf_l1 = {{16{sf[31]}},  sf[31:16]};     // lane1: sign-extend 16→32
        end
        2'b00: begin
            sf_l0 = {{24{sf[7]}},   sf[7:0]};       // lane0: sign-extend  8→32
            sf_l1 = {{24{sf[15]}},  sf[15:8]};      // lane1
            sf_l2 = {{24{sf[23]}},  sf[23:16]};     // lane2
            sf_l3 = {{24{sf[31]}},  sf[31:24]};     // lane3
        end
        default: sf_l0 = sf;
    endcase
end

// --- Fractions
//    The encoding modules index f[31]=implicit-1, f[30:8]=mantissa, f[7:0]=round.
//    For narrower lanes the lane data is packed at the LSBs of f[].
//    We left-shift each lane to move its implicit-1 to f[31] so the
//    encoding modules always see the same bit layout regardless of pres.
//
//    Lane field widths (fraction bus, INCLUDING implicit-1 and round bits):
//      32-bit : uses all 32 bits of f  — no shift needed
//      16-bit : 16 bits per lane       — shift left by 16
//       8-bit :  8 bits per lane       — shift left by 24
// ---------------------------------------------------------------------------
logic [31:0] f_l0, f_l1, f_l2, f_l3;

always_comb begin
    f_l0 = '0;  f_l1 = '0;  f_l2 = '0;  f_l3 = '0;
    unique case (pres)
        2'b10: begin
            f_l0 = f;
        end
        2'b01: begin
            f_l0 = {f[15:0],  16'b0};           // lane0 → bits [31:16]
            f_l1 = {f[31:16], 16'b0};           // lane1 → bits [31:16]
        end
        2'b00: begin
            f_l0 = {f[7:0],   24'b0};           // lane0 → bits [31:24]
            f_l1 = {f[15:8],  24'b0};           // lane1
            f_l2 = {f[23:16], 24'b0};           // lane2
            f_l3 = {f[31:24], 24'b0};           // lane3
        end
        default: f_l0 = f;
    endcase
end

// ---------------------------------------------------------------------------
// 2. IEEE-754 encoder instances
//
//    One instance per lane, each parameterised with the correct BIAS
//    for its precision (paper Section II-A):
//       32-bit (1×1) → BIAS = 127
//       16-bit (2×1) → BIAS =  15
//        8-bit (4×1) → BIAS =   7   (4-bit exp, 3-bit mantissa minifloat)
//
//    All instances drive 32-bit output wires; the mux in section 4 extracts
//    only the relevant LSBs for narrower formats.
//    (For 32-bit output the full [31:0] is used; for 16-bit [15:0]; for 8-bit [7:0].)
// ---------------------------------------------------------------------------

// Lane 0 — always active
logic [31:0] ieee_l0;
encoding_ieee #(.BIAS(127)) u_ieee_l0 (
    .s             (s_l0),
    .sf            (sf_l0),
    .f             (f_l0),
    .sticky_bits   (sticky_bits[0]),
    .exception_bits(exception_bits[0]),
    .vr            (ieee_l0)
);

// Lane 1 — active for pres=01 (16-bit, BIAS=15) and pres=00 (8-bit, BIAS=7)
// Two separate instances cover both precision contexts; mux selects the right one.
logic [31:0] ieee_l1_16, ieee_l1_8;

encoding_ieee #(.BIAS(15)) u_ieee_l1_16 (
    .s             (s_l1),
    .sf            (sf_l1),
    .f             (f_l1),
    .sticky_bits   (sticky_bits[1]),
    .exception_bits(exception_bits[1]),
    .vr            (ieee_l1_16)
);

encoding_ieee #(.BIAS(7)) u_ieee_l1_8 (
    .s             (s_l1),
    .sf            (sf_l1),
    .f             (f_l1),
    .sticky_bits   (sticky_bits[1]),
    .exception_bits(exception_bits[1]),
    .vr            (ieee_l1_8)
);

// Lane 2 — active for pres=00 (8-bit only)
logic [31:0] ieee_l2_8;
encoding_ieee #(.BIAS(7)) u_ieee_l2_8 (
    .s             (s_l2),
    .sf            (sf_l2),
    .f             (f_l2),
    .sticky_bits   (sticky_bits[2]),
    .exception_bits(exception_bits[2]),
    .vr            (ieee_l2_8)
);

// Lane 3 — active for pres=00 (8-bit only)
logic [31:0] ieee_l3_8;
encoding_ieee #(.BIAS(7)) u_ieee_l3_8 (
    .s             (s_l3),
    .sf            (sf_l3),
    .f             (f_l3),
    .sticky_bits   (sticky_bits[3]),
    .exception_bits(exception_bits[3]),
    .vr            (ieee_l3_8)
);

// ---------------------------------------------------------------------------
// 3. Posit encoder instances
//
//    Parameterised with N and ES per lane precision (paper Section II-B,
//    Section III-A.3).  The runtime-configurable exponent size (es from ctrl)
//    is already baked into sf by the KAlignShifter / ExponentShifter in the
//    Decode stage, so ES is fixed at synthesis but sf encodes the correct
//    dynamic range at runtime.
//
//    For the 8-bit quire path, ES=2 is the standard (paper Section III-A.1).
//    16-bit and 32-bit lanes also default to ES=2; a future revision can
//    expose ES as a port if per-lane runtime reconfiguration is needed.
// ---------------------------------------------------------------------------

// Lane 0 — 32-bit posit
logic [31:0] posit_l0_32;
posit_encoding #(.N(32), .ES(2)) u_posit_l0_32 (
    .s             (s_l0),
    .sf            (sf_l0),
    .f             (f_l0),
    .sticky_bits   (sticky_bits[0]),
    .exception_bits(exception_bits[0]),
    .vr            (posit_l0_32)
);

// Lane 0 — 16-bit posit (used when pres=01, lane0)
logic [15:0] posit_l0_16;
posit_encoding #(.N(16), .ES(2)) u_posit_l0_16 (
    .s             (s_l0),
    .sf            (sf_l0),
    .f             (f_l0),
    .sticky_bits   (sticky_bits[0]),
    .exception_bits(exception_bits[0]),
    .vr            (posit_l0_16)
);

// Lane 0 — 8-bit posit (used when pres=00, lane0)
logic [7:0] posit_l0_8;
posit_encoding #(.N(8), .ES(2)) u_posit_l0_8 (
    .s             (s_l0),
    .sf            (sf_l0),
    .f             (f_l0),
    .sticky_bits   (sticky_bits[0]),
    .exception_bits(exception_bits[0]),
    .vr            (posit_l0_8)
);

// Lane 1 — 16-bit posit
logic [15:0] posit_l1_16;
posit_encoding #(.N(16), .ES(2)) u_posit_l1_16 (
    .s             (s_l1),
    .sf            (sf_l1),
    .f             (f_l1),
    .sticky_bits   (sticky_bits[1]),
    .exception_bits(exception_bits[1]),
    .vr            (posit_l1_16)
);

// Lane 1 — 8-bit posit
logic [7:0] posit_l1_8;
posit_encoding #(.N(8), .ES(2)) u_posit_l1_8 (
    .s             (s_l1),
    .sf            (sf_l1),
    .f             (f_l1),
    .sticky_bits   (sticky_bits[1]),
    .exception_bits(exception_bits[1]),
    .vr            (posit_l1_8)
);

// Lane 2 — 8-bit posit
logic [7:0] posit_l2_8;
posit_encoding #(.N(8), .ES(2)) u_posit_l2_8 (
    .s             (s_l2),
    .sf            (sf_l2),
    .f             (f_l2),
    .sticky_bits   (sticky_bits[2]),
    .exception_bits(exception_bits[2]),
    .vr            (posit_l2_8)
);

// Lane 3 — 8-bit posit
logic [7:0] posit_l3_8;
posit_encoding #(.N(8), .ES(2)) u_posit_l3_8 (
    .s             (s_l3),
    .sf            (sf_l3),
    .f             (f_l3),
    .sticky_bits   (sticky_bits[3]),
    .exception_bits(exception_bits[3]),
    .vr            (posit_l3_8)
);

// ---------------------------------------------------------------------------
// 4. Output mux
//
//    Two-level selection (paper Fig. 3B):
//      Level 1 — pres selects the precision / SIMD width
//      Level 2 — fmt  selects Posit vs. IEEE-754 output
//
//    Lane packing of Vr mirrors the input bus convention and the packing
//    used by FieldExtract.sv / DECODE.sv so the rest of the pipeline sees
//    a uniform interface regardless of format or precision.
// ---------------------------------------------------------------------------

always_comb begin
    Vr = '0;

    unique case (pres)

        // ------------------------------------------------------------------
        // 1 × 32-bit scalar
        // ------------------------------------------------------------------
        2'b10: begin
            Vr = fmt ? ieee_l0          // IEEE-754 single precision  (32-bit)
                     : posit_l0_32;     // Posit-32
        end

        // ------------------------------------------------------------------
        // 2 × 16-bit SIMD
        //   Vr[31:16] = lane1,  Vr[15:0] = lane0
        // ------------------------------------------------------------------
        2'b01: begin
            if (fmt) begin
                // IEEE-754 half precision (16-bit: 1s + 5exp + 10mant)
                // encoding_ieee with BIAS=15 assembles the 16-bit result in
                // bits [15:0] of its 32-bit output (sign at [15], 5-bit exp
                // at [14:10], 10-bit mantissa at [9:0]).
                Vr = {ieee_l1_16[15:0],     // lane1
                      ieee_l0[15:0]};        // lane0
            end else begin
                // Posit-16
                Vr = {posit_l1_16,           // lane1  [31:16]
                      posit_l0_16};          // lane0  [15:0]
            end
        end

        // ------------------------------------------------------------------
        // 4 × 8-bit SIMD
        //   Vr[31:24]=lane3, Vr[23:16]=lane2, Vr[15:8]=lane1, Vr[7:0]=lane0
        // ------------------------------------------------------------------
        2'b00: begin
            if (fmt) begin
                // IEEE-754 minifloat (8-bit: 1s + 4exp + 3mant, BIAS=7)
                // encoding_ieee with BIAS=7 assembles the 8-bit result in
                // bits [7:0] of its 32-bit output.
                Vr = {ieee_l3_8[7:0],        // lane3
                      ieee_l2_8[7:0],        // lane2
                      ieee_l1_8[7:0],        // lane1
                      ieee_l0[7:0]};         // lane0
            end else begin
                // Posit-8
                Vr = {posit_l3_8,            // lane3
                      posit_l2_8,            // lane2
                      posit_l1_8,            // lane1
                      posit_l0_8};           // lane0
            end
        end

        default: Vr = '0;

    endcase
end

endmodule
