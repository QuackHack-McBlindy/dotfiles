
const playerContainer = document.getElementById('playerContainer');
const audioElement = document.getElementById('audio');
const videoElement = document.getElementById('video');

// Hide video initially
videoElement.style.visibility = 'hidden';

let isVideoPlaying = false;

// Play/Pause Button Click
//playPauseButton.addEventListener('click', () => {
//    console.log("Play/Pause button clicked");

//    if (videoElement.style.display === 'block') {
 //       if (videoElement.paused) {
  //          videoElement.play();
//        } else {
//            videoElement.pause();
//            playPauseButton.textContent = 'play_circle_filled';
//            console.log("Paused video...");
//            playerContainer.classList.remove('player-split');
//        }
//    } else {
        // Handle audio
//        if (audioElement.paused) {
 //           audioElement.play();
 //           playPauseButton.textContent = 'pause_circle_filled';
 //           console.log("Playing audio...");
//        } else {
//            audioElement.pause();
//            playPauseButton.textContent = 'play_circle_filled';
//            console.log("Paused audio...");
 //       }
//        playerContainer.classList.remove('player-split');
//    }
//});

// Automatically trigger animation when video starts to play
videoElement.addEventListener('play', () => {
    console.log("Video play triggered...");

    // Pause playback until animation completes
    videoElement.pause();

    // Show the video element and start animation
    videoElement.style.visibility = 'visible';
    playerContainer.classList.add('player-split');
    console.log("Started player-split animation");

    isVideoPlaying = true;

    // Play video after animation completes
    playerContainer.addEventListener('animationend', () => {
        if (isVideoPlaying) {
            videoElement.play(); // Play video after animation
            playPauseButton.textContent = 'pause_circle_filled';
            console.log("Playing video after animation...");
            isVideoPlaying = false;
        }
    }, { once: true });
});

// Ensure video element visibility resets on pause
videoElement.addEventListener('pause', () => {
    videoElement.style.visibility = 'hidden';
});
