set periph_ninstances    0

proc generate {drv_handle} {
  ::hsi::utils::define_include_file $drv_handle "xparameters.h" "OQPSK" "NUM_INSTANCES" "BURST_SIZE" "C_S00_AXIS_TDATA_WIDTH" "SAMPLES_PER_SYMBOL"
  ::hsi::utils::define_canonical_xpars $drv_handle "xparameters.h" "OQPSK" "BURST_SIZE" "C_S00_AXIS_TDATA_WIDTH" "SAMPLES_PER_SYMBOL"
}

