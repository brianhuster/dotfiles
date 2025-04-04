if status is-interactive
    # Commands to run in interactive sessions can go here
    set -x OLLAMA_MODELS "/media/brianhuster/D/.ollama/models"
    # set local variable "D"
    set -x D /media/brianhuster/D
    set -gx PATH $PATH \
		$D/.android-studio/bin \
		~/usr/local/go/bin /go/bin \
		$D/Android/Sdk/emulator \
		$D/Android/Sdk/platform-tools \
		$D/Android/Sdk/tools \
		~/.local/share/nvim/mason/bin/
    set -gx ANDROID_HOME $D/Android/Sdk
    set -gx EDITOR nvim
end

set -gx ANDROID_USER_HOME /media/brianhuster/D/.android/
