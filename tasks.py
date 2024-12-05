from invoke import task
import subprocess


@task
def push(ctx, commit=None):
    """
    Add, commit, and push changes to the Git repository.

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
