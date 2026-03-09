module quire_sign_vector (
    input  logic [63:0] fp,        
    input  logic [3:0]  sp,        
    input  logic        operation_sub,
    input  logic [1:0]  mode,      
    output logic signed [127:0] out
);

    always_comb begin
        out = '0;

        case (mode)

       
        2'b00: begin
            for (int i=0; i<4; i++) begin
                logic signed [15:0] prod;
                logic signed [31:0] ext32;
                logic negate;

                prod   = fp[i*16 +: 16];
                negate = sp[i] ^ operation_sub;

                ext32 = {{16{1'b0}}, prod};

                if (negate)
                    ext32 = -ext32;

                out[i*32 +: 32] = ext32;
            end
        end

      2'b01: begin
            for (int i=0; i<2; i++) begin
                logic signed [31:0] prod;
                logic signed [63:0] ext64;
                logic negate;

                prod   = fp[i*32 +: 32];
                negate = sp[i] ^ operation_sub;

                ext64 = {{32{1'b0}}, prod};

                if (negate)
                    ext64 = -ext64;

                out[i*64 +: 64] = ext64;
            end
        end

         2'b10: begin
            logic signed [63:0] prod;
            logic signed [127:0] ext128;
            logic negate;

            prod   = fp;
            negate = sp[0] ^ operation_sub;

            ext128 = {{64{1'b0}}, prod};

            if (negate)
                ext128 = -ext128;

            out = ext128;
        end

        endcase
    end

endmodule