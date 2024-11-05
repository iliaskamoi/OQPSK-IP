`timescale 1ns / 1ps

module valid_data #(
        parameter SAMPLES_PER_SYMBOL = 4,
        parameter C_S00_AXIS_TDATA_WIDTH = 64,
        parameter BURST_SIZE = 2
    )(
        input logic aclk,
        input logic sresetn,
        input logic inphase_receive_data,
        input logic quadrature_receive_data,
        input logic last_quadrature_sample_of_packet,
        input logic last_inphase_sample_of_packet,
        input logic start_fsms,
        input logic [$clog2(BURST_SIZE) - 1 : 0] inphase_packet_counter,
        input logic [$clog2(BURST_SIZE) - 1 : 0] quadrature_packet_counter,
        input logic [C_S00_AXIS_TDATA_WIDTH - 1 : 0] s00_axis_tdata,
        output logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] inphase_valid_data,
        output logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] quadrature_valid_data
    );

    logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] inphase_extracted;
    logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] quadrature_extracted;
    always_comb  begin
        for (int i = 0, int j = 0, int k = 0; i < C_S00_AXIS_TDATA_WIDTH; i++) begin
            if (i % 2 == 0) begin
                quadrature_extracted[j++] = s00_axis_tdata[i];
            end 
            else begin
                inphase_extracted[k++] = s00_axis_tdata[i];
            end
        end
    end

    always_ff @(posedge aclk) begin
        if (quadrature_receive_data) begin
            quadrature_valid_data <= quadrature_extracted;
        end
        else begin
            quadrature_valid_data <= start_fsms ? quadrature_extracted : quadrature_valid_data;
        end
    end
    always_ff @(posedge aclk) begin
        if (inphase_receive_data) begin
            inphase_valid_data <= inphase_extracted;
        end
        else begin
            inphase_valid_data <= start_fsms && !quadrature_receive_data ? inphase_extracted : inphase_valid_data;
        end
    end
endmodule
