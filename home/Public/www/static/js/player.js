const audioElement = document.getElementById('audio');
const toggleButton = document.getElementById('toggleButton');
const spectrumCanvas = document.getElementById('spectrumCanvas');
const canvasContext = spectrumCanvas.getContext('2d');
const volumeSlider = document.getElementById('volumeSlider');
volumeSlider.addEventListener('input', function () {
    const volume = volumeSlider.value / 100;  // Convert to 0-1 range
    audioElement.volume = volume;
});

let audioContext, analyser, sourceNode;
let spectrumData = new Uint8Array(2048);
let isPlaying = false;

function setupAudio() {
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
    analyser = audioContext.createAnalyser();
    analyser.fftSize = 256; // More bars for a colorful spectrum

    sourceNode = audioContext.createMediaElementSource(audioElement);
    sourceNode.connect(analyser);
    analyser.connect(audioContext.destination);

    spectrumData = new Uint8Array(analyser.frequencyBinCount);

    updateSpectrum(); // Start the spectrum visualization loop
}

function updateSpectrum() {
    analyser.getByteFrequencyData(spectrumData);

    // Clear the canvas
    canvasContext.clearRect(0, 0, spectrumCanvas.width, spectrumCanvas.height);

    // Extreme color explosion effect for spectrum bars
    const barWidth = spectrumCanvas.width / analyser.frequencyBinCount;
    let barHeight;
    let x = 0;

    for (let i = 0; i < analyser.frequencyBinCount; i++) {
        barHeight = spectrumData[i] * 1.5; // Increase intensity

        // Create extreme color cycling
        const r = Math.floor(Math.sin(i * 0.3) * 127 + 128); // Sin wave for color cycling
        const g = Math.floor(Math.sin(i * 0.5 + 2) * 127 + 128);
        const b = Math.floor(Math.sin(i * 0.7 + 4) * 127 + 128);

        canvasContext.fillStyle = `rgb(${r}, ${g}, ${b})`; // Set fill color
        canvasContext.fillRect(x, spectrumCanvas.height - barHeight, barWidth, barHeight); // Draw bar

        x += barWidth + 1;
    }

    requestAnimationFrame(updateSpectrum); // Continue the loop
}

// Toggle play/pause functionality
toggleButton.addEventListener('click', () => {
    if (!audioContext) {
        setupAudio(); // Initialize the audio context if not already set up
    }

    if (!isPlaying) {
        audioContext.resume(); // Resume audio context
        audioElement.play();
        toggleButton.textContent = 'Pause'; // Change button text
    } else {
        audioElement.pause();
        toggleButton.textContent = 'Play'; // Change button text
    }

    isPlaying = !isPlaying; // Toggle state
});

// Automatically setup audio once the file is loaded
audioElement.addEventListener('loadedmetadata', setupAudio);

