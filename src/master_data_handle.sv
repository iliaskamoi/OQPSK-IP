`timescale 1ns / 1ps
`include "typedefs.sv"

module master_data_handle #(
        parameter C_S00_AXIS_TDATA_WIDTH = 16
    )(
        input transmission_state_t inphase_state,
        input transmission_state_t quadrature_state,
        input logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] inphase_valid_data,
        input logic [C_S00_AXIS_TDATA_WIDTH / 2 - 1 : 0] quadrature_valid_data,
        input logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] inphase_data_counter,
        input logic [$clog2(C_S00_AXIS_TDATA_WIDTH / 2) - 1 : 0] quadrature_data_counter,
        output logic [31:0] m00_axis_tdata
    );
    
    localparam SqrtTwoOverTwoPos = 16'b0101101000010010; // Is +0.70709228515625 approximately +sqrt(2)/2.
    localparam SqrtTwoOverTwoNeg = 16'b1010010111101110; // Is -0.70709228515625 approximately -sqrt(2)/2.

    always_comb begin
        if (inphase_state == SEND_OFFSET) begin
            m00_axis_tdata[31:16] = 0;            
        end
        else begin
            m00_axis_tdata[31:16] = inphase_valid_data[inphase_data_counter] ? SqrtTwoOverTwoPos : SqrtTwoOverTwoNeg;
        end
    end

    always_comb begin
        if (quadrature_state == SEND_OFFSET) begin
            m00_axis_tdata[15:0] = 0;            
        end
        else begin
            m00_axis_tdata[15:0] = quadrature_valid_data[quadrature_data_counter] ? SqrtTwoOverTwoPos : SqrtTwoOverTwoNeg;
        end
    end
    
endmodule
