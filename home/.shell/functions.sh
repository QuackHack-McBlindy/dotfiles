wait() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        # If the argument is a number, treat it as a sleep duration
        gum spin --spinner meter --title "Please wait..." -- sleep "$1"
    else
        # If a command is provided, execute it while showing the spinner
        gum spin --spinner meter --title "Please wait..." -- bash -c "$@"
    fi
}


# fzf interactive cd command
cd() { 
    if [ -z "$1" ]; then
        builtin cd "$(find ~ -type d | fzf)"
    else
        builtin cd "$1" && ls
    fi
}

detect_language() {
    local text="$1"
    # Echo the text and pipe it to langid to simulate interactive input
    langid <<< "$text" | awk '{print $1}'
}


send_notify() {
  #  notify-send -i /home/pungkula/dotfiles/home/.config/.notify-send/icon.png -u critical "$1" "$2" && say "$2"
    notify-send -u critical "$1" "$2" && bash say "$2"
}

# Advanced rm: Ask for confirmation before removing files. If it fails, ask for force removal.
rm() {
  wait 1
  
  # First confirmation for normal removal
  if gum confirm "Are you sure you want to delete this file/directory?" ; then
    if command rm "$@"; then
      echo "File/Directory deleted successfully."
    else
      wait 1
      # If rm fails, check if it's a directory and ask for force removal
      if [ -d "$1" ]; then
        # Handle directory removal specifically
        if gum confirm "This is a directory. Do you want to force remove it?" ; then
          command rm -rf "$@"
          if [ ! -d "$1" ]; then  # Check if the directory was deleted successfully
            echo "Directory deleted successfully."
          else
            echo "Failed to delete directory."
          fi
        else
          echo "Directory not deleted."
        fi
      else
        # Handle file removal failure (in case it's a file but failed to remove)
        if gum confirm "Regular removal failed. Do you want to force remove this file?" ; then
          command rm -f "$@"
          if [ ! -e "$1" ]; then  # Check if the file was deleted successfully
            echo "File deleted successfully."
          else
            echo "Failed to delete file."
          fi
        else
          echo "File not deleted."
        fi
      fi
    fi
  else
    echo "File/Directory not deleted."
  fi
}

# Advanced cp: Ask for confirmation before overwriting a file. If overwriting is not allowed, ask to force overwrite.
cp() {
  if command cp "$@" ; then
    echo "File copied successfully."
  else
    wait 2
    if gum confirm "Destination exists. Do you want to overwrite?" ; then
      command cp -f "$@"
    else
      echo "File not copied."
    fi
  fi
}

# Advanced mv: Ask for confirmation before overwriting a file. If overwriting is not allowed, ask to force overwrite.
mv() {
  if command mv "$@" ; then
    echo "File moved successfully."
  else
    wait 2
    if gum confirm "Destination exists. Do you want to overwrite?" ; then
      command mv -f "$@"
    else
      echo "File not moved."
    fi
  fi
}


servicess() {
    local service=$(systemctl list-units --type=service | fzf --preview="systemctl status {1} | tail -20" | awk '{print $1}' | sed 's/^[* ]*//')     
    if [[ -n "$service" ]]; then
        local logfile=$(mktemp)      
        journalctl -u "$service" -n 100 --no-pager > "$logfile"       
        gum pager < "$logfile"       
        rm "$logfile"        
        if gum confirm "Are you sure you want to restart the service: $service?"; then
            echo "Restarting service: $service"            
            sudo systemctl restart "$service"           
            wait 15
        else
            echo "Service restart canceled."
        fi
    else
        echo "No service selected"
    fi
}



# Extract compressed files
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xvjf "$1"   ;;
      *.tar.gz)    tar xvzf "$1"   ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xvf "$1"    ;;
      *.tbz2)      tar xvjf "$1"   ;;
      *.tgz)       tar xvzf "$1"   ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "Don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file."
  fi
}


# Compress directory or file
# Usage compress . tar.gz to compress current directory
# Compress files or directories
compress() {
  if [ -d "$1" ] || [ -f "$1" ]; then
    # Default to current directory if no path is given
    target="$1"
    
    # If no target is given, default to current directory (.)
    if [ "$target" == "." ]; then
      target=$(pwd)
    fi
    
    case "$2" in
      tar.bz2)  tar cvjf "$target.tar.bz2" "$target"  ;;
      tar.gz)   tar cvzf "$target.tar.gz" "$target"   ;;
      bz2)      bzip2 -z "$target"                     ;;
      rar)      rar a "$target.rar" "$target"          ;;
      gz)       gzip "$target"                         ;;
      tar)      tar cvf "$target.tar" "$target"        ;;
      tbz2)     tar cvjf "$target.tbz2" "$target"      ;;
      tgz)      tar cvzf "$target.tgz" "$target"       ;;
      zip)      zip -r "$target.zip" "$target"         ;;
      Z)        compress -z "$target"                  ;;
      7z)       7z a "$target.7z" "$target"            ;;
      *)        echo "Unsupported compression format '$2'." ;;
    esac
  else
    echo "'$1' is not a valid directory or file."
  fi
}

# Jump to directory using Thunar
jump() {
  thunar $PWD
}

# Color Helper
color() {
    case $1 in
        red)    color_code=31 ;;
        green)  color_code=32 ;;
        yellow) color_code=33 ;;
        blue)   color_code=34 ;;
        magenta) color_code=35 ;;
        cyan)   color_code=36 ;;
        reset)  color_code=0 ;;
        *)      color_code=0 ;;  # default to no color if invalid input
    esac
    echo -e "\e[${color_code}m$2\e[0m"
}

blink() {
    local text="$1"
    echo -e "\033[1;32m\033[5m$text \033[0m"
}

warning() {
    notify-send "warning"
    local warn="⚠️ WARNING ! ⚠️"
    local text="$1"
    echo -e "\033[1;35m\033[5m$warn\033[0m"
    echo -e "\033[1;35m\033[5m$text\033[0m"
}

# The confirm function
confirm() {
    # Ask user for confirmation
    if gum confirm "Do you want to proceed?"; then
        # Run the wait function with the arguments passed to confirm
        wait "$@"
        color yellow "Action completed!"
    else
        color red "Action canceled!"
    fi
}


flash() {
  # Ensure Gum is installed
  if ! command -v gum &> /dev/null; then
    echo "Gum is not installed. Please install it first: https://github.com/charmbracelet/gum"
    return 1
  fi

  # Display disk information using lsblk
  echo "Available Disks:"
  lsblk -d -o NAME,SIZE,TYPE | grep disk

  # Extract the list of disks for selection
  disk_list=$(lsblk -d -o NAME -n | xargs -n1)

  # Add "Exit" option
  disk_list=$(echo -e "$disk_list\nExit")

  # Prompt the user to select a disk (step 1)
  selected_disk=$(echo "$disk_list" | gum choose --header="Choose a disk:")

  # Check if the user selected "Exit"
  if [ "$selected_disk" == "Exit" ]; then
    echo "No disk selected. Exiting."
    return 0
  fi

  # Output the selected disk
  echo "You selected disk: /dev/$selected_disk"

  iso_list=$(find ./result/iso/ -maxdepth 1 -type f -name '*.iso' -exec basename {} \; | sort)

  # Check if any ISO files are found
  if [ -z "$iso_list" ]; then
    echo "No ISO files found in the specified directory."
    return 1
  fi

  # Add "Exit" option to ISO list
  iso_list=$(echo -e "$iso_list\nExit")

  # Prompt the user to select an ISO file (step 3)
  selected_iso=$(echo "$iso_list" | gum choose --header="Choose an ISO file:")

  # Check if the user selected "Exit"
  if [ "$selected_iso" == "Exit" ]; then
    echo "No ISO selected. Exiting."
    return 0
  fi

  # Output the selected ISO
  echo "You selected ISO: $selected_iso"

  # Double confirmation for disk erasure (step 4)
  if gum confirm "Warning: This will erase the entire disk /dev/$selected_disk. Are you sure you want to proceed?"; then
    echo "Proceeding with wiping the disk..."

    # Zero out the disk (step 5)
    sudo dd if=/dev/zero of=/dev/$selected_disk bs=1M status=progress
    echo "Disk /dev/$selected_disk has been wiped."

    if gum confirm "REMOVE USB STICK AND INSERT AGAIN"; then
      echo "Action confirmed! Flashing the ISO..."

      sudo dd if="./result/iso/$selected_iso" of="/dev/$selected_disk" bs=4M status=progress && echo "Flashed successfully!"
    else
      echo "Action canceled. No flashing performed."
    fi
  else
    echo "Disk wipe canceled. No action taken."
  fi
}


req_sudo() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m YO SUDO PLZ!"
    return 1  
  fi
}


# Kill port process
#killport() {
    # Prompt the user for the port number
#    read -p "Enter the port number to kill: " port
    # Find the PID of the process using the port
#    pid=$(lsof -t -i :$port)
    # Check if we found a PID
#    if [ -z "$pid" ]; then
        # No process found, print a red failure message
#        echo -e "\033[31mFailed to kill port $port, no process running on that port!\033[0m"
#        return 1
#    fi
    # Get the process name from the PID
#    process_name=$(ps -p $pid -o comm=)
    # Kill the process
#    sudo kill -9 $pid
    # Check if the kill was successful
#    if [ $? -eq 0 ]; then
        # Successfully killed the process, print a green success message
#        echo -e "\033[32mSuccessfully killed $process_name on port $port!\033[0m"
#    else
        # Kill failed, print a red failure message
#        echo -e "\033[31mFailed to kill process on port $port!\033[0m"
#    fi
#}
ports() {
  sudo lsof -iTCP -sTCP:LISTEN -nP | fzf \
    --header='Select a listening port to inspect/kill' \
    --preview='echo {} | awk '"'"'{print $2}'"'"' | xargs -I {} ps -fp {}' \
    --bind 'enter:execute-silent(echo {} | awk '"'"'{print $2}'"'"' | xargs -I {} kill -9 {})+abort'
}


# File Decryption Using Yubikey & Age
decrypt() {
  local filepath="$1"
  age-plugin-yubikey --identity --slot 1 > /home/pungkula/dotfiles/home/.config/Yubico/yubikey-identity.txt
  rage -d "$filepath" -i /home/pungkula/dotfiles/home/.config/Yubico/yubikey-identity.txt
}

# File Encryption Using Yubikey & Age
encrypt() {
  local filepath="$1"
  local decrypted_filepath="${filepath}_DECRYPTED"  # Rename the file to add _DECRYPTED suffix
  mv "$filepath" "$decrypted_filepath"
  if rage -r age1yubikey1q0ek47e26sg9eej2xlvxj308fgw8h8ajgx6ucagjzlm9tzgxtckdw35eg0m -o "$filepath" "$decrypted_filepath"; then
    # Optional: Remove the renamed decrypted file after encryption
    rm -f "$decrypted_filepath"
    echo -e "\033[1;32m\033[5mSuccessfully encrypted \033[1;31m$filepath\033[0m \033[5m\033[1;32m!"
  else
    echo -e "\033[1;31mError: Encryption failed for \033[1;37m$filepath\033[0m"
  fi
}


copy() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: copy_with_progress <source> <destination>"
        return 1
    fi

    local src="$1"
    local dest="$2"

    if [[ ! -d "$src" ]]; then
        echo "Error: Source directory does not exist: $src"
        return 1
    fi

    if [[ ! -d "$dest" ]]; then
        echo "Destination does not exist. Creating: $dest"
        mkdir -p "$dest"
    fi

    local total_size=$(du -sb "$src" | awk '{print $1}')

    rsync -avh --progress "$src/" "$dest/" | pv -pet -s "$total_size" > /dev/null
}

