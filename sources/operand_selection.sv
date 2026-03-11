module operand_selection #(
    parameter QUIRE_WIDTH = 128,
    parameter SF_WIDTH    = 32
)(
    input  logic [QUIRE_WIDTH-1:0] quire_r,
    input  logic [SF_WIDTH-1:0]    sfq_r,

    input  logic [QUIRE_WIDTH-1:0] quire_c,
    input  logic [SF_WIDTH-1:0]    sfq_c,

    input  logic [2:0]             op,

    output logic [QUIRE_WIDTH-1:0] quire_s,
    output logic [SF_WIDTH-1:0]    sfq_s
);

always_comb begin

    case(op)

        // 0 : Vr = Va * Vb
        3'b000: begin
            quire_s = quire_c;
            sfq_s   = sfq_c;
        end

        // 1 : Vr = Va + Vc
        3'b001: begin
            quire_s = quire_c;
            sfq_s   = sfq_c;
        end

        // 2 : Vr = Va - Vc
        3'b010: begin
            quire_s = quire_c;
            sfq_s   = sfq_c;
        end

        // 3 : Vr = Va*Vb + Vc
        3'b011: begin
            quire_s = quire_c;
            sfq_s   = sfq_c;
        end

        // 4 : Vr = Va*Vb - Vc
        3'b100: begin
            quire_s = quire_c;
            sfq_s   = sfq_c;
        end

        // 5 : Vr += Va*Vb 
        3'b101: begin
            quire_s = quire_r;
            sfq_s   = sfq_r;
        end

        // 6 : Vr -= Va*Vb
        3'b110: begin
            quire_s = quire_r;
            sfq_s   = sfq_r;
        end

        default: begin
            quire_s = '0;
            sfq_s   = '0;
        end

    endcase

end

endmodule