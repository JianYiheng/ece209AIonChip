set outputDir ./output
file mkdir $outputDir

# step 1
read_verilog ./arithmetic_unit.v
create_ip -module_name dsp_mac -vendor xilinx.com -library ip -name xbip_dsp48_macro
set_property -dict [list \
  CONFIG.instruction1 {(A+D)*B+C} \
  CONFIG.pipeline_options {Expert} \
  CONFIG.dreg_3 {false} \
  CONFIG.areg_3 {false} \
  CONFIG.breg_3 {false} \
  CONFIG.creg_3 {false} \
  CONFIG.d_width {25} \
  CONFIG.a_width {25} \
  CONFIG.b_width {18} \
  CONFIG.c_width {48} \
  CONFIG.has_sclr {true} \
  CONFIG.areg_4 {true} \
  CONFIG.breg_4 {true} \
  CONFIG.creg_4 {true} \
  CONFIG.creg_5 {true} \
  CONFIG.mreg_5 {true} \
  CONFIG.preg_6 {true} \
  CONFIG.d_binarywidth {0} \
  CONFIG.a_binarywidth {0} \
  CONFIG.b_binarywidth {0} \
  CONFIG.concat_width {48} \
  CONFIG.concat_binarywidth {0} \
  CONFIG.c_binarywidth {0} \
  CONFIG.pcin_binarywidth {0} \
  CONFIG.p_full_width {48} \
  CONFIG.p_width {48} \
  CONFIG.p_binarywidth {0} \
] [get_ips dsp_mac]
# read_ip ./dsp_mac.xcix
export_ip_user_files -of_objects [get_ips dsp_mac]

# step 2
synth_ip [get_ips dsp_mac] -force
synth_design -top arithmetic_unit -part xc7k325tffg900-2 -flatten rebuilt
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt

## step 3
#opt_design
#power_opt_design
#place_design
#phys_opt_design
#write_checkpoint -force $outputDir/post_place
#report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
## step 4
#route_design
#write_checkpoint -force $outputDir/post_route
#report_timing_summary -file $outputDir/post_route_timing_summary.rpt
#report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
#report_clock_utilization -file $outputDir/clock_util.rpt
#report_utilization -file $outputDir/post_route_util.rpt
#report_power -file $outputDir/post_route_power.rpt
#report_drc -file $outputDir/post_imp_drc.rpt
#write_verilog -force $outputDir/arithmetic_impl_netlist.v
#write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc
