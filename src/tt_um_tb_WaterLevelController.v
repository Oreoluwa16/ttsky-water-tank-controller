`timescale 1ns / 1ps

module tb_WaterLevelController();

    // Signals
    reg clk;
    reg reset_n;
    reg s1_high;
    reg s0_low;
    wire pump_out;

    // Instantiate UUT
    WaterLevelController uut (
        .clk(clk),
        .reset_n(reset_n),
        .s1_high(s1_high),
        .s0_low(s0_low),
        .pump_out(pump_out)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        reset_n = 0;
        s1_high = 0;
        s0_low = 0;

        // Reset system
        #15 reset_n = 1;
        $display("Reset released at %t", $time);

        // --- Scenario 1: Empty to Filling ---
        // Both sensors 0 -> should transition to FILLING
        #10;
        if (pump_out === 1) $display("[PASS] Pump started in FILLING state.");

        // --- Scenario 2: Middle Level ---
        // Water covers low sensor (s0=1) but not high (s1=0)
        #20 s0_low = 1; s1_high = 0;
        #10;
        if (pump_out === 1) $display("[PASS] Pump still running at mid-level.");

        // --- Scenario 3: Tank Full ---
        // Both sensors active
        #20 s0_low = 1; s1_high = 1;
        #10;
        if (pump_out === 0) $display("[PASS] Pump stopped in FULL state.");

        // --- Scenario 4: Error State ---
        // High sensor is wet but low is dry (Sensor Failure)
        #20 s1_high = 1; s0_low = 0;
        #10;
        // In your code, error_flag was intended, but let's check pump safety
        if (pump_out === 0) $display("[PASS] Safety check: Pump OFF in ERROR state.");

        // --- Scenario 5: Recovery ---
        #20 s1_high = 0; s0_low = 0;
        #20;
        $display("Simulation complete.");
        $finish;
    end

    initial begin
        $monitor("Time: %t | Sensors: %b%b | Pump: %b", $time, s1_high, s0_low, pump_out);
    end

endmodule
