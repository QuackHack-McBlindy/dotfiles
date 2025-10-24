let previousVolume = 50; // Set initial volume to 50%

function updateadbVolume() {
    const adbvolumeSlider = document.getElementById("adbVolumeSlider");
    const currentVolume = parseInt(adbvolumeSlider.value);

    if (currentVolume > previousVolume) {
        // User moved the slider up
        sendVolumeChange('/api/adb/volume_up');
    } else if (currentVolume < previousVolume) {
        // User moved the slider down
        sendVolumeChange('/api/adb/volume_down');
    }

    // Update previousVolume to currentVolume for the next input event
    previousVolume = currentVolume;
}

function sendVolumeChange(endpoint) {
    fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({}) // Send an empty object or any relevant data if needed
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        console.log('Success:', data);
    })
    .catch(error => {
        console.error('Error:', error);
    });
}
