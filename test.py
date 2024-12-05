import subprocess

def run_git_command(command, error_message):
    """
    Runs a Git command and logs errors with explanations if the command fails.
    """
    try:
        result = subprocess.run(command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(result.stdout.strip())
    except subprocess.CalledProcessError as e:
        print(f"Error: {error_message}")
        print(f"Command: {' '.join(command)}")
        print(f"Git Output: {e.stderr.strip()}")

# Step 1: Log out the global Git user
print("Logging out of Git...")
run_git_command(["git", "config", "--global", "--unset", "user.name"], "Failed to unset Git global username.")
run_git_command(["git", "config", "--global", "--unset", "user.email"], "Failed to unset Git global email.")
run_git_command(["git", "credential-cache", "exit"], "Failed to clear Git credential cache.")
print("Logged out of Git.")

# Step 2: Login user
print("Logging in user QuackHack-McBlindy...")
run_git_command(["git", "config", "--global", "user.name", "QuackHack-McBlindy"], "Failed to set Git global username.")
run_git_command(["git", "config", "--global", "user.email", "quackhack.mcblindy@example.com"], "Failed to set Git global email.")
print("User QuackHack-McBlindy is logged in.")

# Step 3: Git add
print("Adding all changes...")
run_git_command(["git", "add", "."], "Failed to stage changes.")

# Step 4: Git commit
print("Committing changes...")
run_git_command(["git", "commit", "-m", "first commit"], "Failed to commit changes.")

# Step 5: Git push
print("Pushing changes...")
run_git_command(["git", "push"], "Failed to push changes.")

print("Git workflow completed.")
