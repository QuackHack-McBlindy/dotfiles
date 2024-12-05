from invoke import task

@task
def push(ctx, commit):
    """
    Add, commit, and push changes to the Git repository.
    
    :param ctx: Invoke context.
    :param commit: Commit message.
    """
    ctx.run("git add .")
    ctx.run(f'git commit -m "{commit}"')
    ctx.run("git push")


