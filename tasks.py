import os
import subprocess
from invoke import task

GITHUB_USER = "QuackHack-McBlindy"
GITHUB_REPO = "dotfiles"



#def is_git_repo():
 #   """Check if the current directory is a Git repository."""
 #   return os.path.isdir(".git")


#@task
#def push(ctx, commit=None):
#    """
#    Push dotfiles directory to GitHub repo.

#    :param ctx: Invoke context.
#    :param commit: Commit message (optional). Defaults to "Updated files".
#    """
    # Default commit message if none provided
#    commit_message = commit or "Updated files"

    # Check if the directory is a Git repository
#    if not is_git_repo():
 #       print("No Git repository found. Initializing new repository.")
        # Initialize the repository if not found
 #       ctx.run("git init", echo=True)
  #      ctx.run(f"git remote add origin https://github.com/{GITHUB_USER}/{GITHUB_REPO}.git", echo=True)
    
    # Ensure there's at least one commit in the repository
  #  status = subprocess.run(
 #      ["git", "status", "--porcelain"], capture_output=True, text=True
 #   )
    
#   if not status.stdout.strip():
 #       print("No commits yet. Creating an initial commit.")
 #       # Create an initial commit if the repo is empty
  #      ctx.run("git add .", echo=True)
 #       ctx.run(f'git commit -m "Initial commit"', echo=True)

    # Check if there are changes to commit
 #   status = subprocess.run(
#        ["git", "status", "--porcelain"], capture_output=True, text=True
 #   )
 #   if not status.stdout.strip():
  #      print("No changes to commit. Exiting.")
 #      return

    # Run Git commands
 #   ctx.run("git add .", echo=True)
#    ctx.run(f'git commit -m "{commit_message}"', echo=True)
    
    # Check the current branch name (if not `main`, use the appropriate branch name)
 #   current_branch = subprocess.run(
  #      ["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True
#    ).stdout.strip()

    # If the branch is still unnamed, we need to create a branch and push it
#    if current_branch == "HEAD":
#        ctx.run("git checkout -b main", echo=True)
    
    # Push to the correct branch
#    ctx.run(f"git push origin {current_branch}", echo=True)


def is_git_repo():
    """Check if the current directory is a Git repository."""
    return os.path.isdir(".git")


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
@task
def pull(ctx, host=None):
    """
    Pull dotfiles from GitHub to a host, or all if none provided.

    :param ctx: Invoke context.
    :param host: Optional hostname to pull from. If omitted, pulls from all available hosts.
    """
    hosts = {
        "desktop",
        "lappy",
        
    }

    if host:
        print(f"Pulling for specific host: {host}")
        _pull_for_host(ctx, host)
    else:
        for name, hostname in hosts.items():
            print(f"Pulling for host: {name} ({hostname})")
            _pull_for_host(ctx, hostname)


def _pull_for_host(ctx, hostname):
    """
    Helper function to pull changes for a specific host.

    :param ctx: Invoke context.
    :param hostname: Hostname to pull from.
    """
    try:
        ctx.run(f"ssh {hostname} 'cd /path/to/repo && git pull'", warn=True, echo=True)
    except Exception as e:
        print(f"Failed to pull for host {hostname}: {e}")
        

@task
def install(ctx, host=None):
    """
    Install NixOS on the specified host.

    :param ctx: Invoke context.
    :param host: hostname to install NixOS on.
    """
    hosts = [
        "desktop",
        "lappy",
        "usb",
    ]

    if host:
        print(f"Installing on: {host}")
        # Adjust the Nix command accordingly
        nix_run_command = f"nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake github:user/repo#{host} --target-host root@{host}"
        print(f"Running: {nix_run_command}")
    else:
        for hostname in hosts:
            print(f"Installing on: {hostname}")
            # Adjust the Nix command accordingly
            nix_run_command = f"nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake github:user/repo#{hostname} --target-host root@usb"
            print(f"Running: {nix_run_command}")
            
            
            

@task
def rebuild(ctx, host=None):
    """
    Rebuild and switch NixOS configuration on the specified host using flakes.

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

