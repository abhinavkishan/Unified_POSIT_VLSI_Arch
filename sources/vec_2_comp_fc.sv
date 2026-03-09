module quire_sign_from_32 (
    input  logic [31:0] in_val,     
    input  logic [3:0]  sign_vec,   
    input  logic        operation_sub,
    input  logic [1:0]  mode,       
    output logic signed [127:0] out
);

    always_comb begin
        out = '0;

        case (mode)

       2'b00: begin
            for (int i=0; i<4; i++) begin
                logic signed [7:0]  lane;
                logic signed [31:0] lane_ext;
                logic negate;

                lane   = in_val[i*8 +: 8];
                negate = sign_vec[i] ^ operation_sub;

                lane_ext = {{24{1'b0}}, lane};

                if (negate)
                    lane_ext = -lane_ext;

                out[i*32 +: 32] = lane_ext;
            end
        end

        2'b01: begin
            for (int i=0; i<2; i++) begin
                logic signed [15:0] lane;
                logic signed [63:0] lane_ext;
                logic negate;

                lane   = in_val[i*16 +: 16];
                negate = sign_vec[i] ^ operation_sub;

                lane_ext = {{48{1'b0}}, lane};

                if (negate)
                    lane_ext = -lane_ext;

                out[i*64 +: 64] = lane_ext;
            end
        end

        2'b10: begin
            logic signed [31:0] lane;
            logic signed [127:0] lane_ext;
            logic negate;

            lane   = in_val;
            negate = sign_vec[0] ^ operation_sub;

            lane_ext = {{96{1'b0}}, lane};

            if (negate)
                lane_ext = -lane_ext;

            out = lane_ext;
        end

        endcase
    end

endmodule