set -gx EDITOR nvim

if test -z "$NVIM"
    set -g fish_key_bindings fish_vi_key_bindings
    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    # Set the external cursor to a line. The external cursor appears when a command is started.
    # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
    set fish_cursor_external line
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block

    bind -M visual y fish_clipboard_copy
    bind -M normal p fish_clipboard_paste
end

set -x OLLAMA_MODELS "/media/brianhuster/D/.ollama/models"
set -x D /media/brianhuster/D
set -gx PATH $PATH \
    $D/.android-studio/bin \
    /usr/local/go/bin ~/go/bin \
    $D/Android/Sdk/emulator \
    $D/Android/Sdk/platform-tools \
    $D/Android/Sdk/tools \
    ~/.local/share/nvim/mason/bin/
	~/.nvm/
set -gx ANDROID_HOME $D/Android/Sdk
set -gx ANDROID_USER_HOME /media/brianhuster/D/.android/

function n8n
    docker run -it -p 5678:5678 \
        -v n8n_data:/home/node/.n8n \
        docker.n8n.io/n8nio/n8n \
        start --tunnel
end
