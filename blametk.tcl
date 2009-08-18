#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

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

proc iforeach { index_var value_var list body } {
	upvar $index_var index
	upvar $value_var value

	set index 0
	foreach value $list {
		uplevel $body
		incr index
	}
}

proc scrolltext { name args } {
	frame $name
	eval [concat text $name.text $args -xscrollcommand \{$name.xscroll set\} -yscrollcommand \{$name.yscroll set\}]
	scrollbar $name.xscroll -orient horizontal -command [concat $name.text xview]
	scrollbar $name.yscroll -orient vertical -command [concat $name.text yview]
	frame $name.corner

	grid $name.text $name.yscroll -sticky news
	grid $name.xscroll $name.corner -sticky news
	grid rowconfigure $name 0 -weight 1
	grid columnconfigure $name 0 -weight 1
}

panedwindow .window -orient vertical -showhandle true

scrolltext .contents -wrap no

set revlist [concat [string repeat "0" 40] [exec git rev-list HEAD -- [lindex $argv 0]]]

set incr [expr 255.0 / ([llength $revlist] - 1)]
puts $incr
iforeach i revname $revlist {
	set val [expr round($incr * $i)]
	set color [format "#ffff%02x" $val $val]
	puts "$i $revname $val $color"
	.contents.text tag configure rev#$revname -background $color
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

	set oldend [.contents.text index end]
	set lineno [.contents.text count -lines 1.0 end]
	regexp $file_line_rxp $line _ fline
	.contents.text insert end "$fline\n"
	.contents.text tag add rev#$revision_name $lineno.0 [expr $lineno + 1].0
}

set revision_tag_rxp {\mrev#([[:xdigit:]]{40})\M}

bind .contents.text <Button> {
	set idx [.contents.text index @%x,%y]
	set tags [.contents.text tag names $idx]
	if {![regexp $revision_tag_rxp $tags _ revname]} {
		error "there was no revision tag in the selected item"
	}
	.info_pane.label configure -text $revname
}

frame .info_pane
label .info_pane.label
.window add .contents .info_pane
.window paneconfigure .contents -stretch always
.window paneconfigure .info_pane -stretch never
pack .info_pane.label

pack .window -expand 1 -fill both
