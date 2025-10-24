// Spotify Controls
document.getElementById('spotifyshuffle').addEventListener('click', () => {
    fetch('/api/spotify/player/shuffle', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Spotify Shuffle:', data))
        .catch(error => console.error('Error:', error));
});

document.getElementById('spotifyprevButton').addEventListener('click', () => {
    fetch('/api/spotify/player/previous', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Spotify Previous Track:', data))
        .catch(error => console.error('Error:', error));
});

document.getElementById('spotifyplayPauseButton').addEventListener('click', () => {
    fetch('/api/spotify/player/playback-state')
        .then(response => response.json())
        .then(data => {
            const isPlaying = data.is_playing; // Assuming response has 'is_playing'
            const endpoint = isPlaying ? '/api/spotify/player/pause' : '/api/spotify/player/play';
            fetch(endpoint, { method: 'POST' })
                .then(response => response.json())
                .then(data => console.log(isPlaying ? 'Spotify Paused' : 'Spotify Playing:', data))
                .catch(error => console.error('Error:', error));
        })
        .catch(error => console.error('Error:', error));
});

document.getElementById('spotifynextButton').addEventListener('click', () => {
    fetch('/api/spotify/player/next', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Spotify Next Track:', data))
        .catch(error => console.error('Error:', error));
});

document.getElementById('spotifyrepeat').addEventListener('click', () => {
    fetch('/api/spotify/player/repeat', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log('Spotify Repeat:', data))
        .catch(error => console.error('Error:', error));
});
