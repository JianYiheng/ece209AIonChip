onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+dsp_mac -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.dsp_mac xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {dsp_mac.udo}

run -all

endsim

quit -force
