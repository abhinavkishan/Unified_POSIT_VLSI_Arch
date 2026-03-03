module mult32_fraction_vector (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [1:0]  mode,   // 00=4x8, 01=2x16, 10=1x32
    output logic [63:0] P
);

    logic [7:0] A_blk [3:0];
    logic [7:0] B_blk [3:0];

    assign {A_blk[3],A_blk[2],A_blk[1],A_blk[0]} = A;
    assign {B_blk[3],B_blk[2],B_blk[1],B_blk[0]} = B;

    logic [15:0] P_blk [3:0][3:0];

    genvar i,j;
    generate
        for(i=0;i<4;i++) begin
            for(j=0;j<4;j++) begin
                booth8_radix4_unsigned u_mul (
                    .a(A_blk[i]),
                    .b(B_blk[j]),
                    .p(P_blk[i][j])
                );
            end
        end
    endgenerate

    logic [63:0] PP [15:0];

    generate
        for(i=0;i<4;i++) begin
            for(j=0;j<4;j++) begin
                assign PP[4*i+j] =
                    {48'd0, P_blk[i][j]} << (8*(i+j));
            end
        end
    endgenerate

    logic [63:0] s1[4:0], c1[4:0];
    logic [63:0] r1;

    csa3 s10(PP[0], PP[1], PP[2],  s1[0], c1[0]);
    csa3 s11(PP[3], PP[4], PP[5],  s1[1], c1[1]);
    csa3 s12(PP[6], PP[7], PP[8],  s1[2], c1[2]);
    csa3 s13(PP[9], PP[10],PP[11], s1[3], c1[3]);
    csa3 s14(PP[12],PP[13],PP[14], s1[4], c1[4]);

    assign r1 = PP[15];

    logic [63:0] s2[2:0], c2[2:0];
    logic [63:0] r2[1:0];

    csa3 s20(s1[0], c1[0], s1[1], s2[0], c2[0]);
    csa3 s21(c1[1], s1[2], c1[2], s2[1], c2[1]);
    csa3 s22(s1[3], c1[3], s1[4], s2[2], c2[2]);

    assign r2[0] = c1[4];
    assign r2[1] = r1;

    logic [63:0] s3[1:0], c3[1:0];
    logic [63:0] r3[1:0];

    csa3 s30(s2[0], c2[0], s2[1], s3[0], c3[0]);
    csa3 s31(c2[1], s2[2], c2[2], s3[1], c3[1]);

    assign r3[0] = r2[0];
    assign r3[1] = r2[1];

    logic [63:0] s4, c4;
    logic [63:0] r4[2:0];

    csa3 s40(s3[0], c3[0], s3[1], s4, c4);

    assign r4[0] = c3[1];
    assign r4[1] = r3[0];
    assign r4[2] = r3[1];

    logic [63:0] s5, c5;
    logic [63:0] r5;

    csa3 s50(s4, c4, r4[0], s5, c5);

    assign r5 = r4[1] + r4[2]; 

    logic [63:0] full32;

    assign full32 = s5 + c5 + r5;

    logic [63:0] simd16;

    always_comb begin
        logic [31:0] low16, high16;

        low16 =
            P_blk[0][0] +
            (P_blk[0][1] << 8) +
            (P_blk[1][0] << 8) +
            (P_blk[1][1] << 16);

        high16 =
            P_blk[2][2] +
            (P_blk[2][3] << 8) +
            (P_blk[3][2] << 8) +
            (P_blk[3][3] << 16);

        simd16 = {high16, low16};
    end

    logic [63:0] simd8;

    always_comb begin
        simd8 = {
            P_blk[3][3],
            P_blk[2][2],
            P_blk[1][1],
            P_blk[0][0]
        };
    end

 
    always_comb begin
        case(mode)
            2'b10: P = full32;
            2'b01: P = simd16;
            2'b00: P = simd8;
            default: P = 64'd0;
        endcase
    end

endmodule
module csa3 (
        input  logic [63:0] x,
        input  logic [63:0] y,
        input  logic [63:0] z,
        output logic [63:0] s,
        output logic [63:0] c
    );
        begin
            assign s = x ^ y ^ z;
            assign c = ((x & y) | (y & z) | (x & z)) << 1;
        end
    endmodule