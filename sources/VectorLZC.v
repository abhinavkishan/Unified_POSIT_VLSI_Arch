module vector_lzc (
    input  wire [31:0] vin,
    input  wire [1:0]  p_m, 
    output reg  [19:0] zero_count      
);

integer i, j;
reg [4:0] count;

always @(*) begin
    zero_count = 20'd0;

    case (p_m)

    2'b00: begin
        for (i = 0; i < 4; i = i + 1) begin
            count = 0;

            for (j = i*8 + 6; j >= i*8; j = j - 1) begin
                if (vin[j] == 0)
                    count = count + 1;
                else
                    j = i*8 - 1;
            end

            zero_count[i*5 +: 5] = count;
        end
    end

    2'b01: begin
        count = 0;
        for (j = 14; j >= 0; j = j - 1) begin
            if (vin[j] == 0)
                count = count + 1;
            else
                j = -1;
        end
        zero_count[4:0] = count;

        count = 0;
        for (j = 30; j >= 16; j = j - 1) begin
            if (vin[j] == 0)
                count = count + 1;
            else
                j = 15;
        end
        zero_count[9:5] = count;
    end

    2'b10: begin
        count = 0;
        for (j = 30; j >= 0; j = j - 1) begin
            if (vin[j] == 1'b0)
                count = count + 1;
            else
                j = -1; 
        end
        zero_count[4:0] = count;
    end

    default: zero_count = 0;

    endcase
end

endmodule