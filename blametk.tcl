proc src_source { fname } {
	upvar argv0 argv0
	set path_parts [lrange [split $argv0 /] 0 end-1]
	set script_path [join [concat $path_parts $fname] /]
	source $script_path
}

src_source ofile.tcl
src_source control-flow.tcl
src_source set.tcl

proc seq { low high } {
	set result {}
	for { set i $low } { $i <= $high } { incr i } {
		lappend result $i
	}
	return $result
}

scrollbar .contents_yscroll -command ".contents yview"
scrollbar .contents_xscroll -orient horizontal -command ".contents xview"
text .contents -wrap no -xscrollcommand ".contents_xscroll set" -yscrollcommand ".contents_yscroll set"

set revlist [exec git rev-list HEAD -- [lindex $argv 0]]

foreach i [seq 0 [llength $revlist]] {
	set tagname rev$i
	set incr [expr 255.0 / [llength $revlist]]
	set val [expr round($incr * $i)]
	set color [format "#ffff%02x" $val $val]
	.contents tag configure $tagname -background $color
}

set f [of_open "|git blame -p [lindex $argv 0]"]
set revision_header_rxp {^([[:xdigit:]]{40}) ([[:digit:]]+) ([[:digit:]]+)(?: ([[:digit:]]+))?$}
set file_line_rxp {^\t(.*)$}
set header_line_rxp {^([^\t].*?)(?: (.*))?$}

while {[of_gets f line] >= 0} {
	if {![regexp $revision_header_rxp $line _ revision_name src_line dst_line line_count]} {
		error "expected header line! ($line)"
	}

	do {
		if {[of_gets f line] == -1} { error "Unexpected EOF" }
	} while { [regexp $header_line_rxp $line _ key val] } {
		#puts "\t[of_line $f]: $revision_name: $key = $val"
		dict set revision_info($revision_name) $key $val
	}

	set oldend [.contents index end]
	set lineno [.contents count -lines 1.0 end]
	set revindex [expr [lsearch $revlist $revision_name] + 1]
	set tagname rev$revindex
	regexp $file_line_rxp $line _ fline
	.contents insert end "$fline\n"
	.contents tag add $tagname $lineno.0 [expr $lineno + 1].0
}
# .contents tag add rev0 1.0 1.end
# .contents tag add rev1 2.0 2.end
# .contents tag add rev2 3.0 3.end
# .contents tag add rev3 4.0 4.end

set usedrevs [array names revision_info]

pack .contents_yscroll -side right -fill y
pack .contents_xscroll -side bottom -fill x
pack .contents -expand 1 -fill both