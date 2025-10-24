const audioElement = document.getElementById('audio');
const playButton = document.getElementById('playButton');
const pauseButton = document.getElementById('pauseButton');
const spectrumCanvas = document.getElementById('spectrumCanvas');
const canvasContext = spectrumCanvas.getContext('2d');

let audioContext, analyser, sourceNode;
let spectrumData = new Uint8Array(2048);

function setupAudio() {
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
    analyser = audioContext.createAnalyser();
    analyser.fftSize = 2048;

    sourceNode = audioContext.createMediaElementSource(audioElement);
    sourceNode.connect(analyser);
    analyser.connect(audioContext.destination);

    updateSpectrum(); // Start the spectrum visualization loop
}

function updateSpectrum() {
    analyser.getByteFrequencyData(spectrumData);

    // Clear the canvas
    canvasContext.clearRect(0, 0, spectrumCanvas.width, spectrumCanvas.height);

    // Draw spectrum bars
    const barWidth = spectrumCanvas.width / analyser.frequencyBinCount;
    let barHeight;
    let x = 0;

    for (let i = 0; i < analyser.frequencyBinCount; i++) {
        barHeight = spectrumData[i] / 2; // Scale bar height
        canvasContext.fillStyle = 'rgb(' + (barHeight + 100) + ',50,50)';
        canvasContext.fillRect(x, spectrumCanvas.height - barHeight, barWidth, barHeight);
        x += barWidth + 1;
    }

    requestAnimationFrame(updateSpectrum);
}

playButton.addEventListener('click', () => {
    audioContext.resume(); // Resumes the audio context
    audioElement.play();
});

pauseButton.addEventListener('click', () => {
    audioElement.pause();
});

// Automatically setup audio once the file is loaded
audioElement.addEventListener('loadedmetadata', setupAudio);

// Handle file upload and automatically set the first file for playback
const uploadForm = document.getElementById('uploadForm');
uploadForm.addEventListener('submit', async function (e) {
    e.preventDefault();

    const formData = new FormData(uploadForm);
    const response = await fetch('/upload_playlist/', {
        method: 'POST',
        body: formData,
    });

    const data = await response.json();
    document.getElementById('audioSource').src = `/uploads/${data.filename}`;
    audioElement.load(); // Load the new source in the audio element
});
