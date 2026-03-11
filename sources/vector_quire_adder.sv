module vector_quire_adder #(
    parameter QUIRE_WIDTH = 128
)(
    input  logic [QUIRE_WIDTH-1:0] q1,
    input  logic [QUIRE_WIDTH-1:0] q0,
    input  logic [1:0]             pres,

    output logic [QUIRE_WIDTH-1:0] q_out
);

always_comb begin

    q_out = '0;

    case(pres)

        // 8-bit precision 
        2'b00: begin
            for(int i=0;i<4;i++) begin
                q_out[i*32 +: 32] =
                    $signed(q1[i*32 +: 32]) +
                    $signed(q0[i*32 +: 32]);
            end
        end

        // 16-bit precision 
        2'b01: begin
            for(int i=0;i<2;i++) begin
                q_out[i*64 +: 64] =
                    $signed(q1[i*64 +: 64]) +
                    $signed(q0[i*64 +: 64]);
            end
        end

        // 32-bit precision
        2'b10: begin
            q_out = $signed(q1) + $signed(q0);
        end

        default: q_out = '0;

    endcase

end

endmodule