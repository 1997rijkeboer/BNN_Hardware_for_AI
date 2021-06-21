#!/usr/bin/tclsh
# Set simulation inputs from test file

#log_wave [get_objects row_in ready row_out done rd_pass]
log_wave [get_objects -r]


set NUM_ROWS 28
set period 10
set halfperiod [expr $period/2]

# Clock & reset
add_force clk {0} {1 5} -repeat_every 10
set_value -radix bin reset 1
run $period
set_value -radix bin reset 0
run $period


# Perform tests
set fp [open "testdata.txt" r]
set testdata [split [read $fp] "\n"]

set numtests [lindex $testdata 0]

for {set i 0} {$i < $numtests} {incr i} {
    set offset [expr $i*($NUM_ROWS+1)+1]
    set label [lindex $testdata [expr $offset]]
    #puts "Input: $label"

    for {set j 0} {$j < $NUM_ROWS} {incr j} {
        set line [lindex $testdata [expr $offset + $j + 1]]
        #puts $line
        set_value -radix bin row_in $line
        set_value -radix bin ready 1
        run $period
    }
    set_value -radix bin ready 0
    run [expr $period * 10]

    set res [get_value -radix unsigned row_out]
    set act [regsub -all "," [get_value -radix dec act_dbg] ",\t"]
    puts "I: $label    O: $res    $act"

    set_value -radix bin reset 1
    run $period
    set_value -radix bin reset 0
    run $period
}


close $fp


exit
