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
	set revname [lindex [dict keys $revdict] [.revisions.listbox curselection]]
	set file [lindex [dict values $revdict] [.revisions.listbox curselection]]
	event generate .revisions.listbox <<RevisionSelected>> -data "$revname:$file"
}

bind .revisions.listbox <<RevisionSelected>> {
	setReadOnlyText .file.text [exec git show "%d"]
}

set cmdResult [exec git log --name-only --follow --format=format:%H $file]
set revdict [regexp -all -inline -- {[^\n]+} $cmdResult]

foreach {key value} $revdict {
	.revisions.listbox insert end "$value ($key)"
}
