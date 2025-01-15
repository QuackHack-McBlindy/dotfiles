import os

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

# Run the function
insert_host_readme_content()
