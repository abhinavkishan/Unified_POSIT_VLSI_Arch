`timescale 1ns / 1ps

module vector_lzc (
    input  logic [31:0] vin,
    input  logic [1:0]  p_m,
    output logic [19:0] zero_count
);
 int count = 0;
always_comb begin
    zero_count = '0;

    unique case (p_m)

    2'b00: begin
        for (int i = 0; i < 4; i++) begin
           count = 0;

            for (int j = i*8 + 6; j >= i*8; j--) begin
                if (vin[j] == 1'b0)
                    count++;
                else
                    break;
            end

            zero_count[i*5 +: 5] = count[4:0];
        end
    end

    2'b01: begin

        for (int j = 14; j >= 0; j--) begin
            if (vin[j] == 1'b0)
                count++;
            else
                break;
        end
        zero_count[4:0] = count[4:0];

        count = 0;
        for (int j = 30; j >= 16; j--) begin
            if (vin[j] == 1'b0)
                count++;
            else
                break;
        end
        zero_count[9:5] = count[4:0];
    end

    2'b10: begin

        for (int j = 30; j >= 0; j--) begin
            if (vin[j] == 1'b0)
                count++;
            else
                break;
        end
        zero_count[4:0] = count[4:0];
    end

    endcase
end

endmodule