import os
import re
import json
import subprocess
from invoke import task

GITHUB_USER = "QuackHack-McBlindy"
GITHUB_REPO = "dotfiles"

SSH_USER = os.getenv("USER") or subprocess.run(["whoami"], capture_output=True, text=True).stdout.strip()
DOTFILES_DIR = f"/home/{SSH_USER}/dotfiles"

AGEKEYS_PATH = './hosts/agekeys.nix'
SECRETS_DIR = './secrets'
SOPS_CONFIG_PATH = '.sops.yaml'

def is_git_repo():
    """Check if the current directory is a Git repository."""
    return os.path.isdir(".git")

def rainbow_text(text):
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
    
    colored_text = ""
    color_index = 0
    for char in text:
        colored_text += f"{colors[color_index % len(colors)]}{char}\033[0m"
        color_index += 1

    return colored_text



###############
# PUSH

@task
def push(ctx, commit=None):
    """
    Push dotfiles directory to GitHub repo.

    :param ctx: Invoke context.
    :param commit: Commit message (optional). Defaults to "Updated files".
    """
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




@task
def deploy(c, hostname, local=False):
    """
    [hostname] --local (to build on the target machine, optional)

    Usage:
        invoke deploy HOSTNAME         # Build locally and deploy
        invoke deploy HOSTNAME --local # Rebuild remotely and apply configuration
    """
    ssh_target = f"{SSH_USER}@{hostname}"
    flake_attr = f".#nixosConfigurations.{hostname}.config.system.build.toplevel"

    if local:
        print(f"🚀 Rebuilding configuration on {hostname} using flakes...")
        subprocess.run([
            "ssh", ssh_target,
            f"sudo nixos-rebuild switch --flake {DOTFILES_DIR}#{hostname}"
        ], check=True)
    else:
        print(f"🔨 Building NixOS configuration locally for {hostname}...")
        subprocess.run(["nix", "build", flake_attr], check=True)

        print(f"🚀 Copying system closure to {hostname}...")
        subprocess.run([
            "nix", "copy", "--substitute-on-destination",
            "--to", f"ssh://{ssh_target}", "./result"
        ], check=True)

        print(f"🔄 Activating configuration on {hostname}...")
        subprocess.run([
            "ssh", ssh_target,
            f"sudo nixos-rebuild switch --flake {DOTFILES_DIR}#{hostname} --no-build"
        ], check=True)

    print("✅ Deployment complete!")

## BUILD

@task
def build(ctx, device):
    """
    --device [auto-installer] [watch] [box3] 
    """
    if device == "watch":
        result = subprocess.run(["esphome", "run", "./hosts/watch/configuration.yaml"], check=False)
        if result.returncode == 0:
            print(" ")
            print("🚀🚀🚀🚀 ✨ ")
            print(rainbow_text("✨✨ Successfully built & flashed the Smart-Watch, and it's ready to be used!"))
        else:
            print("\033[1;31m [ WARNING! ] \033[0m")
            print("\033[1;31m An error occurred while building/flashing the Smart-Watch! \033[0m")
            
    elif device == "box3":
        result = subprocess.run(["esphome", "run", "./hosts/box3/configuration.yaml"], check=False)
        if result.returncode == 0:
            print(" ")
            print("🚀🚀🚀🚀 ✨ ")
            print(rainbow_text("✨✨ Successfully built & flashed the Box3, and it's ready to be used!"))
        else:
            print("\033[1;31m [ WARNING! ] \033[0m")
            print("\033[1;31m An error occurred while building/flashing the Box3! \033[0m")
            
    elif device == "auto-installer":
        result = subprocess.run(["sudo", "nix", "build", ".#auto-installer", "--impure", "--show-trace"], check=False)
        
        if result.returncode == 0:
            print(" ")
            print(" ")
            print("🚀🚀🚀🚀 ✨ ")
            print(rainbow_text("✨✨ Successfully built the USB auto-installer!"))
            print(rainbow_text("✨ You can now dd the resulting iso image onto a USB drive! HINT: just type flash"))      
            print("\033[1;31m [ WARNING READ BELOW CAREFULLY! ] \033[0m")  
            print("\033[1;31m [ THE ISO IMAGE YOU ARE ABOUT TO USE IS 100% DESTRUCTIVE! ] \033[0m")  
            print("\033[1;31m [ IT WILL AUTOMATICALLY REMOVE ALL DATA CURRENTLY ON THE MACHINE WITHOUT ASKING! ] \033[0m")  
        else:
            print("\033[1;31m [ WARNING! ] \033[0m")  
            print("\033[1;31m An error occurred while building the USB auto installer! \033[0m")
    else:
        print(f"Unknown device: {device}. Please specify either 'watch', 'box3' or 'auto-installer'.")


@task
def get_github_url():
    """
    --device [auto-installer] [watch] [box3] 
    """
import os
import re
from pathlib import Path


    # Find .git directory
    git_dir = Path(".git")
    if not git_dir.exists():
        return None

    # Read git config
    config_path = git_dir / "config"
    try:
        with open(config_path, "r") as f:
            config_content = f.read()
    except FileNotFoundError:
        return None

    # Find origin URL
    match = re.search(r'\[remote "origin"\].*?url\s*=\s*(.+?)\n', 
                     config_content, re.DOTALL)
    if not match:
        return None

    url = match.group(1).strip()

    # Convert SSH URL to HTTPS format if needed
    if url.startswith("git@github.com:"):
        url = url.replace("git@github.com:", "https://github.com/")
    if url.endswith(".git"):
        url = url[:-4]
        print(f"GitHub Repository URL: {url}") 
    else:
        print("Error: Not a GitHub repository or no remote origin configured")
    return url




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

def read_agekeys():
    with open(AGEKEYS_PATH, 'r') as f:
        nix_content = f.read()

    # Parse the JSON-like Nix content, which we assume is a valid Nix expression that can be evaluated
    # This requires some custom handling or can be done with a Nix interpreter if needed.
    # For simplicity, here we just assume the data is valid JSON.
    try:
        keys = json.loads(nix_content)
        return keys
    except json.JSONDecodeError:
        raise ValueError("Failed to parse agekeys.nix. Ensure it's a valid JSON-like structure.")

# Generate .sops.yaml file content
def generate_sops_yaml(keys):
    sops_yaml = {
        "keys": [{"&" + k: v} for k, v in keys.items()],
        "creation_rules": [
            {
                "path_regex": r"\.yaml$",
                "key_groups": [
                    {"age": [{"*" + k: v} for k, v in keys.items()]}
                ]
            }
        ]
    }
    return sops_yaml

# Write the .sops.yaml file
def write_sops_yaml(sops_yaml):
    with open(SOPS_CONFIG_PATH, 'w') as f:
        json.dump(sops_yaml, f, indent=2)

# Decrypt files in ./secrets
def decrypt_secrets():
    # This assumes you are using sops to decrypt the files
    # Ensure you have a method to decrypt with old keys before proceeding
    for root, _, files in os.walk(SECRETS_DIR):
        for file in files:
            if file.endswith('.yaml'):
                file_path = os.path.join(root, file)
                print(f"Decrypting {file_path}...")
                subprocess.run(["sops", "--decrypt", file_path, "--output", file_path], check=True)

# Encrypt files in ./secrets with new keys
def encrypt_secrets():
    # Assuming that after updating .sops.yaml, we will encrypt using the new keys
    for root, _, files in os.walk(SECRETS_DIR):
        for file in files:
            if file.endswith('.yaml'):
                file_path = os.path.join(root, file)
                print(f"Encrypting {file_path}...")
                subprocess.run(["sops", "--encrypt", file_path, "--output", file_path], check=True)

@task
def update_keys(c):
    """
    Updates sops-nix config. Invoke this after updating agekeys.nix
    """
    # Step 1: Extract keys from agekeys.nix
    print("Reading keys from agekeys.nix...")
    keys = read_agekeys()

    # Step 2: Generate new .sops.yaml content
    print("Generating .sops.yaml...")
    sops_yaml = generate_sops_yaml(keys)

    # Step 3: Decrypt all secrets in ./secrets
    print("Decrypting existing secrets...")
    decrypt_secrets()

    # Step 4: Write the new .sops.yaml file
    print("Writing new .sops.yaml...")
    write_sops_yaml(sops_yaml)

    # Step 5: Re-encrypt all secrets in ./secrets
    print("Re-encrypting secrets with new keys...")
    encrypt_secrets()

    print("Process completed successfully.")



# Define the list of backup hosts
HOSTS = [
    "192.168.1.111",
    "192.168.1.28",
    "192.168.1.211"
]

@task
def backup(c, host=None):
    """Trigger a backup for all hosts or a specific host."""
    if host:
        if host in HOSTS:
            command = f"sudo systemctl start backup-{host}"
            print(f"Executing: {command}")
            subprocess.run(command, shell=True, check=True)
        else:
            print(f"Error: Host {host} not recognized.")
    else:
        for h in HOSTS:
            command = f"sudo systemctl start backup-{h}"
            print(f"Executing: {command}")
            subprocess.run(command, shell=True, check=True)

@task
def log(c, host):
    """Show logs for a specific backup job."""
    if host in HOSTS:
        command = f"sudo journalctl -u backup-{host} --no-pager --reverse"
        print(f"Executing: {command}")
        subprocess.run(command, shell=True, check=True)
    else:
        print(f"Error: Host {host} not recognized.")

