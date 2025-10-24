async function updateState(buttonId, stateUrl, toggleUrl, stateName) {
  try {
    // Fetch current state
    const response = await fetch(stateUrl);
    const data = await response.json();
    const isOn = data.is_on;

    // Update button color based on state
    const button = document.getElementById(buttonId);
    if (isOn) {
      button.style.backgroundColor = 'green'; // Set color for 'on' state
      button.textContent = `${stateName} Playing`;
    } else {
      button.style.backgroundColor = 'red'; // Set color for 'off' state
      button.textContent = `${stateName} Stopped`;
    }
  } catch (error) {
    console.error(`Error fetching ${stateName} state:`, error);
  }
}

async function toggleState(buttonId, toggleUrl, stateName) {
  try {
    // Send POST request to toggle state
    const response = await fetch(toggleUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    });

    const data = await response.json();

    // Update button color based on new state
    const button = document.getElementById(buttonId);
    if (data.is_on) {
      button.style.backgroundColor = 'green'; // Set color for 'on' state
      button.textContent = `${stateName} Playing`;
    } else {
      button.style.backgroundColor = 'red'; // Set color for 'off' state
      button.textContent = `${stateName} Stopped`;
    }
  } catch (error) {
    console.error(`Error toggling ${stateName} state:`, error);
  }
}

// Attach click event handlers
document.getElementById('playplaylistButton').addEventListener('click', () => {
  toggleState('playplaylistButton', 'http://192.168.1.28:6999/api/db/toggle/cast', 'Playlist');
});
document.getElementById('youtubeButton').addEventListener('click', () => {
  toggleState('youtubeButton', 'http://192.168.1.28:6999/api/db/toggle/youtube_state', 'YouTube');
});
document.getElementById('spotifyButton').addEventListener('click', () => {
  toggleState('spotifyButton', 'http://192.168.1.28:6999/api/db/toggle/spotify_state', 'Spotify');
});

// Initialize button states on load
updateState('playplaylistButton', 'http://192.168.1.28:6999/api/db/check/cast', 'http://192.168.1.28:6999/api/db/toggle/cast', 'Playlist');
updateState('youtubeButton', 'http://192.168.1.28:6999/api/db/check/youtube_state', 'http://192.168.1.28:6999/api/db/toggle/youtube_state', 'YouTube');
updateState('spotifyButton', 'http://192.168.1.28:6999/api/db/check/spotify_state', 'http://192.168.1.28:6999/api/db/toggle/spotify_state', 'Spotify');


