proc scrolltext { name args } {
	frame $name -background red
	eval [concat text $name.text $args -xscrollcommand \{$name.xscroll set\} -yscrollcommand \{$name.yscroll set\}]
	scrollbar $name.xscroll -orient horizontal -command [concat $name.text xview]
	scrollbar $name.yscroll -orient vertical -command [concat $name.text yview]
	frame $name.corner -background orange

	grid $name.text $name.yscroll -sticky news
	grid $name.xscroll $name.corner -sticky news
	grid rowconfigure $name 0 -weight 1
	grid columnconfigure $name 0 -weight 1
}

panedwindow .window -orient vertical -showhandle true
scrolltext .top -background blue
frame .bottom -background green -width 200 -height 100

.window add .top .bottom
pack .window -expand 1 -fill both
