


function fish_command_not_found
	if type -q command-not-found
		command-not-found $argv[1]
	else if type -q /usr/lib/command-not-found
		/usr/lib/command-not-found $argv[1]
	else
		__fish_default_command_not_found_handler $argv[1]
	end
end
