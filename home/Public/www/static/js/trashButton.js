document.addEventListener('DOMContentLoaded', () => {
    const playlistTrashButton = document.getElementById('playlistTrashButton');
    let holdTimer;

    // Function to send the POST request
    const clearPlaylist = () => {
        fetch('/api/playlist/clear', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ output_playlist: "/srv/mergerfs/Pool/playlist.m3u" })
        })
        .then(response => response.ok ? console.log("Playlist cleared successfully.") : console.error("Failed to clear the playlist."))
        .catch(error => console.error("Error:", error));
    };

    // Add event listeners for holding the button
    const startHoldTimer = () => {
        holdTimer = setTimeout(clearPlaylist, 2000); // Trigger after 2 seconds hold
    };

    const cancelHoldTimer = () => {
        clearTimeout(holdTimer);
    };

    playlistTrashButton.addEventListener('mousedown', startHoldTimer);
    playlistTrashButton.addEventListener('mouseup', cancelHoldTimer);
    playlistTrashButton.addEventListener('mouseleave', cancelHoldTimer);
});

