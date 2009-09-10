proc ssubtract { src_set to_remove } {
	set result {}
	foreach i $src_set {
		if {[lsearch $to_remove $i] == -1} {
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