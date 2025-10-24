async function playPlaylist() {
  try {
    // Send POST request to play playlist
    const response = await fetch('http://192.168.1.28:6999/api/adb/play/playlist', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    });

    if (response.ok) {
      console.log('Playlist successfully sent via ADB.');
    } else {
      console.error('Failed to send playlist via ADB.');
    }
  } catch (error) {
    console.error('Error sending playlist via ADB:', error);
  }
}

// Attach click event to play news
document.getElementById('playplaylistButton').addEventListener('click', playPlaylist);
