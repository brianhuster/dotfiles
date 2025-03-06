if status is-interactive
    # Commands to run in interactive sessions can go here
	set -x OLLAMA_MODELS "/media/brianhuster/D/.ollama/models"
	set -gx PATH $PATH /usr/local/go/bin
	set -gx EDITOR nvim
	set -gx BROWSER w3m
end
