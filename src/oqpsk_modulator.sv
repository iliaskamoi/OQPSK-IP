`include "typedefs.sv"
//`include "component_fsms.sv"
//`include "valid_data.sv"
//`include "master_data_handle.sv"

module OQPSK_MODULATOR_v4_1 #(

        parameter BURST_SIZE = 256,

        parameter SAMPLES_PER_SYMBOL = 8,
        // Slave port 0 parameters.
        parameter C_S00_AXIS_TDATA_WIDTH = 64,
        
        // Master port 0 parameters. Associated with the FIR handling the in-phase component.
        parameter C_M00_AXIS_TDATA_WIDTH = 32
        
    )(

        /* General inputs and outputs. */
        input logic aclk,
        input logic sresetn,

        /* AXI4-S slave port 0 inputs and outputs. */
        input logic s00_axis_tvalid,
        input logic [C_S00_AXIS_TDATA_WIDTH - 1 : 0] s00_axis_tdata,
        output logic s00_axis_tready,
        input logic s00_axis_tlast,
        
        /* AXI4-S master port 0 inputs and outputs. */
        output logic  m00_axis_tvalid,
        output logic [C_M00_AXIS_TDATA_WIDTH - 1 : 0] m00_axis_tdata,
        input logic m00_axis_tready,
        output logic m00_axis_tlast
    
    );

    logic last_inphase_packet, last_quadrature_packet;
    
    always_comb begin
        last_inphase_packet = current_inphase_packet_counter == BURST_SIZE - 1;
        last_quadrature_packet = current_quadrature_packet_counter == BURST_SIZE - 1;
    end
    
    logic receive_data;
    logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] inphase_data_counter;
    logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] quadrature_data_counter;
    logic end_of_transmission;
    transmission_state_t quadrature_state, inphase_state;
    component_fsms #(
        .SAMPLES_PER_SYMBOL(SAMPLES_PER_SYMBOL),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .BURST_SIZE(BURST_SIZE)
    ) components (
        .aclk(aclk),     
        .sresetn(sresetn),
        .start_fsms(start_fsms),
        .last_inphase_packet(last_inphase_packet),
        .last_quadrature_packet(last_quadrature_packet),
        .quadrature_data_counter_out(quadrature_data_counter),
        .inphase_data_counter_out(inphase_data_counter),
        .quadrature_receive_data(quadrature_receive_data),
        .inphase_receive_data(inphase_receive_data),
        .inphase_state(inphase_state),
        .quadrature_state(quadrature_state),
        .end_of_transmission(end_of_transmission)
    );

/*******************************************************************************/
    logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] inphase_valid_data;
    logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] quadrature_valid_data;
    valid_data #(
        .SAMPLES_PER_SYMBOL(SAMPLES_PER_SYMBOL),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .BURST_SIZE(BURST_SIZE)
    ) data_seperator (
        .aclk(aclk),
        .sresetn(sresetn),
        .inphase_receive_data(inphase_receive_data),
        .quadrature_receive_data(quadrature_receive_data),
        .inphase_packet_counter(current_inphase_packet_counter),
        .quadrature_packet_counter(current_quadrature_packet_counter),
        .s00_axis_tdata(s00_axis_tdata),
        .quadrature_valid_data(quadrature_valid_data),
        .inphase_valid_data(inphase_valid_data),
        .start_fsms(s00_axis_tready && s00_axis_tvalid)
    );
    
/*******************************************************************************/
    
    logic [$clog2(BURST_SIZE) - 1 : 0] next_inphase_packet_counter, current_inphase_packet_counter;
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_inphase_packet_counter <= 0;
        end
        else begin
            current_inphase_packet_counter <= m00_axis_tready && inphase_state != IDLE ? next_inphase_packet_counter : current_inphase_packet_counter;
        end
    end
    
    always_comb begin
        if (end_of_transmission) begin
            next_inphase_packet_counter = 0;
        end
        else begin
            next_inphase_packet_counter = inphase_receive_data ? current_inphase_packet_counter + 1 : current_inphase_packet_counter;            
        end
    end

    logic [$clog2(BURST_SIZE) - 1 : 0] next_quadrature_packet_counter, current_quadrature_packet_counter;    
    
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_quadrature_packet_counter <= 0;
        end
        else begin
            current_quadrature_packet_counter <= m00_axis_tready && quadrature_state != IDLE ? next_quadrature_packet_counter : current_quadrature_packet_counter;
        end
    end
    
    always_comb begin
        if (end_of_transmission) begin
            next_quadrature_packet_counter = 0;
        end
        else begin
            next_quadrature_packet_counter = quadrature_receive_data ? current_quadrature_packet_counter + 1 : current_quadrature_packet_counter;            
        end
    end

    
    /*******************************************************************************/
    
    master_data_handle #(
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
    ) master_data (
        .inphase_state(inphase_state),
        .quadrature_state(quadrature_state),
        .inphase_valid_data(inphase_valid_data),
        .quadrature_valid_data(quadrature_valid_data),
        .inphase_data_counter(inphase_data_counter),
        .quadrature_data_counter(quadrature_data_counter),
        .m00_axis_tdata(m00_axis_tdata)
    );
    
    /********************************************************************************/
    axis_master_fsm next_axis_state, current_axis_state;
    always_ff @(posedge aclk) begin
        if (!sresetn) begin
            current_axis_state <= IDLE_MASTER;
        end
        else begin
            current_axis_state <= next_axis_state;
        end
    end
    
    always_comb begin
        if (current_axis_state == SEND_MASTER) begin
            next_axis_state = m00_axis_tlast ? IDLE_MASTER : SEND_MASTER;
        end
        else if (current_axis_state == IDLE_MASTER) begin
            next_axis_state = s00_axis_tready && s00_axis_tvalid ? SEND_MASTER : IDLE_MASTER;
        end
    end
    
    
    /********************************************************************************/
    
    logic start_fsms;
    always_comb begin
        m00_axis_tvalid = inphase_state == SEND_DATA || inphase_state == SEND_OFFSET;
        start_fsms = current_axis_state == SEND_MASTER && m00_axis_tready;
        s00_axis_tready = (current_axis_state == IDLE_MASTER || quadrature_receive_data);
        m00_axis_tlast = end_of_transmission && inphase_state != IDLE;
    end

endmodule
