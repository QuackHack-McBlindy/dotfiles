pip3() {
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

rainbow_text() {
    local text="$1"
    local colors=(
        "\033[38;5;196m"  # Red
        "\033[38;5;202m"  # Orange
        "\033[38;5;226m"  # Yellow
        "\033[38;5;46m"   # Green
        "\033[38;5;51m"   # Cyan
        "\033[38;5;189m"  # Blue
        "\033[38;5;99m"   # Purple
        "\033[0m"         # Reset color
    )

    local colored_text=""
    local color_index=0

    for ((i = 0; i < ${#text}; i++)); do
        colored_text+="${colors[$((color_index % ${#colors[@]}))]}${text:$i:1}\033[0m"
        ((color_index++))
    done
    echo -e ""
    echo -e "🌈 "
    echo -e "$colored_text" 
}


# Create a directory and cd into it
mkd() {
    mkdir "${1}" && cd "${1}"
}

path() {
  echo -e "${PATH//:/\\n}"
}

hm-logs() {
  # Fetch last 100 logs related to home-manager service
  log_output=$(sudo journalctl -u "home-manager-${USER}.service" | tail -100)
  
  # Extract the file path pattern for the 'clobbered' message
  conflict_file=$(echo "$log_output" | grep -oP "(?<=Existing file ')[^']+" | tail -n 1)

  # Check if a conflict file path was found
  if [ -n "$conflict_file" ]; then
    # Derive the backup file path (e.g., appending .bak2)
    backup_file="${conflict_file}.bak2"
    
    # Print the move command (optional)
    echo "Moving file from $conflict_file to $backup_file"
    
    # Execute the move command
    mv "$conflict_file" "$backup_file"
    
    # Check if the move command was successful
    if [ $? -eq 0 ]; then
      echo "File successfully moved to $backup_file"
    else
      echo "Failed to move file."
    fi
  else
    echo "No conflicting files found in the last 100 log entries."
  fi
}

c() {
  cat "$1" | xclip -selection clipboard
}

space() {
  df -h . | awk 'NR==2 {print $3 " / " $2}'
}

# Use original ls if any other arguments are provided
#ls() {
#    if [[ "$1" =~ ^- ]]; then
#        command ls "$@"
#    else
#        command lsd --tree --depth 1 "$@"
#    fi
#}

