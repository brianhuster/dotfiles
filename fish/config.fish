if status is-interactive
    # Commands to run in interactive sessions can go here
    set -x OLLAMA_MODELS "/media/brianhuster/D/.ollama/models"
	# set local variable "D"
	set -x D /media/brianhuster/D
    set -gx PATH $PATH /usr/local/go/bin $D/.android-studio/bin /home/brianhuster/go/bin $D/Android/Sdk/emulator $D/Android/Sdk/platform-tools $D/Android/Sdk/tools
	set -gx ANDROID_HOME $D/Android/Sdk
    set -gx EDITOR nvim
end

set -gx ANDROID_USER_HOME /media/brianhuster/D/.android/
