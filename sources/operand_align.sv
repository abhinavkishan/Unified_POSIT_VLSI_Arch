module operand_align #(
    parameter QUIRE_WIDTH = 128,
    parameter SF_WIDTH    = 32
)(
    input  logic [QUIRE_WIDTH-1:0] quire_p,
    input  logic [SF_WIDTH-1:0]    sfq_p,

    input  logic [QUIRE_WIDTH-1:0] quire_s,
    input  logic [SF_WIDTH-1:0]    sfq_s,

    input  logic [3:0]             cmp,
    input  logic [1:0]             pres,

    output logic [QUIRE_WIDTH-1:0] q1,
    output logic [QUIRE_WIDTH-1:0] q0,
    output logic [3:0]             sticky,
    output logic [SF_WIDTH-1:0]    sfq_new
);

logic signed [7:0] shift;

always_comb begin

    q1 = '0;
    q0 = '0;
    sfq_new = '0;

    case(pres)

        // 8-bit precision 
        2'b00: begin
            for(int i=0;i<4;i++) begin

                logic signed [7:0] sp = sfq_p[i*8 +: 8];
                logic signed [7:0] ss = sfq_s[i*8 +: 8];

                shift = sp - ss;

                if(cmp[i]) begin
                    q1[i*32 +: 32] = quire_p[i*32 +: 32];
                    q0[i*32 +: 32] = quire_s[i*32 +: 32] >> shift;
                    sticky[i] = |(quire_s[i*32 +: 32] & ((1<<shift)-1));
                    sfq_new[i*8 +: 8] = sp;
                end
                else begin
                    q1[i*32 +: 32] = quire_s[i*32 +: 32];
                    q0[i*32 +: 32] = quire_p[i*32 +: 32] >> (-shift);
                    sticky[i] = |(quire_p[i*32 +: 32] & ((1<<(-shift))-1));
                    sfq_new[i*8 +: 8] = ss;
                end

            end
        end

        // 16-bit precision 
        2'b01: begin
            for(int i=0;i<2;i++) begin

                logic signed [15:0] sp = sfq_p[i*16 +: 16];
                logic signed [15:0] ss = sfq_s[i*16 +: 16];

                shift = sp - ss;

                if(cmp[i*2]) begin
                    q1[i*64 +: 64] = quire_p[i*64 +: 64];
                    q0[i*64 +: 64] = quire_s[i*64 +: 64] >> shift;
                    sticky[i*2] = |(quire_s[i*64 +: 64] & ((1<<shift)-1));
                    sfq_new[i*16 +: 16] = sp;
                end
                else begin
                    q1[i*64 +: 64] = quire_s[i*64 +: 64];
                    q0[i*64 +: 64] = quire_p[i*64 +: 64] >> (-shift);
                    sticky[i*2] = |(quire_p[i*64 +: 64] & ((1<<(-shift))-1));
                    sfq_new[i*16 +: 16] = ss;
                end

            end
        end

        // 32-bit precision 
        2'b10: begin

            logic signed [31:0] sp = sfq_p;
            logic signed [31:0] ss = sfq_s;

            shift = sp - ss;

            if(cmp[0]) begin
                q1 = quire_p;
                q0 = quire_s >> shift;
                sticky[0] = |(quire_s & ((1<<shift)-1));
                sfq_new = sp;
            end
            else begin
                q1 = quire_s;
                q0 = quire_p >> (-shift);
                sticky[0] = |(quire_p & ((1<<(-shift))-1));
                sfq_new = ss;
            end

        end

    endcase

end

endmodule