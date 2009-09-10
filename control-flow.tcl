proc do {body while_or_until condition {rest {}}} {
	if {$while_or_until eq "while"} {
		set break_test [list uplevel expr ! ( $condition ) ]
	} elseif {$while_or_until eq "until"} {
		set break_test [list uplevel expr $condition ]
	} else {
		error "Syntax error: do body while condition or do body until condition"
	}
	
	while {true} {
		uplevel $body

		if {[eval $break_test]} {
			break
		}
		
		uplevel $rest
	}
}

proc seq { low high } {
	set result {}
	for { set i $low } { $i <= $high } { incr i } {
		lappend result $i
	}
	return $result
}

proc iforeach { index_var value_var list body } {
	upvar $index_var index
	upvar $value_var value

	set index 0
	foreach value $list {
		uplevel $body
		incr index
	}
}

proc doto { value commandList } {
	foreach command $commandList {
		uplevel [concat $value $command]
	}
}
