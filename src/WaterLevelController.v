/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
module WaterLevelController (
    input wire clk,           // System clock
    input wire reset_n,       // Active-low asynchronous reset
    input wire s1_high,       // High-level sensor (Bit 1)
    input wire s0_low,        // Low-level sensor (Bit 0)
    output reg pump_out      // Pump control signal
    
);

    // State definitions
    parameter IDLE     = 2'b00;
    parameter FILLING  = 2'b01;
    parameter FULL     = 2'b10;
    parameter ERROR    = 2'b11;

    reg [1:0] current_state, next_state;
    
    // Bundled sensor variable
    // Binary map: 2'b11 (Full), 2'b01 (Middle), 2'b00 (Empty), 2'b10 (Error)
    wire [1:0] sensor_bus = {s1_high, s0_low};

    // Sequential Logic: State Transitions
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Combinational Logic: Next State and Output
    always @(*) begin
        // Default assignments
        next_state = current_state;
        pump_out = 1'b0;
        error_flag = 1'b0;

        case (current_state)
            IDLE: begin
                pump_out = 1'b0;
                if (sensor_bus == 2'b00) next_state = FILLING;
                else  next_state = IDLE;
            end

            FILLING: begin
                pump_out = 1'b1;
                if (sensor_bus == 2'b11) next_state = FULL;
                else if (sensor_bus == 2'b10) next_state = ERROR; // Impossible state
                else next_state = FILLING; // Continue filling
            end

            FULL: begin
                pump_out = 1'b0;
                if (sensor_bus == 2'b10) next_state = ERROR;  // Impossible state
                else next_state = IDLE; // Continue full
            end

            ERROR: begin
                pump_out = 1'b0;
                error_flag = 1'b1;  // Safety Override: Catch impossible sensor state (High wet, Low dry)
                if (sensor_bus == 2'b00) next_state = IDLE; // Reset to IDLE when sensors read empty
            end

            default: next_state = IDLE;
        endcase

        // Safety Override: Catch impossible sensor state (High wet, Low dry)         
    end

endmodule
