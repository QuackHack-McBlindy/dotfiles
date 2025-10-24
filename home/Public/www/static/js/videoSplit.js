const playPauseButton = document.getElementById('playPauseButton');
const playerContainer = document.getElementById('playerContainer');
const audioElement = document.getElementById('audio');
const videoElement = document.getElementById('video');

// Ensure the video frame is always visible but hidden initially
videoElement.style.visibility = 'hidden';

let isVideoPlaying = false; // Track if video should play after animation

playPauseButton.addEventListener('click', () => {
    console.log("Play/Pause button clicked");

    // Handle play/pause for video
    if (videoElement.style.display === 'block') {
        if (videoElement.paused) {
            videoElement.play().catch(() => {
                console.log("Playback requested...");
            });
        } else {
            videoElement.pause();
            playPauseButton.textContent = 'play_circle_filled';
            console.log("Paused video...");
            playerContainer.classList.remove('player-split');
        }
    } else {
        // Handle audio as usual
        if (audioElement.paused) {
            audioElement.play();
            playPauseButton.textContent = 'pause_circle_filled';
            console.log("Playing audio...");
        } else {
            audioElement.pause();
            playPauseButton.textContent = 'play_circle_filled';
            console.log("Paused audio...");
        }
        playerContainer.classList.remove('player-split');
    }
});

// Trigger animation when video is about to play
videoElement.addEventListener('canplay', () => {
    if (videoElement.paused) {
        console.log("Video is ready to play...");
        
        // Pause playback until animation finishes
        videoElement.pause();

        // Show the video and start animation
        videoElement.style.visibility = 'visible';
        playerContainer.classList.add('player-split');
        console.log("Started player-split animation");

        isVideoPlaying = true;

        // Listen for the animation end event
        playerContainer.addEventListener('animationend', () => {
            if (isVideoPlaying) {
                videoElement.play(); // Play the video after animation finishes
                playPauseButton.textContent = 'pause_circle_filled';
                console.log("Playing video after animation...");
                isVideoPlaying = false;
            }
        }, { once: true });
    }
});
