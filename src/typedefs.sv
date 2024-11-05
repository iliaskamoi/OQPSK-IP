`ifndef TYPEDEFS
`define TYPEDEFS

typedef enum logic [1:0] {
    SEND_DATA = 2'b00,
    SEND_OFFSET = 2'b01,
    IDLE = 2'b10,
    RESET = 2'b11
} transmission_state_t;

typedef enum logic {
    IDLE_MASTER = 1'b0,
    SEND_MASTER = 1'b1
} axis_master_fsm;
`endif