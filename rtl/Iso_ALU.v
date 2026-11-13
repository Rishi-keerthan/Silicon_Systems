// 4-bit ALU ? with operand isolation
// When enable=0, inputs are forced to zero ? no switching inside ALU

module alu_isolated (
    input  [3:0] A,
    input  [3:0] B,
    input  [1:0] op,
    input        enable,   // 1 = ALU active, 0 = ALU idle
    output reg [4:0] Y
);

    // Isolated versions of A and B
    wire [3:0] A_iso;
    wire [3:0] B_iso;

    // When enable=0, clamp inputs to zero ? this is operand isolation
    assign A_iso = enable ? A : 4'b0000;
    assign B_iso = enable ? B : 4'b0000;

    always @(*) begin
        case (op)
            2'b00 : Y = A_iso + B_iso;
            2'b01 : Y = A_iso - B_iso;
            2'b10 : Y = A_iso & B_iso;
            2'b11 : Y = A_iso | B_iso;
            default: Y = 5'b0;
        endcase
    end

endmodule
