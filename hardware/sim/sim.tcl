#!/usr/bin/tclsh
# Set simulation inputs from test file

#log_wave [get_objects]


set NUM_ROWS 28


set fp [open "testdata.txt" r]
set testdata [split [read $fp] "\n"]

set numtests [lindex $testdata 0]

for {set i 0} {$i < $numtests} {incr i} {
    set offset [expr $i*($NUM_ROWS+1)+1]
    set label [lindex $testdata [expr $offset]]
    puts $label

    for {set j 0} {$j < $NUM_ROWS} {incr j} {
        set line [lindex $testdata [expr $offset + $j + 1]]
        puts $line
    }
}

close $fp


#run 1 ms
#exit
