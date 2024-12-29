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
        builtin cd "$1"
    fi
}

detect_language() {
    local text="$1"
    # Echo the text and pipe it to langid to simulate interactive input
    langid <<< "$text" | awk '{print $1}'
}


send_notify() {
    notify-send -i /home/pungkula/dotfiles/home/.config/.notify-send/icon.png -u critical "$1" "$2" && say "$2"
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

# Read File
services() {
    # Get the service name using fzf
    local service=$(systemctl list-units --type=service | fzf --preview="systemctl status {1} | tail -20" | awk '{print $1}')
    
    # Check if a service was selected
    if [[ -n "$service" ]]; then
        # Prompt for confirmation before restarting
        if gum confirm "Are you sure you want to restart the service: $service?"; then
            echo "Restarting service: $service"
            
            # Restart the selected service
            sudo systemctl restart "$service"
            
            # Wait for 15 seconds with the custom wait function
            wait 15
            
            # Create a temporary file to store the logs
            local logfile=$(mktemp)
            
            # Save the last 100 lines of logs to the temporary file (adjust the number as needed)
            journalctl -u "$service" -n 100 --no-pager > "$logfile"
            
            # Show the logs using gum pager
            gum pager < "$logfile"
            
            # Clean up the temporary log file
            rm "$logfile"
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

  # List all ISO files in the result/iso directory (step 2)
  iso_list=$(ls ./result/iso/)

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

    # Confirm removal and re-insertion of the USB stick (step 6)
    if gum confirm "REMOVE USB STICK AND INSERT AGAIN"; then
      echo "Action confirmed! Flashing the ISO..."

      # Flash the selected ISO onto the USB (step 7)
      sudo dd if="./result/iso/$selected_iso" of="/dev/$selected_disk" bs=4M status=progress && echo "Flashed successfully!"
    else
      echo "Action canceled. No flashing performed."
    fi
  else
    echo "Disk wipe canceled. No action taken."
  fi
}


req_sudo() {
  # Check if the script is run as root
  if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m YO SUDO PLZ!"
    return 1  # Use return to avoid crashing the terminal
  fi
}
