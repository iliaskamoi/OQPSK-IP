# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox

  set BURST_SIZE [ipgui::add_param $IPINST -name "BURST_SIZE"]
  set_property tooltip {How many bursts the peripheral will receive} ${BURST_SIZE}
  set SAMPLES_PER_SYMBOL [ipgui::add_param $IPINST -name "SAMPLES_PER_SYMBOL" -widget comboBox]
  set_property tooltip {Samples per symbol} ${SAMPLES_PER_SYMBOL}
  #Adding Page
  set _Clocks_ [ipgui::add_page $IPINST -name "_Clocks_"]
  ipgui::add_static_text $IPINST -name "clock_text" -parent ${_Clocks_} -text {Enter the target frequency for the input clock(s) for the IP.
These frequencies will be used during the default out-of-context synthesis flow}


}

proc update_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to update BURST_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to validate BURST_SIZE
	return true
}

proc update_PARAM_VALUE.SAMPLES_PER_SYMBOL { PARAM_VALUE.SAMPLES_PER_SYMBOL } {
	# Procedure called to update SAMPLES_PER_SYMBOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPLES_PER_SYMBOL { PARAM_VALUE.SAMPLES_PER_SYMBOL } {
	# Procedure called to validate SAMPLES_PER_SYMBOL
	return true
}

proc update_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S00_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M00_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BURST_SIZE { MODELPARAM_VALUE.BURST_SIZE PARAM_VALUE.BURST_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BURST_SIZE}] ${MODELPARAM_VALUE.BURST_SIZE}
}

proc update_MODELPARAM_VALUE.SAMPLES_PER_SYMBOL { MODELPARAM_VALUE.SAMPLES_PER_SYMBOL PARAM_VALUE.SAMPLES_PER_SYMBOL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPLES_PER_SYMBOL}] ${MODELPARAM_VALUE.SAMPLES_PER_SYMBOL}
}

