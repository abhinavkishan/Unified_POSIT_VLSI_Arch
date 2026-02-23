module k_align_shifter (
    input  wire signed [19:0] k_in,   
    input  wire [1:0] precision_mode,
    input  wire [1:0] es,             
    output reg  signed [19:0] k_aligned
);

integer i;
reg signed [4:0] k_lane;

always @(*) begin
    k_aligned = 20'd0;

    case (precision_mode)
        2'b00: begin
            for (i = 0; i < 4; i = i + 1) begin
                k_lane = k_in[i*5 +: 5];
                k_aligned[i*5 +: 5] = k_lane <<< es;
            end
        end

        2'b01: begin
            k_lane = k_in[4:0];
            k_aligned[4:0] = k_lane <<< es;

            k_lane = k_in[9:5];
            k_aligned[9:5] = k_lane <<< es;
        end

        2'b10: begin
            k_lane = k_in[4:0];
            k_aligned[4:0] = k_lane <<< es;
        end

        default: k_aligned = 20'd0;

    endcase
end

endmodule