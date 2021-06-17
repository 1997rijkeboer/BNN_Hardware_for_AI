#!/usr/bin/tclsh
# Set simulation inputs from test file

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

# Load in weights
set fp [open "weightdata.txt" r]

foreach w [lreverse [split [read $fp] ""]] {
    if {$w == 0 || $w == 1} {
        #puts $w
        set_value -radix bin w_in $w
        set_value -radix bin w_en 1
        run $period
    }
}
set_value -radix bin w_en 0
run $period

close $fp


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
