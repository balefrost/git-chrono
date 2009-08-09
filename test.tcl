proc test { mapping } {
	dict for { name proc} $mapping {
		puts -nonewline $name
		set result [catch [list newscope $proc] message]
		puts -nonewline " - "
		switch $result {
			0 -
			2 { puts "success" }
			1 { puts "$message" }
			3 { break }
			4 { continue }
			10 { puts "failed: $message" }
			default { puts "error $result" }
		}
	}
}

proc assertEquals {expected actual} {
	if {$expected != $actual} {
		return -code 10 "Expected $expected, but was $actual"
	}
}

