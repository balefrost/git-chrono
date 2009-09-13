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


set file [lindex $argv 0]

panedwindow .window -orient horizontal -showhandle true
scroll listbox .revisions -noxscroll
panedwindow .panel -orient vertical -showhandle true
.window add .revisions .panel -sticky news

scroll text .contents -wrap no
frame .info_pane
.panel add .contents .info_pane -sticky news

.window paneconfigure .revisions -stretch never
.window paneconfigure .panel -stretch always
.panel paneconfigure .contents -stretch always
.panel paneconfigure .info_pane -stretch never

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
grid .info_pane.revisionLabel .info_pane.revisionValue -sticky nw
grid .info_pane.filenameLabel .info_pane.filenameValue -sticky nw
grid .info_pane.authorLabel .info_pane.authorValue -sticky nw
grid .info_pane.dateLabel .info_pane.dateValue -sticky nw
grid .info_pane.commitSummaryLabel .info_pane.commitSummaryValue -sticky nw

pack .window -expand 1 -fill both



set revdict [git-follow-revs $file]

foreach {key value} $revdict {
	.revisions.listbox insert end "$value ($key)"
}

bind .revisions.listbox <<ListboxSelect>> {
	set revname [lindex [dict keys $revdict] [.revisions.listbox curselection]]
	set file [lindex [dict values $revdict] [.revisions.listbox curselection]]
	event generate .revisions.listbox <<RevisionSelected>> -data "$revname:$file"
}

bind .contents.text <Button-1> {
	set idx [.contents.text index @%x,%y]
	set tags [.contents.text tag names $idx]
	if {[regexp {\mrev#([[:xdigit:]]{40})\M} $tags _ revname]} {
		event generate .contents.text <<RevisionSelected>> -data $revname
	}
}

set uncommitted_changes [string repeat "0" 40]

bind .revisions.listbox <<RevisionSelected>> {
	array unset revision_info
	
	.contents.text delete 1.0 end
	
	git-blame %d line revname info {
		set lineno [.contents.text count -lines 1.0 end]
		.contents.text insert end "$line\n"
		.contents.text tag add rev#$revname $lineno.0 [expr $lineno + 1].0
		set revision_info($revname) $info
	}

	set revlist [dict keys $revdict]
	if { [llength [array names revision_info -exact $uncommitted_changes]] != 0 } {
		set revlist [linsert $revlist 0 $uncommitted_changes]
	}

	set incr [expr 255.0 / ([llength $revlist] - 1)]
	iforeach i revname $revlist {
		set val [expr round($incr * $i)]
		set color [color 255 255 $val]
		.contents.text tag configure rev#$revname -background $color
	}
}

bind .contents.text <<RevisionSelected>> {
	set revinfo $revision_info(%d)
	
	setReadOnlyText .info_pane.revisionValue %d
	setReadOnlyText .info_pane.authorValue "[dict get $revinfo author] [dict get $revinfo author-mail]"
	setReadOnlyText .info_pane.dateValue "[clock format [dict get $revinfo author-time]]"
	setReadOnlyText .info_pane.commitSummaryValue "[dict get $revinfo summary]"
	setReadOnlyText .info_pane.filenameValue "[dict get $revinfo filename]"
}









