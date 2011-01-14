package provide git 0

package require controlFlow 0

proc bash-escape { param } {
	return [regsub -all { } $param "\\ "]
}

namespace eval git {

	proc blame { filename linevar revnamevar infovar body } {
		set parts [split $filename ":"]
		if { [llength $parts] == 2 } {
			set f [open "|git blame -p [lindex $parts 0] -- [bash-escape [lindex $parts 1]]"]
		} elseif { [llength $parts] == 1 } {
			set f [open "|git blame -p [lindex $parts 0]"]
		} else {
			error "The filename was bad"
		}
		blame-proc 2 $f $linevar $revnamevar $infovar $body
		close $f
	}

	proc blame-proc { levels f linevar revnamevar infovar proc } {
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

	#Asks Git for a list of revisions of the specified file.
	#The search will follow the file through renames.
	#The resulting list contains interleaved revision name and file name entries.
	#This also makes it suitable for use as a dict.
	proc follow-revs { file } {
		set cmdResult [exec git log --name-only --follow --format=format:%H $file]
		return [regexp -all -inline -- {[^\n]+} $cmdResult]
	}

	proc log { file } {
		set cmdResult [exec git log --name-only --follow --format=format:%H%n%an%n%ae%n%at%n%s $file]
		set rxpResult [regexp -all -inline -- {[^\n]+} $cmdResult]
		flatmap { commitName authorName authorEmail authorDate subject fileName } $rxpResult {
			list $commitName [dict create author $authorName author-mail "<$authorEmail>" author-time $authorDate summary $subject filename $fileName]
		}
	}
	
	proc cdup {} {
		return [exec git rev-parse --show-cdup]
	}

}