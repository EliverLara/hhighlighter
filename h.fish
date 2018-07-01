function h

	set -l _OPTS ""

	# detect pipe or tty
	if  isatty stdin
		help_usage
		return 1
	end

	
	__argu i c d -- $argv | while read -l opt value
		switch $opt
			case "-i"
	            set _OPTS $_OPTS" -i "
	        case "-d"
	             set _OPTS $_OPTS" -Q "
	        case "-c"
	            set n_flag true
			case "-Q"
	            set _OPTS  $_OPTS" -Q "
	        case _
				set keywords $keywords $value
	        	
		end
	end

	# check for keywords
	if test (count $keywords) -eq 0
		help_usage
		return 1
	end

	set -l _i 1

	if test -n "$H_COLORS_FG"
		set -l _CSV $H_COLORS_FG
		set -l OLD_IFS "$IFS"
		set IFS ","
		for entry in $_CSV
			set _COLORS_FG "$_COLORS_FG" "$entry"
		end
		set IFS "$OLD_IFS"
	else
		 set _COLORS_FG "underline bold red" \
		  "underline bold green" \
		  "underline bold yellow" \
		  "underline bold blue" \
		  "underline bold magenta" \
		  "underline bold cyan"
	end

	if test -n "$H_COLORS_BG"
		set -l _CSV $H_COLORS_BG
		set -l OLD_IFS "$IFS"
		set IFS ","
		for entry in $_CSV
			set _COLORS_BG "$_COLORS_BG" "$entry"
		end
		set IFS "$OLD_IFS"
	else
		set _COLORS_BG "bold on_red" \
		"bold on_green" \
		"bold black on_yellow" \
		"bold on_blue" \
		"bold on_magenta" \
		"bold on_cyan" \
		"bold black on_white"

	end



	if test $n_flag
		#inverted-colors-last scheme
		set _COLORS $_COLORS_FG $_COLORS_BG
	else
		#inverted-colors-first sche
		set _COLORS $_COLORS_BG $_COLORS_FG
	end

	if test (count $keywords) -gt (count $_COLORS)
		echo "You have passed to hhighlighter more keywords to search than the number of configured colors.
	Check the content of your H_COLORS_FG and H_COLORS_BG environment variables or unset them to use default 13 defined colors."
		return 1
	end

	set -l ACK (type -p ack)
	set -l _COMMAND ""

	# build the filtering command
	for keyword in $keywords
		set  _COMMAND $_COMMAND"$ACK $_OPTS --noenv --flush --passthru --color --color-match=\"$_COLORS[$_i]\" '$keyword' |"
		set _i (math "$_i + 1")
	end

	
	#trim ending pipe
	set _COMMAND (echo $_COMMAND | sed 's/.$//g')

	echo $_COMMAND
	eval $_COMMAND
	#echo $_OPTS
	

end

function help_usage
	echo "h usage: YOUR_COMMAND | h [-idc] keyword...
	-i : ignore case
	-d : disable regexp
	-c : invert colors"
end
