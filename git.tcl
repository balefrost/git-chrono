proc git-follow-revs { file } {
	set cmdResult [exec git log --name-only --follow --format=format:%H $file]
	return [regexp -all -inline -- {[^\n]+} $cmdResult]
}
