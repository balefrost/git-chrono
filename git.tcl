proc bash-escape { param } {
	return [regsub -all { } $param "\\ "]
}

proc git-blame { filename linevar revnamevar infovar body } {
	set parts [split $filename ":"]
	if { [llength $parts] == 2 } {
		set f [open "|git blame -p [lindex $parts 0] -- [bash-escape [lindex $parts 1]]"]
	} elseif { [llength $parts] == 1 } {
		set f [open "|git blame -p [lindex $parts 0]"]
	} else {
		error "The filename was bad"
	}
	git-blame-proc 2 $f $linevar $revnamevar $infovar $body
}

proc git-blame-proc { levels f linevar revnamevar infovar proc } {
	upvar $levels $linevar line
	upvar $levels $revnamevar revname
	upvar $levels $infovar info
	
	set revision_header_rxp {^([[:xdigit:]]{40}) ([[:digit:]]+) ([[:digit:]]+)(?: ([[:digit:]]+))?$}
	set file_line_rxp {^\t(.*)$}
	set header_line_rxp {^([^\t].*?)(?: (.*))?$}

	while {[gets $f fline] >= 0} {
		if {![regexp $revision_header_rxp $fline _ revname src_line dst_line line_count]} {
			error "expected header line! ($fline)"
		}

		do {
			if {[gets $f fline] == -1} { error "Unexpected EOF" }
		} while { [regexp $header_line_rxp $fline _ key val] } {
			dict set revision_info($revname) $key $val
		}
	
		regexp $file_line_rxp $fline _ line
		
		set info $revision_info($revname)

		uplevel $levels $proc
	}
}

proc git-follow-revs { file } {
	set cmdResult [exec git log --name-only --follow --format=format:%H $file]
	return [regexp -all -inline -- {[^\n]+} $cmdResult]
}
