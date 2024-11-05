`timescale 1ns / 1ps
`include "typedefs.sv"
`include "in_phase_fsm.sv"
`include "quadrature_fsm.sv"

module component_fsms #(
        parameter SAMPLES_PER_SYMBOL = 4,
        parameter C_S00_AXIS_TDATA_WIDTH = 16,
        parameter BURST_SIZE = 2
    )(
        input logic aclk,     
        input logic sresetn,
        input logic start_fsms,
        input logic last_quadrature_packet,
        input logic last_inphase_packet,
        output logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] quadrature_data_counter_out,
        output logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] inphase_data_counter_out,
        output logic end_of_transmission,
        output transmission_state_t inphase_state,
        output transmission_state_t quadrature_state,
        output logic quadrature_receive_data,
        output logic inphase_receive_data
    );
    
    
    
    /*******************************************************************************/
    logic inphase_receive_data;
    logic inphase_end_of_transmission;
    logic inphase_last_sample_of_packet;
    logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] inphase_data_counter;
    in_phase_fsm #(
        .SAMPLES_PER_SYMBOL(SAMPLES_PER_SYMBOL),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .BURST_SIZE(BURST_SIZE)
    ) in_phase_fsm_inst (
        .aclk(aclk),
        .sresetn(sresetn),    
        .start_fsms(start_fsms),
        .last_packet(last_inphase_packet),
        .last_sample_of_packet_out(inphase_last_sample_of_packet),
        .inphase_data_counter_out(inphase_data_counter),
        .end_of_transmission(inphase_end_of_transmission),
        .inphase_transmission_state_out(inphase_state)
    );

/*******************************************************************************/
    logic quadrature_receive_data;
    logic quadrature_end_of_transmission;
    logic quadrature_last_sample_of_packet;
    logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] quadrature_data_counter;
    quadrature_fsm #(
        .SAMPLES_PER_SYMBOL(SAMPLES_PER_SYMBOL),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .BURST_SIZE(BURST_SIZE)
    ) quadrature_fsm_inst (
        .aclk(aclk),
        .sresetn(sresetn),    
        .start_fsms(start_fsms),
        .last_packet(last_quadrature_packet),
        .last_sample_of_packet_out(quadrature_last_sample_of_packet),
        .quadrature_data_counter_out(quadrature_data_counter),
        .end_of_transmission(quadrature_end_of_transmission),
        .quadrature_transmission_state_out(quadrature_state)
    );
    
    always_comb begin
        quadrature_data_counter_out = quadrature_data_counter;
        inphase_data_counter_out = inphase_data_counter;
    end
    
    always_comb begin
        quadrature_receive_data = quadrature_last_sample_of_packet && !last_quadrature_packet;
        inphase_receive_data = inphase_last_sample_of_packet && !last_inphase_packet;
        end_of_transmission = quadrature_end_of_transmission && inphase_end_of_transmission;
    end
endmodule
