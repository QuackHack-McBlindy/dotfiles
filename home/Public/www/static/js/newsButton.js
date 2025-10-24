async function playNews() {
  try {
    // Send POST request to play news
    const response = await fetch('http://192.168.1.28:6999/api/adb/play/news', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    });

    if (response.ok) {
      console.log('News playback triggered successfully.');
    } else {
      console.error('Failed to trigger news playback.');
    }
  } catch (error) {
    console.error('Error triggering news playback:', error);
  }
}

// Attach click event to play news
document.getElementById('newsButton').addEventListener('click', playNews);
