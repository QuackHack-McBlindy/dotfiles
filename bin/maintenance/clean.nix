# bin/clean.nix
{ config, self, pkgs, sysHosts, cmdHelpers, ... }:
{
    yo.scripts.clean = {
        description = "Run a total garbage collection: Removes old NixOS generations, empty trash, flush tmp files, whipes cache and runs a docker prune";
        category = "🧹 Maintenance";
        aliases = [ "gc" ];
        code = ''
            ${cmdHelpers}   
            # 1. Nix OS garbage collection
            run_cmd ${pkgs.nix}/bin/nix-collect-garbage -d
            run_cmd sudo ${pkgs.nix}/bin/nix-collect-garbage
              
            # 2. Empty user trash (adjust for each user if needed)
            # run_cmd rm -rf ~/.local/share/Trash/*
              
            # 3. Flush /tmp (be cautious if apps are using it)
            # run_cmd sudo rm -rf /tmp/*
             
            # 4. Wipe Nix store cache
            run_cmd sudo nix-store --gc
            run_cmd sudo nix-store --verify --check-contents --repair # optional but thorough
            run_cmd sudo ${pkgs.nix}/bin/nix-collect-garbage -d

            # 5. Remove unused Docker data
            # ANSI escape codes for bold and red text
            BOLD=$(tput bold)
            RED=$(tput setaf 1)
            GREEN=$(tput setaf 2)
            RESET=$(tput sgr0)

            # Docker prune Step 1: Remove dangling images, unused volumes (but keep running containers intact)
            run_cmd echo "Cleaning up dangling images and unused volumes..."
            run_cmd docker image prune -f
            run_cmd docker volume prune -f
    
            # Step 2: Retrieve all image IDs
            all_images=$(docker images -q)

            if [ -z "$all_images" ]; then
                run_cmd echo "No images found after cleanup."
                run_cmd exit 0
            fi

            # Step 3: Try to remove all images (without force) but only if they are NOT in use by containers
            run_cmd echo "Attempting to remove all unused images without force..."
            run_cmd docker rmi $(docker images -q --filter "dangling=true") 2>/dev/null

            # Step 4: Retrieve all image IDs again (after first removal attempt)
            remaining_images=$(docker images -q)
            if [ -z "$remaining_images" ]; then
                run_cmd echo "No images remain after initial removal."
                run_cmd exit 0
            fi
            # Initialize a flag for 'Remove All' option
            remove_all=false

            # Step 5: Loop through remaining images
            for image_id in $remaining_images; do
                # Get the stopped containers using the image
                containers=$(docker ps -a -q --filter "ancestor=$image_id")
                if [ -n "$containers" ]; then
                    container_names=$(docker ps -a --filter "ancestor=$image_id" --format "{{.Names}}")

                    # Step 6: Prompt user (with existing prompt style)
                    if [ "$remove_all" = false ]; then
                        run_cmd echo "The following containers are using image $image_id:"
                        run_cmd echo "''${BOLD}''${RED}$container_names''${RESET}"  # Escaped for Nix interpolation
                        run_cmd echo "Do you want to forcefully remove this image and its containers? (Y/N/A)"
                        run_cmd read -rp "(Y = Yes, N = No, A = Remove all remaining images with force): " choice
                    fi
                    # Handle user choice (case-insensitive)
                    case "$choice" in
                        [Yy]*)  # Handle Y or y as "Yes"
                            run_cmd docker rm $containers
                            run_cmd docker rmi -f $image_id
                            run_cmd echo -e "\nRemoved image $image_id and its containers.\n"
                            ;;
                        [Aa]*)  # Handle A or a as "Remove all remaining images with force"
                            remove_all=true
                            run_cmd docker rm $containers
                            run_cmd docker rmi -f $image_id
                            run_cmd echo -e "\nForcefully removed image $image_id and its containers.\n"
                            ;;
                        *)  # Handle any other input (N or invalid) as "No"
                            run_cmd echo -e "\nSkipping image $image_id.\n"
                            ;;
                    esac
                else
                    run_cmd echo "No containers found for image $image_id. Attempting to remove..."
                    run_cmd docker rmi $image_id
                    if [ $? -eq 0 ]; then
                        run_cmd echo "Image $image_id removed successfully."
                    else
                        run_cmd echo "Failed to remove image $image_id."
                    fi
                fi
            done
            run_cmd echo "Process completed."
            # Run docker system df to display current Docker disk usage
            run_cmd echo -e "\nCurrent Docker disk usage:"
            run_cmd docker system df
            # Prompt user if they want to prune the build cache
            run_cmd read -rp "Do you want to prune the Docker build cache? This will free up build cache layers (Y/N): " prune_choice
            # If the user chooses 'Y' or 'y', run docker builder prune -a -f
            if [[ "$prune_choice" =~ ^[Yy]$ ]]; then
                run_cmd echo "Pruning Docker build cache..."
                run_cmd docker builder prune -a -f
                run_cmd echo "Build cache pruned."
            fi
            # Run docker system df again to show the new disk usage
            run_cmd echo -e "\nUpdated Docker disk usage after pruning:"
            run_cmd docker system df
            # Display free space and percentage in /home with color coding
            run_cmd df -h ~ | awk 'NR==2 {
                free_space=$4;
                used_percent=$5;
                gsub("%", "", used_percent);
                green="\033[32m";
                red="\033[31m";
                reset="\033[0m";
                if (used_percent > 65) {
                    color=red;
                } else {
                    color=green;
                }
                printf "Free space: %s, Used: %s%s%s\n", free_space, color, $5, reset;
            }'
        '';
    };}  
