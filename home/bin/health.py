import curses
import time
import psutil
import paramiko  # for SSH to remote hosts

# Function to retrieve system stats from a remote machine using SSH
def get_remote_stats(host, username, password):
    try:
        # Set up SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=username, password=password)

        # Get CPU usage
        stdin, stdout, stderr = ssh.exec_command("top -bn1 | grep 'Cpu(s)'")
        cpu_line = stdout.read().decode('utf-8').strip()
        cpu_usage = float(cpu_line.split()[1].replace('%', ''))

        # Get memory usage
        stdin, stdout, stderr = ssh.exec_command("free -m | grep Mem:")
        memory_line = stdout.read().decode('utf-8').strip()
        memory_total, memory_used = map(int, memory_line.split()[1:3])
        memory_usage = (memory_used / memory_total) * 100

        # Get CPU temperature (requires specific platform support, i.e., Linux)
        temp = None
        try:
            stdin, stdout, stderr = ssh.exec_command("sensors | grep 'Core 0' | awk '{print $3}'")
            temp_line = stdout.read().decode('utf-8').strip()
            temp = float(temp_line.replace('°C', '')) if temp_line else None
        except Exception:
            temp = None

        ssh.close()

        return cpu_usage, memory_usage, temp
    except Exception as e:
        return None, None, None  # Return None if connection fails or stats cannot be fetched

# Function to display UI
def draw_ui(stdscr, hosts, credentials):
    # Clear screen
    stdscr.clear()

    # Set up colors
    curses.start_color()
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)

    # Main loop
    while True:
        stdscr.clear()

        # Display local system stats
        cpu_usage = psutil.cpu_percent(interval=1)
        memory_usage = psutil.virtual_memory().percent
        local_temp = None

        # Check local CPU temperature (Linux only)
        try:
            temp_info = psutil.sensors_temperatures()
            if temp_info and 'coretemp' in temp_info:
                local_temp = temp_info['coretemp'][0].current
        except Exception as e:
            local_temp = None

        stdscr.addstr(1, 1, "Local Computer:", curses.color_pair(3))

        # Display CPU Usage and bar for local system
        stdscr.addstr(2, 1, f"CPU Usage: {cpu_usage:.2f}%")
        stdscr.addstr(3, 1, "CPU Bar: ")
        for i in range(50):
            if i < cpu_usage // 2:
                stdscr.addstr(3, 10 + i, "=", curses.color_pair(2))
            else:
                stdscr.addstr(3, 10 + i, "=", curses.color_pair(1))

        # Display Memory Usage and bar for local system
        stdscr.addstr(4, 1, f"Memory Usage: {memory_usage:.2f}%")
        stdscr.addstr(5, 1, "Memory Bar: ")
        for i in range(50):
            if i < memory_usage // 2:
                stdscr.addstr(5, 13 + i, "=", curses.color_pair(2))
            else:
                stdscr.addstr(5, 13 + i, "=", curses.color_pair(1))

        if local_temp:
            stdscr.addstr(6, 1, f"CPU Temp: {local_temp:.2f}°C")
        else:
            stdscr.addstr(6, 1, "CPU Temp: N/A")

        row = 8  # Start the next row for remote machines
        # Display stats for each remote host
        for host in hosts:
            cpu_usage, memory_usage, temp = get_remote_stats(host, credentials['username'], credentials['password'])

            stdscr.addstr(row, 1, f"{host['name']} ({host['ip']}):", curses.color_pair(3))

            if cpu_usage is None or memory_usage is None:
                stdscr.addstr(row + 1, 1, "Error retrieving stats.", curses.color_pair(2))
                row += 3
            else:
                # Display CPU Usage and bar
                stdscr.addstr(row + 1, 1, f"CPU Usage: {cpu_usage:.2f}%")
                stdscr.addstr(row + 2, 1, "CPU Bar: ")
                for i in range(50):
                    if i < cpu_usage // 2:
                        stdscr.addstr(row + 2, 10 + i, "=", curses.color_pair(2))
                    else:
                        stdscr.addstr(row + 2, 10 + i, "=", curses.color_pair(1))

                # Display Memory Usage and bar
                stdscr.addstr(row + 3, 1, f"Memory Usage: {memory_usage:.2f}%")
                stdscr.addstr(row + 4, 1, "Memory Bar: ")
                for i in range(50):
                    if i < memory_usage // 2:
                        stdscr.addstr(row + 4, 13 + i, "=", curses.color_pair(2))
                    else:
                        stdscr.addstr(row + 4, 13 + i, "=", curses.color_pair(1))

                if temp is not None:
                    stdscr.addstr(row + 5, 1, f"CPU Temp: {temp:.2f}°C")
                else:
                    stdscr.addstr(row + 5, 1, "CPU Temp: N/A")

                row += 7

        # Refresh the screen to show updates
        stdscr.refresh()

        # Wait for a moment before updating
        time.sleep(2)

# List of host machines to monitor
hosts = [
    {"name": "Laptop", "ip": "192.168.1.131"},
    {"name": "Homie", "ip": "192.168.1.181"},
    {"name": "Nasty", "ip": "192.168.1.28"},
    {"name": "Pi", "ip": "192.168.1.158"}
]
credentials = {"username": "your_username", "password": "your_password"}

# Initialize curses and start the UI
curses.wrapper(lambda stdscr: draw_ui(stdscr, hosts, credentials))
