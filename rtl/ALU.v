// 4-bit ALU ? normal version, no isolation
// Operations: ADD, SUB, AND, OR selected by 2-bit opcode

module alu (
    input  [3:0] A,       
    input  [3:0] B,       
    input  [1:0] op,     
    output reg [4:0] Y    
);

    always @(*) begin
        case (op)
            2'b00 : Y = A + B;  
            2'b01 : Y = A - B;   
            2'b10 : Y = A & B;   
            2'b11 : Y = A | B;   
            default: Y = 5'b0;
        endcase
    end

endmodule
