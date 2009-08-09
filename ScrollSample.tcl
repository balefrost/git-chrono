
proc rtassert { condition {message {}} } {
	if { ! [uplevel expr $condition] } {
		puts -nonewline "Failure"
		if {[string length $message] > 0} {
			puts -nonewline ": $message"
		}
		puts {}
		exit 1
	}
}

#Tcl variables are proc-scoped. This proc provides a way to evaluate a block in a brand new scope
proc newscope { block } {
	eval $block
}

apply { {} {
	set i 5
	newscope {
		set i 100
	}
	rtassert {$i == 5} "newscope did not actually establish a new scope"
} }
