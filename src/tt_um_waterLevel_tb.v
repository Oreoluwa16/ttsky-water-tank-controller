`timescale 1ns / 1ps

module tt_um_waterLevel_tb;

    // 1. Inputs (Registers) and Outputs (Wires)
    reg clk;
    reg reset_n;
    reg s1_high;
    reg s0_low;
    wire pump;
    wire error_flag;

    // 2. Instantiate the Unit Under Test (UUT)
    WaterLevelController_Structural uut (
        .clk(clk),
        .reset_n(reset_n),
        .s1_high(s1_high),
        .s0_low(s0_low),
        .pump_out(pump),

    );

    // 3. Clock Generation (100MHz / 10ns period)
    always #5 clk = ~clk;

    // 4. Stimulus Process
    initial begin
        // Initialize Inputs
        clk = 0;
        reset_n = 0;
        s1_high = 0;
        s0_low = 0;

        // Release Reset after 20ns
        #20 reset_n = 1;
        
        // --- Scenario 1: Tank is Empty ---
        // Both sensors 0. Pump should turn ON.
        #20; 
        
        // --- Scenario 2: Filling Up ---
        // Water hits bottom sensor (S0=1)
        #20 s0_low = 1; 
        // Pump should remain ON (FILLING state)
        
        // --- Scenario 3: Tank becomes Full ---
        // Water hits top sensor (S1=1)
        #20 s1_high = 1;
        // Pump should turn OFF (FULL state)

        // --- Scenario 4: Draining Phase ---
        // Water level drops below top sensor (S1=0)
        #20 s1_high = 0;
        // Pump should remain OFF (DRAINING state) - THIS IS THE TEST FOR HYSTERESIS

        // --- Scenario 5: Back to Empty ---
        // Water level drops below bottom sensor (S0=0)
        #20 s0_low = 0;
        // Pump should turn back ON

        // --- Scenario 6: Error Condition ---
        #40 s1_high = 1; s0_low = 0; // Impossible state
        #20;

        #100 $finish; // End simulation
    end

    // 5. Monitor the results in the console
    initial begin
        $monitor("Time=%0t | Sensors={%b%b} | State=%b | Pump=%b | Error=%b", 
                 $time, s1_high, s0_low, uut.q1, uut.q0, pump, error_flag);
    end

endmodule
