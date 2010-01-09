package require controlFlow 0
package require test 0

test {
	"simple while" {
		do {
			incr i
			lappend val i
		} while { $i < 5 }
		assertEquals 5 [llength $val]
	} 
	
	"simple until" {
		do {
			incr i
			lappend val i
		} until { $i > 4 }
		assertEquals 5 [llength $val]
	}
	
	"simple break" {
		do {
			incr i
			lappend val i
			if {$i > 4} { break}
		} while { true }
		assertEquals 5 [llength $val]
	}

	"simple continue" {
		do {
			incr i
			lappend val i
			if {$i < 5} { continue }
		} while { false }
		assertEquals 5 [llength $val]
	}
	
	"do while do" {
		do {
			incr i
		} while {$i < 5} {
			lappend val i
		}
		assertEquals 4 [llength $val]
	}
	
	"do until do" {
		do {
			incr i
		} until {$i > 4} {
			lappend val i
		}
		assertEquals 4 [llength $val]
	}
}

