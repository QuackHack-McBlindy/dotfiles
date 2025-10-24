document.addEventListener('DOMContentLoaded', () => {
    const playlistButton = document.getElementById('playlistButton');
    const playlistContainer = document.getElementById('playlistContainer');
    const audioElement = document.getElementById('audio');
    const audioSource = document.getElementById('audioSource');
    let playlistVisible = false;

    // Toggle Playlist
    playlistButton.addEventListener('click', () => {
        playlistVisible = !playlistVisible;
        if (playlistVisible) {
            playlistContainer.classList.add('open');   // Add 'open' class to show
            playlistButton.textContent = 'playlist_remove';
        } else {
            playlistContainer.classList.remove('open'); // Remove 'open' class to hide
            playlistButton.textContent = 'playlist_add';
        }
    });

    // Function to dynamically set the audio source
    function setAudioSource(src) {
        audioSource.src = src;
        audioElement.load(); // Reload the audio element to apply the new source
        audioElement.play(); // Play the new audio
    }

    // Function to load playlist from the server
    function loadPlaylist() {
        fetch('/api/playlist')
            .then(response => response.json())
            .then(data => {
                const playlistContainer = document.querySelector('.playlist-items');
                playlistContainer.innerHTML = ''; // Clear the current playlist items

                // Loop through the playlist and add items to the container
                data.playlist.forEach((item) => {
                    const listItem = document.createElement('div');
                    listItem.classList.add('playlist-item');
                    listItem.textContent = item; // Use the file name as the content

                    // Add click event to play the selected item
                    listItem.addEventListener('click', () => {
                        const filePath = `/media/${item}`; // Adjust this path based on your server
                        setAudioSource(filePath);
                    });

                    playlistContainer.appendChild(listItem);
                });
            })
            .catch(error => console.error('Error loading playlist:', error));
    }

    // Load the playlist when the page loads
    loadPlaylist();

    // Auto-refresh the playlist every 5 seconds (optional)
    setInterval(loadPlaylist, 5000);  // Auto-refresh the playlist every 5 seconds
});
