DOTFILES_DIR="."

for item in "$DOTFILES_DIR/"*; do
    base_item=$(basename "$item")
    
    if [ -d "$item" ]; then
        if [ -d "$HOME/$base_item" ]; then
            echo "$HOME/$base_item already exists. Copying contents..."
            cp -r "$item/"* "$HOME/$base_item/"
        else
            cp -r "$item" "$HOME/"
            echo "Copied directory: $base_item to $HOME/"
        fi

	# Nếu không phải thư mục
    else
		cp "$item" "$HOME/"
		echo "Copied file: $base_item to $HOME/"
    fi
done

