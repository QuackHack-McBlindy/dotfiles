// ddotfiles/packages/yo-rs/src/yo-say.rs ⮞ https://github.com/QuackHack-McBlindy/dotfiles
use std::{ // 🦆 says ⮞ text-to-speech with an optional .wav file dump path
    io::{self, Write},
    process::{Command, Stdio},
    os::unix::net::UnixStream,
};
use clap::Parser;
use ducktrace_logger::*;
use tempfile::NamedTempFile;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(long, required = true)]
    model: String,

    #[arg(long, required = true)]
    text: String,

    #[arg(long, num_args = 0..=1, default_missing_value = "true")]
    blocking: Option<bool>,

    #[arg(long)]
    path: Option<String>,
}

fn try_broadcast(text: &str) -> bool {
    if let Ok(mut stream) = UnixStream::connect("/tmp/yo-tts.sock") {
        if stream.write_all(text.as_bytes()).is_ok() && stream.flush().is_ok() {
            dt_info!("Broadcasted TTS via Unix socket");
            return true;
        }
    }
    false
}

fn main() -> io::Result<()> {
    let args = Args::parse();


    if try_broadcast(&args.text) {
        return Ok(());
    }

    let blocking = args.blocking.unwrap_or(false);

    let (temp_holder, path, is_temp) = match args.path {
        Some(p) => (None, p, false),
        None => {
            let temp = NamedTempFile::with_suffix(".wav")?;
            let path = temp.path().to_string_lossy().into_owned();
            (Some(temp), path, true)
        }
    };

    run_piper_to_file(&args.model, &args.text, &path)?;

    play_file(&path, blocking)?;

    if is_temp && blocking {
        std::fs::remove_file(&path)?;
        dt_info!("Removed temporary file: {}", path);
    }

    Ok(())
}

fn run_piper_to_file(model: &str, text: &str, path: &str) -> io::Result<()> {
    let status = Command::new("piper")
        .arg("-m")
        .arg(model)
        .arg("-f")
        .arg(path)
        .arg("--text")
        .arg(text)
        .status()?;

    if !status.success() {
        dt_info!("Piper failed with exit code: {:?}", status.code());
        std::process::exit(status.code().unwrap_or(1));
    }
    Ok(())
}

fn play_file(path: &str, blocking: bool) -> io::Result<()> {
    let mut player = Command::new("aplay")
        .arg(path)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()?;

    if blocking {
        let status = player.wait()?;
        if !status.success() {
            dt_info!("aplay failed with exit code: {:?}", status.code());
            std::process::exit(status.code().unwrap_or(1));
        }
    } else { dt_info!("Playing in background (file: {})", path); }

    Ok(())
}
