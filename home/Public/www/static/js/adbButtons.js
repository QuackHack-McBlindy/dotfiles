// Reconnect Button
document.getElementById('adbreconnect')?.addEventListener('click', () => {
    console.log('Reconnect button clicked');
    fetch('/api/adb/reconnect', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Reconnected:', data))
        .catch(error => console.error('Error:', error));
});

// Previous Button
document.getElementById('adbprevButton')?.addEventListener('click', () => {
    console.log('Previous button clicked');
    fetch('/api/adb/previous_track', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Previous Track:', data))
        .catch(error => console.error('Error:', error));
});

// Play/Pause Button
document.getElementById('adbplayPauseButton')?.addEventListener('click', () => {
    console.log('Play/Pause button clicked');
    fetch('/api/adb/play_pause', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Play/Pause:', data))
        .catch(error => console.error('Error:', error));
});

// Next Button
document.getElementById('adbnextButton')?.addEventListener('click', () => {
    console.log('Next button clicked');
    fetch('/api/adb/next_track', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Next Track:', data))
        .catch(error => console.error('Error:', error));
});

// Power Toggle Button
document.getElementById('adbpower')?.addEventListener('click', () => {
    console.log('Power button clicked');
    fetch('/api/adb/power_on', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Power Toggled:', data))
        .catch(error => console.error('Error:', error));
});
