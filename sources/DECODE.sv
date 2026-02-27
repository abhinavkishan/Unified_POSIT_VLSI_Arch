`timescale 1ns / 1ps

module DECODE (
    input  logic [31:0] V,
    input  logic [5:0]  ctrl,
    output logic [31:0] f,
    output logic [31:0] sf,
    output logic [3:0] s
);

    logic [15:0]        exp;
    logic [31:0]        fraction;
    logic signed [31:0] sf1;
    logic [31:0]        v2c;
    logic [31:0]        vi;
    logic [19:0]        zc;
    logic [31:0]        vrs;
    logic [31:0]        frapos;
    logic [31:0]        exppos;
    logic signed [19:0] k_out;
    logic signed [31:0] k_alignout;
    
    FieldExtract FE (
        .V(V),
        .pres(ctrl[5:4]),
        .exp(exp),
        .fraction(fraction)
    );

    VectorSubtract VS (
        .exp(exp),
        .pres(ctrl[5:4]),
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

    regimeShifter RS (
        .vin(v2c),
        .zero_count(zc),
        .p_m(ctrl[5:4]),
        .vout(vrs)
    );
    ExponentShifter ES(
       .vin(vrs),
       .es(ctrl[3:2]),
       .pres(ctrl[5:4]),
       .fraction(frapos),
       .exp(exppos)
    );
    vector_adder VA(
        .vin(v2c),
        .zero_count(zc),
        .p_m(ctrl[5:4]),
        .k_out(k_out)
    );
    k_align_shifter KAS(
        .k_in(k_out),
        .precision_mode(ctrl[5:4]),
        .es(ctrl[3:2]),
        .k_aligned(k_alignout)
    );
    logic signed [31:0] expadd;

    assign expadd = exppos+k_alignout;
    assign frapos[31] = 1'b1;
    assign s={V[31],V[23],V[15],V[7]};
    assign sf = ctrl[1] ? sf1 : expadd;
    assign f = ctrl[1] ? fraction : frapos;
    


endmodule