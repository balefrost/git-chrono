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
src_source widget.tcl

set file [lindex $argv 0]

panedwindow .panel -orient horizontal -showhandle true

scroll listbox .revisions -noxscroll
scroll text .file -state disabled -wrap none

.panel add .revisions .file -sticky nsew
pack .panel -expand true -fill both

bind .revisions.listbox <<ListboxSelect>> {
	set revname [.revisions.listbox get [.revisions.listbox curselection]]
	event generate .revisions.listbox <<RevisionSelected>> -data $revname
}

bind .revisions.listbox <<RevisionSelected>> {
	setReadOnlyText .file.text [exec git show "%d:$file"]
}

set revlist [exec git rev-list HEAD -- $file]

foreach r $revlist {
	.revisions.listbox insert end $r
}
