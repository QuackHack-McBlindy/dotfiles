pip3() {
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
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


# Use original ls if any other arguments are provided
#ls() {
#    if [[ "$1" =~ ^- ]]; then
#        command ls "$@"
#    else
#        command lsd --tree --depth 1 "$@"
#    fi
#}

