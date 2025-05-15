import numpy as np
from tflite_runtime.interpreter import Interpreter
import sounddevice as sd
import queue
import threading

class WakeWordDetector:
    def __init__(self, model_path, threshold=0.85, cooldown=5):
        self.threshold = threshold
        self.cooldown = cooldown
        self.last_trigger = 0
        
        # Load TFLite model
        self.interpreter = Interpreter(model_path=model_path)
        self.interpreter.allocate_tensors()
        
        # Get model details
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()
        
        # Audio settings based on model requirements
        self.sample_rate = 16000
        self.chunk_size = self.input_details[0]['shape'][1]
        self.audio_queue = queue.Queue()
        
    def _audio_callback(self, indata, frames, time, status):
        """Collect audio data from microphone"""
        self.audio_queue.put(indata.copy())

    def _process_audio(self, audio):
        """Preprocess audio for model input"""
        # Convert to mono and float32
        audio = audio[:, 0].astype(np.float32) / 32767.0
        
        # Add batch dimension
        return np.expand_dims(audio, axis=0)

    def _run_inference(self, audio):
        """Run model inference on audio chunk"""
        self.interpreter.set_tensor(
            self.input_details[0]['index'], 
            self._process_audio(audio)
        )
        self.interpreter.invoke()
        return self.interpreter.get_tensor(self.output_details[0]['index'])[0]

    def listen(self):
        """Start listening for wake word"""
        with sd.InputStream(
            samplerate=self.sample_rate,
            channels=1,
            dtype=np.int16,
            blocksize=self.chunk_size,
            callback=self._audio_callback
        ):
            while True:
                try:
                    audio = self.audio_queue.get(timeout=1)
                    probability = self._run_inference(audio)
                    
                    current_time = time.time()
                    if (probability > self.threshold and 
                        (current_time - self.last_trigger) > self.cooldown):
                        
                        self.last_trigger = current_time
                        self.on_wake_detected()
                        
                except queue.Empty:
                    continue

    def on_wake_detected(self):
        """Override this method for custom wake actions"""
        dt.info("Wake word detected!")
        play_wav("/path/to/awake.wav")
        subprocess.Popen([shutil.which("voice-client")])
