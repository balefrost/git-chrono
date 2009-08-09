proc ssubtract { src_set set_to_remove } {
	set result {}
	foreach i $src_set {
		if {[lsearch $set_to_remove $i] == -1} {
			lappend result $i
		}
	}
	return $result
}

proc sintersect { left right } {
	set result {}
	foreach i $left {
		if {[lsearch $right $i] != -1} {
			lappend result $i
		}
	}
	return $result
}