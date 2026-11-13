`timescale 1ns/1ps

module LP_ALU_tb;

    // Inputs (shared for both ALUs)
    reg [3:0] A, B;
    reg [1:0] op;
    reg       enable;
    reg       clk;

    // Outputs
    wire [4:0] Y_normal;
    wire [4:0] Y_iso;

    // Instantiate normal ALU
    alu u_normal (
        .A(A), .B(B), .op(op),
        .Y(Y_normal)
    );

    // Instantiate isolated ALU
    alu_isolated u_iso (
        .A(A), .B(B), .op(op),
        .enable(enable),
        .Y(Y_iso)
    );

    // Clock: toggles every 5ns ? 100MHz
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
      #300;
      $stop;
    end
    // Variables to count transitions on output Y
    integer normal_toggles;
    integer iso_toggles;
    reg [4:0] prev_normal, prev_iso;

    initial begin
        // Initialize
        normal_toggles = 0;
        iso_toggles    = 0;
        A = 0; B = 0; op = 0; enable = 1;

        // ---- PHASE 1: ALU actively used (enable=1) ----
        // Both ALUs see real changing inputs
        #10; A = 4'b0011; B = 4'b0101; op = 2'b00; // ADD
        #10; A = 4'b1010; B = 4'b0011; op = 2'b01; // SUB
        #10; A = 4'b1111; B = 4'b1010; op = 2'b10; // AND
        #10; A = 4'b0110; B = 4'b1001; op = 2'b11; // OR
        #10; A = 4'b1100; B = 4'b0111; op = 2'b00;
        #10; A = 4'b0001; B = 4'b1110; op = 2'b01;
        #10; A = 4'b1011; B = 4'b0100; op = 2'b10;
        #10; A = 4'b0101; B = 4'b1010; op = 2'b11;

        // ---- PHASE 2: ALU idle (enable=0 for isolated, enable=1 for normal) ----
        // Normal ALU still switching; isolated ALU inputs clamped to 0
        enable = 0;   // isolated ALU goes quiet
        #10; A = 4'b1001; B = 4'b0110; op = 2'b00;
        #10; A = 4'b0111; B = 4'b1000; op = 2'b01;
        #10; A = 4'b1110; B = 4'b0001; op = 2'b10;
        #10; A = 4'b0010; B = 4'b1101; op = 2'b11;
        #10; A = 4'b1111; B = 4'b0000; op = 2'b00;
        #10; A = 4'b0100; B = 4'b1011; op = 2'b01;
        #10; A = 4'b1000; B = 4'b0111; op = 2'b10;
        #10; A = 4'b0011; B = 4'b1100; op = 2'b11;

        // Print results
        $display("=================================");
        $display("Normal ALU output transitions : %0d", normal_toggles);
        $display("Isolated ALU output transitions: %0d", iso_toggles);
        $display("Switching reduction            : %0d%%",
                 100 - (iso_toggles * 100 / (normal_toggles + 1)));
        $display("=================================");

        
    end

    // Count transitions on Y_normal
    initial prev_normal = 0;
    always @(Y_normal) begin
        if (Y_normal !== prev_normal) begin
            normal_toggles = normal_toggles + 1;
            prev_normal = Y_normal;
        end
    end

    // Count transitions on Y_iso
    initial prev_iso = 0;
    always @(Y_iso) begin
        if (Y_iso !== prev_iso) begin
            iso_toggles = iso_toggles + 1;
            prev_iso = Y_iso;
        end
    end

    // Dump waveforms for ModelSim
    initial begin
        $dumpfile("alu_compare.vcd");
        $dumpvars(0, LP_ALU_tb);
    end

endmodule
