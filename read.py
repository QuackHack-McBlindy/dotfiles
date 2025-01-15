import re
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
def main(base_dir='./hosts'):
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

# Run the function
insert_host_readme_content()

if __name__ == "__main__":
    main()  # Starts processing all host directories under ./hosts
