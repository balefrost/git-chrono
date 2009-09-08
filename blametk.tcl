#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

proc src_source { fname } {
	upvar argv0 argv0
	set path_parts [lrange [split $argv0 /] 0 end-1]
	set script_path [join [concat $path_parts $fname] /]
	source $script_path
}

src_source control-flow.tcl
src_source set.tcl
src_source widget.tcl
src_source git.tcl

proc seq { low high } {
	set result {}
	for { set i $low } { $i <= $high } { incr i } {
		lappend result $i
	}
	return $result
}

proc bash-escape { param } {
	return [regsub -all { } $param "\\ "]
}

set file [lindex $argv 0]

panedwindow .window -orient vertical -showhandle true

scroll text .contents -wrap no

set revlist [concat [string repeat "0" 40] [dict keys [git-follow-revs $file]]]

set incr [expr 255.0 / ([llength $revlist] - 1)]
puts $incr
iforeach i revname $revlist {
	set val [expr round($incr * $i)]
	set color [format "#ffff%02x" $val $val]
	puts "$i $revname $val $color"
	.contents.text tag configure rev#$revname -background $color
}

set f [open "|git blame -p [bash-escape $file]"]
set revision_header_rxp {^([[:xdigit:]]{40}) ([[:digit:]]+) ([[:digit:]]+)(?: ([[:digit:]]+))?$}
set file_line_rxp {^\t(.*)$}
set header_line_rxp {^([^\t].*?)(?: (.*))?$}

while {[gets $f line] >= 0} {
	if {![regexp $revision_header_rxp $line _ revision_name src_line dst_line line_count]} {
		error "expected header line! ($line)"
	}

	do {
		if {[gets $f line] == -1} { error "Unexpected EOF" }
	} while { [regexp $header_line_rxp $line _ key val] } {
		dict set revision_info($revision_name) $key $val
	}

	set oldend [.contents.text index end]
	set lineno [.contents.text count -lines 1.0 end]
	regexp $file_line_rxp $line _ fline
	.contents.text insert end "$fline\n"
	.contents.text tag add rev#$revision_name $lineno.0 [expr $lineno + 1].0
}



.contents.text configure -state disabled

set revision_tag_rxp {\mrev#([[:xdigit:]]{40})\M}

bind .contents.text <Button-1> {
	set idx [.contents.text index @%x,%y]
	set tags [.contents.text tag names $idx]
	if {![regexp $revision_tag_rxp $tags _ revname]} {
		error "there was no revision tag in the selected item"
	}
	event generate .contents.text <<RevisionSelected>> -data $revname
}

bind .contents.text <<RevisionSelected>> {
	set revinfo $revision_info(%d)
	
	setReadOnlyText .info_pane.revisionValue %d
	setReadOnlyText .info_pane.authorValue "[dict get $revinfo author] [dict get $revinfo author-mail]"
	setReadOnlyText .info_pane.dateValue "[clock format [dict get $revinfo author-time]]"
	setReadOnlyText .info_pane.commitSummaryValue "[dict get $revinfo summary]"
	setReadOnlyText .info_pane.filenameValue "[dict get $revinfo filename]"
}

frame .info_pane
label .info_pane.revisionLabel -text "Revision: "
text .info_pane.revisionValue -height 1
label .info_pane.filenameLabel -text "Filename: "
text .info_pane.filenameValue -height 1
label .info_pane.authorLabel -text "Author: "
text .info_pane.authorValue -height 1
label .info_pane.dateLabel -text "Date: "
text .info_pane.dateValue -height 1
label .info_pane.commitSummaryLabel -text "Summary: "
text .info_pane.commitSummaryValue -height 4
.window add .contents .info_pane
.window paneconfigure .contents -stretch always
.window paneconfigure .info_pane -stretch never
grid .info_pane.revisionLabel .info_pane.revisionValue -sticky nw
grid .info_pane.filenameLabel .info_pane.filenameValue -sticky nw
grid .info_pane.authorLabel .info_pane.authorValue -sticky nw
grid .info_pane.dateLabel .info_pane.dateValue -sticky nw
grid .info_pane.commitSummaryLabel .info_pane.commitSummaryValue -sticky nw

pack .window -expand 1 -fill both
