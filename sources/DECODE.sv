`timescale 1ns / 1ps

module DECODE (
    input  logic [31:0] V,
    input  logic [5:0]  ctrl,
    output logic [31:0] Vr
);

    logic [15:0]        exp;
    logic [31:0]        fraction;
    logic signed [31:0] sf1;
    logic [31:0]        v2c;
    logic [31:0]        vi;
    logic [19:0]        zc;
    logic [31:0]        vrs;

    FieldExtract FE (
        .V(V),
        .pres(ctrl[5:4]),
        .vec(ctrl[3]),
        .exp(exp),
        .fraction(fraction)
    );

    VectorSubtract VS (
        .exp(exp),
        .pres(ctrl[5:4]),
        .vec(ctrl[3]),
        .sf(sf1)
    );

    Vector2sComp V2C (
        .vin(V),
        .p_m(ctrl[5:4]),
        .vout(v2c)
    );

    vector_inverter vinv (
        .vin(v2c),
        .p_m(ctrl[5:4]),
        .vout(vi)
    );

    vector_lzc LZC (
        .vin(vi),
        .p_m(ctrl[5:4]),
        .zero_count(zc)
    );

    vector_regime_shifter RS (
        .vin(v2c),
        .zero_count(zc),
        .p_m(ctrl[5:4]),
        .vout(vrs)
    );

    assign Vr = vrs;

endmodule