import os
import re
import subprocess
from invoke import task

GITHUB_USER = "QuackHack-McBlindy"
GITHUB_REPO = "dotfiles"

# Define the paths
root_readme = 'README.md'
hosts_dir = 'hosts'
host_files = {
    'desktop': 'desktop/README.md',
    'laptop': 'laptop/README.md',
    'nasty': 'nasty/README.md',
    'homie': 'homie/README.md'
}

# Define the unique placeholders for each host
placeholders = {
    'desktop': '<!-- INSERT_DESKTOP_README_CONTENT_HERE -->',
    'laptop': '<!-- INSERT_LAPTOP_README_CONTENT_HERE -->',
    'nasty': '<!-- INSERT_NASTY_README_CONTENT_HERE -->',
    'homie': '<!-- INSERT_HOMIE_README_CONTENT_HERE -->'
}

# List of hosts to include (modify as needed)
hosts_to_include = ['desktop', 'laptop', 'nasty', 'homie']


# Function to extract modules and generate links
def extract_modules(config_file):
    modules_info = []
    with open(config_file, 'r') as file:
        content = file.read()
        # Extract module paths
        modules_match = re.findall(r'imports\s*=\s*\[([^\]]+)\]', content)
        if modules_match:
            modules_info.append('### Modules:')
            for module in modules_match[0].splitlines():
                if module.strip():  # Exclude empty lines
                    # Clean up the path, removing the leading `..` if present
                    module_path = module.strip().replace('./', '').replace('#', '').lstrip('..')
                    if module_path:
                        modules_info.append(f'`{module_path}` (link: https://github.com/your-repo/{module_path})')
    return modules_info

# Extract bootloader section from the configuration file
def extract_bootloader(config_file):
    bootloader_info = []
    with open(config_file, 'r') as file:
        content = file.read()
        bootloader_match = re.search(r'boot\.loader\s*=\s*{([^}]+)}', content)
        if bootloader_match:
            bootloader_info.append('### Bootloader Configuration:')
            bootloader_info.append(f'```nix\n{bootloader_match.group(1).strip()}\n```')
    return bootloader_info


# Extract filesystem configuration from hardware-configuration.nix
def extract_filesystem(hardware_file):
    filesystem_info = []
    with open(hardware_file, 'r') as file:
        content = file.read()
        fs_match = re.findall(r'fileSystems\."([^"]+)"\s*=\s*\{([^}]+)\}', content)
        if fs_match:
            filesystem_info.append('### File System Configuration:')
            for fs in fs_match:
                filesystem_info.append(f'**{fs[0]}**: {fs[1].strip()}')
    return filesystem_info

# Extract hardware-related information
def extract_hardware(hardware_file):
    hardware_info = []
    with open(hardware_file, 'r') as file:
        content = file.read()
        hardware_match = re.search(r'hardware\.cpu\.intel\.updateMicrocode\s*=\s*lib\.mkDefault\s*([^;]+)', content)
        if hardware_match:
            hardware_info.append('### Hardware Configuration:')
            hardware_info.append(f'**CPU Microcode Update**: {hardware_match.group(1).strip()}')
    return hardware_info

# Function to remove previous sections from README.md
def remove_previous_sections(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            content = file.read()
        
        # Define markers for each section
        sections = [
            '### Modules:',
            '### Bootloader Configuration:',
            '### File System Configuration:',
            '### Hardware Configuration:'
        ]
        
        # Remove each section and everything following it until the next section
        for section in sections:
            content = re.sub(rf'({re.escape(section)}[\s\S]*?)(?=\n### |$)', '', content)
        
        # Write the cleaned content back to the file
        with open(file_path, 'w') as file:
            file.write(content)

# Write the extracted data into the README.md file, appending to it if it exists
def write_readme(modules, bootloader, filesystem, hardware, output_file='README.md'):
    # First, remove previous sections before appending new data
    remove_previous_sections(output_file)
    
    with open(output_file, 'a') as file:
        for section in [modules, bootloader, filesystem, hardware]:
            for line in section:
                file.write(line + '\n')
            file.write('\n')

# Main function to orchestrate the extraction and generation for each host directory
def process_host_directory(host_dir):
    config_file = os.path.join(host_dir, 'configuration.nix')  # Path to the NixOS configuration file
    hardware_file = os.path.join(host_dir, 'hardware-configuration.nix')  # Path to the hardware configuration file
    
    if os.path.exists(config_file) and os.path.exists(hardware_file):
        modules = extract_modules(config_file)
        bootloader = extract_bootloader(config_file)
        filesystem = extract_filesystem(hardware_file)
        hardware = extract_hardware(hardware_file)

        readme_file = os.path.join(host_dir, 'README.md')
        write_readme(modules, bootloader, filesystem, hardware, output_file=readme_file)
    else:
        print(f"Configuration or hardware file missing in {host_dir}, skipping...")

# Main function to process all host directories
def update_host_readme(base_dir='./hosts'):
    for root, dirs, files in os.walk(base_dir):
        for dir_name in dirs:
            host_dir = os.path.join(root, dir_name)
            process_host_directory(host_dir)

# Function to read and insert host README content
def insert_host_readme_content():
    # Read the root README file
    with open(root_readme, 'r') as file:
        content = file.readlines()

    # Loop through each host and insert content at the respective placeholder
    for host in hosts_to_include:
        # Find the placeholder for the current host
        placeholder = placeholders.get(host)
        if placeholder:
            insert_line = None
            for i, line in enumerate(content):
                if placeholder in line:
                    insert_line = i
                    break

            if insert_line is None:
                print(f"Placeholder for {host} not found in the root README.md.")
                continue

            # Read the content of the host README file
            host_file = host_files.get(host)
            if host_file and os.path.exists(os.path.join(hosts_dir, host_file)):
                with open(os.path.join(hosts_dir, host_file), 'r') as host_file_obj:
                    host_content = f"\n"
                    host_content += host_file_obj.read() + "\n"

                # Insert the content at the placeholder location
                content.insert(insert_line + 1, host_content)
            else:
                print(f"Host file for {host} does not exist.")

    # Write the modified content back to the root README
    with open(root_readme, 'w') as file:
        file.writelines(content)

    print(f"Inserted host README content into {root_readme}")




def is_git_repo():
    """Check if the current directory is a Git repository."""
    return os.path.isdir(".git")

def rainbow_text(text):
    # ANSI color codes for rainbow colors
    colors = [
        "\033[38;5;196m",  # Red
        "\033[38;5;202m",  # Orange
        "\033[38;5;226m",  # Yellow
        "\033[38;5;46m",   # Green
        "\033[38;5;51m",   # Cyan
        "\033[38;5;189m",  # Blue
        "\033[38;5;99m",   # Purple
        "\033[0m"          # Reset color
    ]
    
    # Iterate over the text and assign each character a color
    colored_text = ""
    color_index = 0
    for char in text:
        colored_text += f"{colors[color_index % len(colors)]}{char}\033[0m"
        color_index += 1

    return colored_text


###############
## BUILD
@task
def build(ctx, device):
    """
    Build & flash Watch/Box3 device.
    """
    if device == "watch":
        subprocess.run(["esphome", "run", "./hosts/watch/configuration.yaml"], check=True)
    elif device == "box3":
        subprocess.run(["esphome", "run", "./hosts/box3/configuration.yaml"], check=True)
    else:
        print(f"Unknown device: {device}. Please specify either 'watch' or 'box3'.")

###############



@task
def push(ctx, commit=None):
    """
    Push dotfiles directory to GitHub repo.

    :param ctx: Invoke context.
    :param commit: Commit message (optional). Defaults to "Updated files".
    """
  #  update_host_readme()
 #   insert_host_readme_content()
    # Default commit message if none provided
    commit_message = commit or "Updated files"

    # Check if the directory is a Git repository
    if not is_git_repo():
        print("No Git repository found. Initializing new repository.")
        # Initialize the repository if not found
        ctx.run("git init", echo=True)
        ctx.run(f"git remote add origin https://github.com/{GITHUB_USER}/{GITHUB_REPO}.git", echo=True)
    
    # Ensure there's at least one commit in the repository
    status = subprocess.run(
       ["git", "status", "--porcelain"], capture_output=True, text=True
    )
    
    if not status.stdout.strip():
        print("No commits yet. Creating an initial commit.")
        # Create an initial commit if the repo is empty
        ctx.run("git add .", echo=True)
        ctx.run(f'git commit -m "Initial commit"', echo=True)

    # Check if there are changes to commit
    status = subprocess.run(
        ["git", "status", "--porcelain"], capture_output=True, text=True
    )
    if not status.stdout.strip():
        print("No changes to commit. Exiting.")
        return

    # Run Git commands
    ctx.run("git add .", echo=True)
    ctx.run(f'git commit -m "{commit_message}"', echo=True)
    
    # Check the current branch name (if not `main`, use the appropriate branch name)
    current_branch = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True
    ).stdout.strip()

    # If the branch is still unnamed, we need to create a branch and push it
    if current_branch == "HEAD":
        ctx.run("git checkout -b main", echo=True)
    
    # Push to the correct branch
    ctx.run(f"git push origin {current_branch}", echo=True)
    print(" ")
    print(" ")
    print("🚀🚀🚀🚀💫 ")
    print(rainbow_text("✨✨ Successfully pushed dotfiles to GitHub!"))
    

@task
def pull(ctx):
    """
    Pulls dotfiles from GitHub repo.

    :param ctx: Invoke context.
    """
    result_checkout = ctx.run("git checkout -- .", echo=True)
    result_pull = ctx.run("git pull origin main", echo=True)

    if result_checkout.return_code == 0 and result_pull.return_code == 0:
        print(" ")
        print(" ")
        print("🚀🚀🚀🚀 ✨ ")
        print(rainbow_text("✨✨ Successfully pulled the latest dotfiles repository!"))
    else:
        print("\033[1;31m [ WARNING! ] \033[0m")  
        print("\033[1;31mAn error occurred while pulling the latest changes.\033[0m")
      
############
## INSTALL 

#@task
#def install(ctx, host=None):
#    """
#    Install NixOS on the specified host.

#    :param ctx: Invoke context.
#    :param host: hostname to install NixOS on.
#    """
#    hosts = [
#        "desktop",
#        "lappy",
#        "usb",
#    ]

#    if host:
#        print(f"Installing on: {host}")
#        # Adjust the Nix command accordingly
#        nix_run_command = f"nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake github:user/repo#{host} --target-host root@{host}"
#        print(f"Running: {nix_run_command}")
#    else:
#        for hostname in hosts:
#            print(f"Installing on: {hostname}")
#            # Adjust the Nix command accordingly
#            nix_run_command = f"nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake github:user/repo#{hostname} --target-host root@usb"
#            print(f"Running: {nix_run_command}")
            
            
            
######################
# SWITCH 

@task
def switch(ctx, host=None):
    """
    Rebuild and switch NixOS configuration on the specified host.

    :param ctx: Invoke context.
    :param host: Optional hostname to rebuild on. If omitted, defaults to 'laptop'.
    """
    # Default host (flake) is 'laptop' if not specified
    target_host = host or "laptop"
    
    print(f"Rebuilding and switching on: {target_host}")

    # Construct the nixos-rebuild command
    nixos_rebuild_command = f"sudo nixos-rebuild switch --flake github:QuackHack-McBlindy/dotfiles#{target_host}"

    # Run the command on the specified host
    if host:
        # If a host is provided, rebuild on that specific host
        print(f"Running: {nixos_rebuild_command} on {host}")
        ctx.run(f"ssh {host} '{nixos_rebuild_command}'", echo=True)
    else:
        # Run the rebuild for the default host (laptop)
        print(f"Running: {nixos_rebuild_command} on {target_host}")
        ctx.run(f"ssh {target_host} '{nixos_rebuild_command}'", echo=True)

