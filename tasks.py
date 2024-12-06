from invoke import task
import subprocess


@task
def push(ctx, commit=None):
    """
    Push dotfiles directory to GitHub repo.

    :param ctx: Invoke context.
    :param commit: Commit message (optional). Defaults to "Updated files".
    """
    # Default commit message if none provided
    commit_message = commit or "Updated files"

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
    ctx.run("git push", echo=True)


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
