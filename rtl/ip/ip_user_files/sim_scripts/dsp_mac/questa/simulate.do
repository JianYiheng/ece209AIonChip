onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib dsp_mac_opt

do {wave.do}

view wave
view structure
view signals

do {dsp_mac.udo}

run -all

quit -force
