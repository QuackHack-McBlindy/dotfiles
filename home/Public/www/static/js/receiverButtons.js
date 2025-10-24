// Function to toggle the visibility of control sets
function toggleControls(controlType) {
    // Default elements
    const defaultAlbumCover = document.getElementById('defaultAlbumCover');
    const defaultVolumeControl = document.getElementById('defaultVolumeControl');
    const defaultTrackInfo = document.getElementById('defaultTrackInfo');
    const defaultControls = document.getElementById('defaultControls');
    
    // Spotify elements
    const spotifyAlbumCover = document.getElementById('spotifyAlbumCover');
    const spotifyVolumeControl = document.getElementById('spotifyVolumeControl');
    const spotifyTrackInfo = document.getElementById('spotifyTrackInfo');
    const spotifyControls = document.getElementById('spotifyControls');
    
    // ADB elements
    const adbAlbumCover = document.getElementById('adbAlbumCover');
    const adbVolumeControl = document.getElementById('adbVolumeControl');
    const adbTrackInfo = document.getElementById('adbTrackInfo');
    const adbControls = document.getElementById('adbControls');
    
    // Hide all elements initially
    defaultAlbumCover.style.display = 'none';
    defaultVolumeControl.style.display = 'none';
    defaultTrackInfo.style.display = 'none';
    defaultControls.classList.remove('active');
    
    spotifyAlbumCover.style.display = 'none';
    spotifyVolumeControl.style.display = 'none';
    spotifyTrackInfo.style.display = 'none';
    spotifyControls.classList.remove('active');
    
    adbAlbumCover.style.display = 'none';
    adbVolumeControl.style.display = 'none';
    adbTrackInfo.style.display = 'none';
    adbControls.classList.remove('active');
    
    // Display selected mode elements
    if (controlType === 'default') {
        defaultAlbumCover.style.display = 'block';
        defaultVolumeControl.style.display = 'block';
        defaultTrackInfo.style.display = 'block';
        defaultControls.classList.add('active');
    } else if (controlType === 'spotify') {
        spotifyAlbumCover.style.display = 'block';
        spotifyVolumeControl.style.display = 'block';
        spotifyTrackInfo.style.display = 'block';
        spotifyControls.classList.add('active');
    } else if (controlType === 'adb') {
        adbAlbumCover.style.display = 'block';
        adbVolumeControl.style.display = 'block';
        adbTrackInfo.style.display = 'block';
        adbControls.classList.add('active');
    }
}

// Function to handle button clicks
function handleButtonClick(buttonId) {
    const buttons = document.querySelectorAll('.state_button');
    const clickedButton = document.getElementById(buttonId);

    // Check if the clicked button is already active
    const isActive = clickedButton.classList.contains('active');

    // Deactivate all buttons and hide all control sets
    buttons.forEach(button => {
        button.classList.remove('active');
    });

    // Determine which controls to show
    if (isActive) {
        // If the clicked button is already active, toggle it off and show default controls
        clickedButton.classList.remove('active');
        toggleControls('default');
    } else {
        // Activate the clicked button
        clickedButton.classList.add('active');
        
        // Toggle appropriate controls based on the button clicked
        if (buttonId.startsWith('spotify')) {
            toggleControls('spotify');
            // Deactivate the adb button if switching to spotify
            document.getElementById('adbButton').classList.remove('active');
        } else if (buttonId.startsWith('adb')) {
            toggleControls('adb');
            // Deactivate the spotify button if switching to adb
            document.getElementById('spotifyButton').classList.remove('active');
        }
    }
}

// Event listeners for the buttons
document.getElementById('spotifyButton').addEventListener('click', () => handleButtonClick('spotifyButton'));
document.getElementById('adbButton').addEventListener('click', () => handleButtonClick('adbButton'));

// Initial setup to show only default controls on page load
window.onload = function() {
    toggleControls('default'); // Ensure only default controls are shown
};

async function fetchNowPlaying() {
    try {
        const response = await fetch("http://192.168.1.28:6999/api/adb/now-playing");
        if (response.ok) {
            let data = await response.text();  // Get the response as plain text

            // Remove leading and trailing quotes if present
            data = data.trim();
            if (data.startsWith('"') && data.endsWith('"')) {
                data = data.slice(1, -1);  // Remove the leading and trailing quotes
            }

            // Apply templating to the URL if it matches the specified domain
            if (data.startsWith("https://qwackify.duckdns.org/")) {
                const parts = data.split("/");
                if (parts.length > 5) {
                    data = parts.slice(4).join("/").replace("/", " - ");
                }
            }

            document.getElementById("adbTrackInfo").innerText = data;
        } else {
            document.getElementById("adbTrackInfo").innerText = "Error fetching data";
        }
    } catch (error) {
        document.getElementById("adbTrackInfo").innerText = "Request failed";
    }
}

// Fetch data on page load
fetchNowPlaying();
