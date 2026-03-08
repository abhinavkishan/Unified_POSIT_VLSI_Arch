module encoding_ieee
(
    input  logic              s,
    input  logic signed [31:0] sf,
    input  logic        [31:0] f,       // f[31] = implicit 1, f[30:8] = mantissa bits, f[7:0] = round bits
    input  logic               sticky_bits,
    input  logic               exception_bits,

    output logic [31:0] vr
);

parameter BIAS = 127;

// Use 9-bit exp to safely detect overflow (>= 0xFF) and underflow (<= 0)
logic signed [8:0] biased_exp;
logic        [7:0] exp_out;
logic       [22:0] mantissa;
logic       [23:0] mantissa_rounded; // 24-bit to catch carry-out

logic guard_bit;
logic round_b;
logic sticky;

// Subnormal shift amount: how far below 1 the exponent is
logic [7:0] sub_shift;

always_comb begin

    // ----------------------------------------------------------------
    // Step 1: Compute biased exponent (9-bit to detect out-of-range)
    // ----------------------------------------------------------------
    biased_exp = sf + BIAS;

    // ----------------------------------------------------------------
    // Step 2: Extract mantissa (bits [30:8] of f) and rounding bits
    //   f layout (per paper's unified internal format):
    //     f[31]    = implicit leading 1 (not stored in IEEE output)
    //     f[30:8]  = 23 fractional bits -> mantissa field
    //     f[7]     = guard bit
    //     f[6]     = round bit
    //     f[5:0]   = extra sticky bits
    // ----------------------------------------------------------------
    mantissa  = f[30:8];
    guard_bit = f[7];
    round_b   = f[6];
    sticky    = |f[5:0] | sticky_bits;

    // ----------------------------------------------------------------
    // Step 3: Handle SUBNORMAL numbers (biased_exp <= 0)
    //   Right-shift mantissa by (1 - biased_exp) positions so that
    //   the implicit leading 1 is shifted into the mantissa field.
    //   Clamp shift to 24 to avoid shifting everything out.
    // ----------------------------------------------------------------
    if (biased_exp <= 0) begin
        // How many extra positions to shift right
        sub_shift = ((-biased_exp) >= 8'd23) ? 8'd24 : 8'(1 - biased_exp);

        // Include implicit leading 1 in the full 24-bit mantissa, then shift
        // Rounding bits are carried along: use concatenated value
        // For simplicity we shift the 24-bit {1,mantissa} right
        {mantissa, guard_bit} = {1'b1, f[30:8], f[7]} >> sub_shift;
        round_b = (sub_shift > 0) ? f[6] : round_b; // simplified: sticky absorbs lower bits
        sticky  = sticky | (sub_shift > 1 ? |({1'b1, f[30:8]} << (25 - sub_shift)) : 1'b0);
        biased_exp = 0;
    end

    // ----------------------------------------------------------------
    // Step 4: Round to Nearest Even (RNE)
    //   Increment mantissa if: guard AND (round OR sticky OR lsb)
    // ----------------------------------------------------------------
    mantissa_rounded = {1'b0, mantissa};
    if (guard_bit && (round_b || sticky || mantissa[0])) begin
        mantissa_rounded = {1'b0, mantissa} + 24'd1;
    end

    // Carry-out from rounding increments exponent
    if (mantissa_rounded[23]) begin
        mantissa_rounded[22:0] = 23'd0;
        biased_exp = biased_exp + 9'd1;
    end

    // ----------------------------------------------------------------
    // Step 5: Overflow -> Infinity
    // ----------------------------------------------------------------
    if (biased_exp >= 9'h0FF) begin
        biased_exp            = 9'h0FF;
        mantissa_rounded[22:0] = 23'd0;
    end

    exp_out  = biased_exp[7:0];
    mantissa = mantissa_rounded[22:0];

    // ----------------------------------------------------------------
    // Step 6: Exception (NaN) overrides everything
    //   Canonical quiet NaN: exp=0xFF, mantissa MSB=1
    // ----------------------------------------------------------------
    if (exception_bits) begin
        exp_out  = 8'hFF;
        mantissa = 23'h400000;
    end

    // ----------------------------------------------------------------
    // Step 7: Assemble output
    // ----------------------------------------------------------------
    vr = {s, exp_out, mantissa};

end

endmodule
