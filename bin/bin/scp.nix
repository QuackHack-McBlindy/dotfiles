# bin/scp.nix
{ self, config, pkgs, cmdHelpers, ... }:
{
  yo.scripts = {
    scp = {
      description = "Move files between hosts interactively";
      aliases = [ "pl" ];
      parameters = [ 
        { name = "flake"; description = "Path to the directory containing your flake.nix"; optional = true; default = config.this.user.me.dotfilesDir; } 
      ];
      code = ''
        ${cmdHelpers}
        read -p "[HOSTNAME/IP]: " remote_host
        read -p "[USERNAME]: " remote_user
        local_download_dir="/home/pungkula/scp"
        list_directory() {
            local path="$1"
            ssh "$remote_user@$remote_host" "ls -p $(echo $path)"  # Expanding path
        }
        remove_trailing_slash() {
            echo "$1" | sed 's:/*$::'
        }
        navigate_directory() {
            local current_path="$1"
            current_path=$(remove_trailing_slash "$current_path")
            if [[ "$current_path" != "~" ]]; then
                list=$(echo -e "Back\n$(list_directory "$current_path")")
            else
                list=$(list_directory "$current_path")
            fi
            selected_item=$(echo "$list" | gum choose --height 20)
            if [[ "$selected_item" == "Back" ]]; then
                navigate_directory "$(dirname "$current_path")"
            else
                if [[ "$selected_item" == */ ]]; then
                    choice=$(gum choose "Enter directory" "Select directory")
                    if [[ "$choice" == "Enter directory" ]]; then
                        navigate_directory "$current_path/$selected_item"
                    else
                        download_item "$current_path/$selected_item"
                    fi
                else
                    download_item "$current_path/$selected_item"
                fi
            fi
        }
        download_item() {
            local remote_path="$1"
            remote_path=$(remove_trailing_slash "$remote_path")
            remote_path=$(ssh "$remote_user@$remote_host" "echo $remote_path")
            echo "Preparing to download: $remote_user@$remote_host:$remote_path"

            if ssh "$remote_user@$remote_host" "[ -d \"$remote_path\" ]"; then
                echo "Downloading directory: $remote_user@$remote_host:$remote_path"
                scp -r "$remote_user@$remote_host:$remote_path" "$local_download_dir"
               if [[ $? -eq 0 ]]; then
                    echo "Directory download complete: $remote_user@$remote_host:$remote_path"
                else
                    echo "Error: Failed to download directory $remote_path"
                fi
            elif ssh "$remote_user@$remote_host" "[ -f \"$remote_path\" ]"; then
                echo "Downloading file: $remote_user@$remote_host:$remote_path"
                scp "$remote_user@$remote_host:$remote_path" "$local_download_dir"
                if [[ $? -eq 0 ]]; then
                    echo "File download complete: $remote_user@$remote_host:$remote_path"
                else
                    echo "Error: Failed to download file $remote_path"
                fi
            else
                echo "Error: $remote_user@$remote_host:$remote_path is neither a file nor a directory."
            fi
        }
        navigate_directory "~"
          
      '';
    };
  };}
