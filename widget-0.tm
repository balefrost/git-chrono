package provide widget 0

proc consumeArg { listName argName } {
	upvar $listName list
	set argIndex [lsearch -exact $list $argName]
	if {$argIndex != -1} {
		set list [lreplace $list $argIndex $argIndex]
		return true
	} else {
		return false
	}
}

proc scroll { type name args } {
	frame $name
	
	set xscroll [expr ! [consumeArg args -noxscroll]]
	set yscroll [expr ! [consumeArg args -noyscroll]]
	
	set widgetCommand [concat $type $name.$type $args]
	if { $xscroll } {
		lappend widgetCommand -xscrollcommand "$name.xscroll set"
		scrollbar $name.xscroll -orient horizontal -command "$name.text xview"
	}

	if { $yscroll } {
		lappend widgetCommand -yscrollcommand "$name.yscroll set"
		scrollbar $name.yscroll -orient vertical -command "$name.text yview"
	}
	
	if { $xscroll && $yscroll } {
		frame $name.corner
	}

	eval $widgetCommand
	
	grid $name.$type -row 0 -column 0 -sticky news
	if { $yscroll } {
		grid $name.yscroll -row 0 -column 1 -sticky news
	}
	if { $xscroll } {
		grid $name.xscroll -row 1 -column 0 -sticky news
	}
	if { $xscroll && $yscroll } {
		grid $name.corner -row 1 -column 1 -sticky news
	}
	grid rowconfigure $name 0 -weight 1
	grid columnconfigure $name 0 -weight 1
}

proc setReadOnlyText { windowPath value } {
	updateReadOnlyText $windowPath {
		$windowPath replace 1.0 end $value
	}
}

proc updateReadOnlyText { windowPath block } {
	$windowPath configure -state normal
	uplevel $block
	$windowPath configure -state disabled
}

proc color { red green blue } {
	return [format "#%02x%02x%02x" $red $green $blue]
}
