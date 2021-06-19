#!/usr/bin/tclsh
# Set simulation inputs from test file

log_wave [get_objects /top_tb/top_inst/row_in /top_tb/top_inst/ready /top_tb/top_inst/row_out /top_tb/top_inst/done /top_tb/top_inst/w_pass /top_tb/top_inst/rd_pass]


set NUM_ROWS 28
set period 10
set halfperiod [expr $period/2]

# Clock & reset
#add_force clk {0} {1 5} -repeat_every 10
set_value -radix bin reset 1
run $period
set_value -radix bin reset 0
run $period

# Load in weights
#set fp [open "../bnn_weights.txt" r]
#set i 0

#set_value -radix bin w_en 1
#foreach w [lreverse [split [read $fp] ""]] {
#    if {$w == 0 || $w == 1} {
#        #puts $w
#        set_value -radix bin w_in $w
#        run $period
#
#        incr i
#        if {[expr $i%100] == 0} {
#            puts $i
#            if {$i >= 200} {
#                break
#            }
#        }
#    }
#}
#set_value -radix bin w_en 0
#run $period
#
#close $fp
# 494 * 100 > 49362
for {set i 0} {$i < 494} {incr i} {
    puts $i
    run [expr $period * 100]
}


# Perform tests
set fp [open "testdata.txt" r]
set testdata [split [read $fp] "\n"]

set numtests [lindex $testdata 0]

for {set i 0} {$i < $numtests} {incr i} {
    set offset [expr $i*($NUM_ROWS+1)+1]
    set label [lindex $testdata [expr $offset]]
    puts "Input: $label"

    for {set j 0} {$j < $NUM_ROWS} {incr j} {
        set line [lindex $testdata [expr $offset + $j + 1]]
        #puts $line
        set_value -radix bin row_in $line
        set_value -radix bin ready 1
        run $period
    }
    set_value -radix bin ready 0
    run [expr $period * 10]

    set res [get_value -radix dec row_out]
    puts "Output: $res\n"

    set_value -radix bin reset 1
    run $period
    set_value -radix bin reset 0
    run $period
}


close $fp


exit
