#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

set file [lindex $argv 0]

panedwindow .panel -orient horizontal -showhandle true -background lightblue

frame .revisions
listbox .revisions.list -yscrollcommand ".revisions.scroll set"
scrollbar .revisions.scroll -command ".revisions.list yview"

frame .contents
scrollbar .contents.xscroll -orient horizontal -command ".contents.text xview"
scrollbar .contents.yscroll -command ".contents.text yview"
text .contents.text -state disabled -wrap none -xscrollcommand ".contents.xscroll set" -yscrollcommand ".contents.yscroll set"

.panel add .revisions .contents -sticky nsew
pack .panel -fill both -expand true

pack .revisions.scroll -in .revisions -side right -fill y
pack .revisions.list -in .revisions -side left -fill both -expand true
pack .contents.yscroll -side right -fill y
pack .contents.xscroll -side bottom -fill x
pack .contents.text -side left -fill both -expand true

bind .revisions.list <<ListboxSelect>> {
	set r [.revisions.list get [.revisions.list curselection]]
	.contents.text configure -state normal
	.contents.text delete 1.0 end
	.contents.text insert end [exec git show "$r:$file"]
	.contents.text configure -state disabled
}

set revlist [exec git rev-list HEAD -- $file]

foreach r $revlist {
	.revisions.list insert end $r
}
