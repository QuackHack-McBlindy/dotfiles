from fastapi import FastAPI, File, UploadFile
import uvicorn
import tempfile
import soundfile as sf
from faster_whisper import WhisperModel

app = FastAPI()

# Load the generic "medium" model
model = WhisperModel("medium", device="cpu", compute_type="int8")  # Change to "cuda" if using GPU

@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile = File(...)):
    try:
        # Save received file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
            temp_audio.write(await audio.read())
            temp_audio_path = temp_audio.name

        # Load audio and transcribe, explicitly setting Swedish language
        segments, _ = model.transcribe(temp_audio_path, language="sv")  # <-- Force Swedish
        
        transcription = " ".join(segment.text for segment in segments)
        return {"transcription": transcription}

    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8765)
