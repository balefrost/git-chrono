proc of_line { of } {
	return [lindex $of 1]
}

proc of_open { path } {
	return [list [open $path] 0]
}

proc of_gets { of out } {
	upvar $of uf
	upvar $out uout
	set ret [gets [lindex $uf 0] uout]
	lset uf 1 [expr [of_line $uf] + 1]
	return $ret
}
