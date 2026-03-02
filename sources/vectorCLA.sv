module vector_sf_adder #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [1:0]       p_m,   
    output logic [WIDTH-1:0] sum
);

logic [WIDTH-1:0] P, G;
logic [WIDTH:0]   C;

assign P = a ^ b;
assign G = a & b;

always_comb begin
    C = '0;

    for (int i = 0; i < WIDTH; i++) begin
        case (p_m)
            2'b00: begin
                if (i % 8 == 0)
                    C[i] = 1'b0;
            end

            2'b01: begin
                if (i == 16)
                    C[i] = 1'b0;
            end

            2'b10: begin
                // nothing
            end
        endcase

        C[i+1] = G[i] | (P[i] & C[i]);

        sum[i] = P[i] ^ C[i];
    end
end

endmodule