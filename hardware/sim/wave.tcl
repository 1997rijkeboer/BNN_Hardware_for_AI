add_wave -radix bin [get_objects]
add_wave_group dbg
add_wave -radix dec -into dbg [get_objects -regexp {/top/dbg_row\[\d*\]}]
