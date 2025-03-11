if status is-interactive
    # Commands to run in interactive sessions can go here
    set -x OLLAMA_MODELS "/media/brianhuster/D/.ollama/models"
    set -gx PATH $PATH /usr/local/go/bin /media/brianhuster/D/.android-studio/bin
    set -gx EDITOR nvim
end

set -gx ANDROID_USER_HOME /media/brianhuster/D/.android/
