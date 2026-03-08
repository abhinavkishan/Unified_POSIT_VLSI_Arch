module posit_encoding
(
    input  logic               s,
    input  logic signed [31:0] sf,
    input  logic        [31:0] f,        // f[31]=implicit 1, f[30:0]=fraction bits
    input  logic               sticky_bits,
    input  logic               exception_bits,

    output logic [N-1:0] vr
);

parameter N  = 8;
parameter ES = 2;

// ----------------------------------------------------------------
// Internal signals
// ----------------------------------------------------------------
logic signed [31:0] k_full;       // regime value (signed)
logic signed [7:0]  k;            // clamped to [-N+1, N-2]
logic [ES-1:0]      exp_bits;     // lower ES bits of sf
logic [2*N-1:0]     temp;         // working buffer (2x wide)
logic [N-1:0]       result;       // truncated N-bit result

logic guard_bit, round_b, sticky;

// Regime field assembled as a 2*N-bit value (MSB-justified)
logic [2*N-1:0] regime_field;
integer regime_len;   // total bits consumed by regime (run + terminator)

always_comb begin

    // ----------------------------------------------------------------
    // Step 1: Derive k and exp from sf
    //   sf = k * 2^ES + exp   (arithmetic right-shift gives k)
    // ----------------------------------------------------------------
    k_full   = sf >>> ES;                    // arithmetic shift
    exp_bits = sf[ES-1:0];                   // lower ES bits

    // Clamp k: regime can represent k in [-(N-2), N-2]
    // (N-1 ones uses all bits for regime, leaving no room for terminator
    //  or exponent; so effective range is -(N-2) to (N-2))
    if (k_full > (N-2))
        k = N-2;
    else if (k_full < -(N-2))
        k = -(N-2);
    else
        k = k_full[7:0];

    // ----------------------------------------------------------------
    // Step 2: Generate regime in MSB-justified position within temp
    //   Positive k: (k+1) ones then a zero  -> run length = k+2 bits
    //   Negative k: |k| zeros then a one    -> run length = |k|+1 bits
    //
    //   We build the regime as a 2*N wide field, MSB first, so that
    //   concatenating exp+fraction below falls naturally.
    // ----------------------------------------------------------------
    regime_field = '0;

    if (k >= 0) begin
        // (k+1) ones, one zero, rest zero
        // e.g. k=0 -> "10", k=1 -> "110", k=2 -> "1110"
        regime_len = k + 2;                          // total regime bits
        // Shift a run of (k+1) ones to MSB of 2*N field, then add 0 terminator
        regime_field = ({2*N{1'b1}} << (2*N - k - 1)) & ~({2*N{1'b1}} >> (k+1));
        // terminator '0' is already 0 from initialisation
    end else begin
        // |k| zeros, one '1', rest zero
        // e.g. k=-1 -> "01", k=-2 -> "001"
        regime_len = (-k) + 1;
        // Place single '1' at position (2*N-1 - |k|) from MSB
        regime_field = (2*N)'(1'b1) << (2*N - 1 + k);  // k is negative
    end

    // ----------------------------------------------------------------
    // Step 3: Pack  [regime | exp | fraction]  into temp (2*N wide)
    //   After regime_len bits, insert ES exp bits, then fraction bits.
    //   We do this by OR-ing shifted fields.
    // ----------------------------------------------------------------
    begin
        // exp field: shifted to start right after regime
        automatic logic [2*N-1:0] exp_field;
        automatic logic [2*N-1:0] frac_field;
        automatic integer exp_offset;   // bit position from MSB where exp starts
        automatic integer frac_offset;

        exp_offset  = regime_len;
        frac_offset = regime_len + ES;

        exp_field  = ({2*N{1'b0}} | {{(2*N-ES){1'b0}}, exp_bits}) << (2*N - frac_offset);
        frac_field = ({2*N{1'b0}} | {{(2*N-30){1'b0}}, f[29:0]}) << (2*N - frac_offset - 30);

        temp = regime_field | exp_field | frac_field;
    end

    // ----------------------------------------------------------------
    // Step 4: Extract N-bit result and rounding bits from temp
    //   temp[2*N-1 : N] = result
    //   temp[N-1]       = guard bit
    //   temp[N-2]       = round bit
    //   temp[N-3:0]     = sticky bits
    // ----------------------------------------------------------------
    result    = temp[2*N-1 : N];
    guard_bit = temp[N-1];
    round_b   = temp[N-2];
    sticky    = |temp[N-3:0] | sticky_bits;

    // ----------------------------------------------------------------
    // Step 5: Round to Nearest Even
    // ----------------------------------------------------------------
    if (guard_bit && (round_b || sticky || result[0]))
        result = result + 1;

    // ----------------------------------------------------------------
    // Step 6: Handle special cases
    // ----------------------------------------------------------------

    // NaR (Not-a-Real): MSB=1, rest 0  [paper Section II-B]
    if (exception_bits) begin
        vr = {1'b1, {(N-1){1'b0}}};
    end
    // Zero: all bits zero (sign does not apply)
    else if (sf == 0 && f == 0) begin
        vr = {N{1'b0}};
    end
    // Negative posit: take 2's complement of the encoded magnitude
    else if (s) begin
        vr = (~result) + 1;
    end
    else begin
        vr = result;
    end

end

endmodule
