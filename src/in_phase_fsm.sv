`timescale 1ns / 1ps
`include "typedefs.sv"

module in_phase_fsm #(
        parameter SAMPLES_PER_SYMBOL = 4,
        parameter C_S00_AXIS_TDATA_WIDTH = 16,
        parameter BURST_SIZE = 2
    )(
        input logic aclk, sresetn,    
        input logic start_fsms,
        input logic last_packet,
        output logic last_sample_of_packet_out,
        output logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] inphase_data_counter_out,
        output transmission_state_t inphase_transmission_state_out,
        output logic end_of_transmission
    );
    
    
    always_comb begin
        inphase_data_counter_out = current_inphase_data_counter;
        inphase_transmission_state_out = current_inphase_transmission_state;
        last_sample_of_packet_out = last_sample && last_data_of_packet;
        end_of_transmission = last_data;
    end
    
    logic last_sample;
    logic last_data_of_packet;
    logic last_offset;
    logic last_data;
    logic last_sample_of_packet;
    always_comb begin
        last_sample = current_inphase_sample_counter == SAMPLES_PER_SYMBOL - 1;
        last_data_of_packet = current_inphase_data_counter == C_S00_AXIS_TDATA_WIDTH / 2 - 1;
        last_offset = current_inphase_offset_counter == SAMPLES_PER_SYMBOL / 2 - 1;
        last_data = last_data_of_packet && last_packet;
        last_sample_of_packet = last_sample && last_data_of_packet;
    end
    
    /*********************************************************************************/    
    logic next_continue_offset, current_continue_offset;
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_continue_offset <= 0;
        end
        else begin
            current_continue_offset = start_fsms ? next_continue_offset : current_continue_offset;
        end
    end
    
    always_comb begin
        if (current_inphase_transmission_state == SEND_OFFSET) begin
            next_continue_offset = last_offset ? 0 : 1;
        end
        else if (current_inphase_transmission_state == SEND_DATA) begin
            next_continue_offset = 0;
        end 
        else if (current_inphase_transmission_state == RESET) begin
            next_continue_offset = 0;
        end
        else begin
            next_continue_offset = current_continue_offset;
        end
    end
    /*********************************************************************************/    
    
    transmission_state_t next_inphase_transmission_state, current_inphase_transmission_state;
    
    always_comb begin
        if (current_inphase_transmission_state == RESET) begin
            next_inphase_transmission_state = SEND_OFFSET;
        end
        else if (current_inphase_transmission_state == IDLE) begin
            next_inphase_transmission_state = current_continue_offset ? SEND_OFFSET : SEND_DATA;
        end
        else if (current_inphase_transmission_state == SEND_OFFSET) begin
            next_inphase_transmission_state = last_offset ? SEND_DATA : SEND_OFFSET;
        end
        else if (current_inphase_transmission_state == SEND_DATA) begin
            next_inphase_transmission_state = last_sample_of_packet && last_packet ? RESET : SEND_DATA;
        end
        else begin
            next_inphase_transmission_state = IDLE;
        end 
    end
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_inphase_transmission_state <= RESET;
        end
        else begin
            if (current_inphase_transmission_state == RESET) begin
                current_inphase_transmission_state <= start_fsms ? next_inphase_transmission_state : RESET;
            end
            else begin
                current_inphase_transmission_state <= start_fsms ? next_inphase_transmission_state : IDLE;
            end
        end
    end
    
    /*********************************************************************************/
    
    logic [$clog2(SAMPLES_PER_SYMBOL / 2) - 1 : 0] current_inphase_offset_counter, next_inphase_offset_counter;
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_inphase_offset_counter <= 0;
        end
        else begin
            current_inphase_offset_counter <= start_fsms ? next_inphase_offset_counter : current_inphase_offset_counter;
        end
    end
    
    always_comb begin
        if (current_inphase_transmission_state == SEND_OFFSET) begin
            next_inphase_offset_counter = last_offset ? 0 : current_inphase_offset_counter + 1;
        end
        else if (current_inphase_transmission_state == IDLE) begin
            next_inphase_offset_counter = current_inphase_offset_counter;
        end
        else begin
            next_inphase_offset_counter = 0;
        end
    end

    /*********************************************************************************/
    
    logic [$clog2(SAMPLES_PER_SYMBOL) - 1: 0] next_inphase_sample_counter, current_inphase_sample_counter;
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_inphase_sample_counter <= 0;
        end
        else begin
            current_inphase_sample_counter <= start_fsms ? next_inphase_sample_counter : current_inphase_sample_counter;
        end
    end
    
    always_comb begin
        if (current_inphase_transmission_state == SEND_DATA) begin
            next_inphase_sample_counter = last_sample ? 0 : current_inphase_sample_counter + 1;
        end
        else if (current_inphase_transmission_state == IDLE) begin
            next_inphase_sample_counter = current_inphase_sample_counter;
        end
        else begin
            next_inphase_sample_counter = 0;
        end
    end
    
    /*********************************************************************************/
    
    logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] next_inphase_data_counter, current_inphase_data_counter;
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_inphase_data_counter <= 0;
        end
        else begin
            current_inphase_data_counter <= start_fsms ? next_inphase_data_counter : current_inphase_data_counter;
        
        end
    end
    
    always_comb begin
        if (current_inphase_transmission_state == SEND_DATA) begin
            if (last_sample) begin
                next_inphase_data_counter = last_data_of_packet ? 0 : current_inphase_data_counter + 1;
            end
            else begin
                next_inphase_data_counter = current_inphase_data_counter;
            end
        end
        else if (current_inphase_transmission_state == IDLE) begin
            next_inphase_data_counter = current_inphase_data_counter;
        end
        else begin
            next_inphase_data_counter = 0;
        end
    end
    
endmodule