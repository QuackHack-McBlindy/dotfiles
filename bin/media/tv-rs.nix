# dotfiles/bin/media/tv-rs.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ high performance media and playlist generator 
  self,
  lib,
  config,
  pkgs,
  cmdHelpers,
  RustDuckTrace,
  ... 
} : let # 🦆 says ⮞ yo    

  # 🦆say⮞ TV in Rust
  tv-rs = pkgs.writeText "main.rs" ''
    use std::collections::HashSet;
    use std::env;
    use std::fs;
    use std::io::{self, Write};
    use std::path::{Path, PathBuf};
    use std::time::{Duration, Instant};
    use walkdir::WalkDir;
    use regex::Regex;
    use std::error::Error;
    use once_cell::sync::Lazy;
    use rand::seq::SliceRandom;
    use rand::thread_rng;
    
    // 🦆 says ⮞ configuration loading from env vars/args
    mod config {
        use std::collections::HashMap;
        use std::env;
        use std::fs;
        use serde::{Deserialize, Serialize};
    
        #[derive(Debug, Clone, Serialize, Deserialize)]
        pub struct MediaConfig {
            pub tv_dir: String,
            pub movie_dir: String,
            pub music_dir: String,
            pub podcast_dir: String,
            pub audiobook_dir: String,
            pub musicvideo_dir: String,
            pub videos_dir: String,
            pub max_items: usize,
            pub fuzzy_threshold: i32,
        }
    
        impl Default for MediaConfig {
            fn default() -> Self {
                MediaConfig {
                    tv_dir: "/Pool/TV".to_string(),
                    movie_dir: "/Pool/Movies".to_string(),
                    music_dir: "/Pool/Music".to_string(),
                    podcast_dir: "/Pool/Podcasts".to_string(),
                    audiobook_dir: "/Pool/Audiobooks".to_string(),
                    musicvideo_dir: "/Pool/Music_Videos".to_string(),
                    videos_dir: "/Pool/Other_Videos".to_string(),
                    max_items: 200,
                    fuzzy_threshold: 30,
                }
            }
        }
    
        impl MediaConfig {
            pub fn from_env() -> Self {
                let mut config = Self::default();
                
                // 🦆 says ⮞ load from env vars
                if let Ok(val) = env::var("TVDIR") {
                    config.tv_dir = val;
                }
                if let Ok(val) = env::var("MOVIEDIR") {
                    config.movie_dir = val;
                }
                if let Ok(val) = env::var("MUSICDIR") {
                    config.music_dir = val;
                }
                if let Ok(val) = env::var("PODCASTDIR") {
                    config.podcast_dir = val;
                }
                if let Ok(val) = env::var("AUDIOBOOKDIR") {
                    config.audiobook_dir = val;
                }
                if let Ok(val) = env::var("MUSICVIDEODIR") {
                    config.musicvideo_dir = val;
                }
                if let Ok(val) = env::var("VIDEOSDIR") {
                    config.videos_dir = val;
                }
                if let Ok(val) = env::var("MAX_ITEMS") {
                    if let Ok(num) = val.parse() {
                        config.max_items = num;
                    }
                }
                if let Ok(val) = env::var("FUZZY_THRESHOLD") {
                    if let Ok(num) = val.parse() {
                        config.fuzzy_threshold = num;
                    }
                }
                
                config
            }
            
            pub fn search_dir(&self, media_type: &str) -> Option<String> {
                match media_type {
                    "tv" => Some(self.tv_dir.clone()),
                    "movie" => Some(self.movie_dir.clone()),
                    "music" => Some(self.music_dir.clone()),
                    "song" => Some(self.music_dir.clone()),
                    "podcast" => Some(self.podcast_dir.clone()),
                    "audiobook" => Some(self.audiobook_dir.clone()),
                    "musicvideo" => Some(self.musicvideo_dir.clone()),
                    "othervideo" => Some(self.videos_dir.clone()),
                    "jukebox" => Some(self.music_dir.clone()),
                    _ => None,
                }
            }
            
            pub fn get_extensions(&self, media_type: &str) -> Vec<String> {
                match media_type {
                    "song" => vec![
                        "*.mp3".to_string(),
                        "*.flac".to_string(),
                        "*.m4a".to_string(),
                        "*.wav".to_string(),
                        "*.ogg".to_string(),
                    ],
                    "music" => vec![],
                    "othervideo" => vec![
                        "*.mp4".to_string(),
                        "*.mkv".to_string(),
                        "*.avi".to_string(),
                        "*.mov".to_string(),
                        "*.wmv".to_string(),
                    ],
                    "musicvideo" => vec![
                        "*.mp4".to_string(),
                        "*.mkv".to_string(),
                        "*.mov".to_string(),
                    ],
                    "movie" => vec![
                        "*.mp4".to_string(),
                        "*.mkv".to_string(),
                        "*.avi".to_string(),
                        "*.mov".to_string(),
                    ],
                    _ => vec![],
                }
            }
        }
    
        #[derive(Debug, Serialize, Deserialize)]
        pub struct SearchResult {
            pub score: i32,
            pub path: String,
            pub filename: String,
            pub normalized_name: String,
        }
    
        impl SearchResult {
            pub fn to_output_format(&self) -> String {
                format!("{}:{}:{}", self.score, self.path, self.filename)
            }
        }
    }
    
    // 🦆 says ⮞ cache directory
    static CACHE_DIR: Lazy<PathBuf> = Lazy::new(|| {
        let mut path = dirs::cache_dir().unwrap_or_else(|| PathBuf::from("/tmp"));
        path.push("tv-rs");
        std::fs::create_dir_all(&path).ok();
        path
    });
    
    #[derive(Debug)]
    struct SearchResult {
        score: i32,
        path: String,
        name: String,
    }
    
    impl SearchResult {
        fn to_output_format(&self) -> String {
            format!("{}:{}:{}", self.score, self.path, self.name)
        }
    }
    
    // 🦆 says ⮞ string normalization
    fn normalize_string(s: &str) -> String {
        let re = Regex::new(r"[^a-z0-9]").unwrap();
        re.replace_all(&s.to_lowercase(), "").to_string()
    }

    // 🦆 says ⮞ similarity scoring for short queries
    fn calculate_similarity(query: &str, target: &str) -> i32 {
        let normalized_query = normalize_string(query);
        let normalized_target = normalize_string(target);
        
        if normalized_query.is_empty() || normalized_target.is_empty() {
            return 0;
        }
        
        // 🦆 says ⮞ exact match bonus
        if normalized_target.contains(&normalized_query) {
            return 100;
        }
        
        // 🦆 says ⮞ handle very short queries (1-3 chars) specially
        if normalized_query.len() <= 3 {
            if normalized_target.starts_with(&normalized_query) {
                return 90;
            }
            
            if normalized_target.contains(&normalized_query) {
                return 85;
            }
            
            if normalized_target.len() >= normalized_query.len() {
                let mut score = 0;
                for c in normalized_query.chars() {
                    if normalized_target.contains(c) {
                        score += 25;
                    }
                }
                return score.min(100);
            }
            return 0;
        }
        
        let tri_score = trigram_similarity(&normalized_query, &normalized_target);
        let lev_score = levenshtein_similarity(&normalized_query, &normalized_target);
        (lev_score * 80 + tri_score * 20) / 100
    }
    
    // 🦆 says ⮞ levenshtein distance algo
    fn levenshtein_distance(a: &str, b: &str) -> usize {
        let a_chars: Vec<char> = a.chars().collect();
        let b_chars: Vec<char> = b.chars().collect();
        let a_len = a_chars.len();
        let b_len = b_chars.len();
    
        if a_len == 0 { return b_len; }
        if b_len == 0 { return a_len; }
    
        let mut matrix = vec![vec![0; b_len + 1]; a_len + 1];
    
        for i in 0..=a_len { matrix[i][0] = i; }
        for j in 0..=b_len { matrix[0][j] = j; }
    
        for i in 1..=a_len {
            for j in 1..=b_len {
                let cost = if a_chars[i-1] == b_chars[j-1] { 0 } else { 1 };
                matrix[i][j] = (matrix[i-1][j] + 1)
                    .min(matrix[i][j-1] + 1)
                    .min(matrix[i-1][j-1] + cost);
            }
        }
        matrix[a_len][b_len]
    }
    
    // 🦆 says ⮞ levenshtein similarity algo
    fn levenshtein_similarity(a: &str, b: &str) -> i32 {
        if a.is_empty() && b.is_empty() {
            return 100;
        }
        
        let max_len = a.len().max(b.len());
        if max_len == 0 {
            return 100;
        }
        
        let distance = levenshtein_distance(a, b);
        let similarity = 100 - (distance * 100 / max_len);
        similarity as i32
    }
    
    // 🦆 says ⮞ trigram similarity algo
    fn trigram_similarity(a: &str, b: &str) -> i32 {
        if a.is_empty() || b.is_empty() {
            return 0;
        }
        
        let a_trigrams: HashSet<String> = a
            .chars()
            .collect::<Vec<_>>()
            .windows(3)
            .map(|w| w.iter().collect::<String>())
            .collect();
        
        let b_trigrams: HashSet<String> = b
            .chars()
            .collect::<Vec<_>>()
            .windows(3)
            .map(|w| w.iter().collect::<String>())
            .collect();
        
        if a_trigrams.is_empty() && b_trigrams.is_empty() {
            return 100;
        }
        
        let intersection: HashSet<_> = a_trigrams.intersection(&b_trigrams).collect();
        let union: HashSet<_> = a_trigrams.union(&b_trigrams).collect();
        
        if union.is_empty() {
            return 0;
        }
        
        ((intersection.len() as f32 / union.len() as f32) * 100.0) as i32
    }
    
    // 🦆 says ⮞ cache da search results
    fn get_cached_results(cache_key: &str, max_age_seconds: u64) -> Option<Vec<SearchResult>> {
        let cache_file = CACHE_DIR.join(format!("{}.cache", cache_key.replace("/", "_")));
        
        if let Ok(metadata) = fs::metadata(&cache_file) {
            if let Ok(modified) = metadata.modified() {
                if let Ok(elapsed) = modified.elapsed() {
                    if elapsed < Duration::from_secs(max_age_seconds) {
                        if let Ok(content) = fs::read_to_string(&cache_file) {
                            let mut results = Vec::new();
                            for line in content.lines() {
                                let parts: Vec<&str> = line.splitn(3, ':').collect();
                                if parts.len() == 3 {
                                    if let Ok(score) = parts[0].parse() {
                                        results.push(SearchResult {
                                            score,
                                            path: parts[1].to_string(),
                                            name: parts[2].to_string(),
                                        });
                                    }
                                }
                            }
                            return Some(results);
                        }
                    }
                }
            }
        }
        None
    }
    
    fn save_to_cache(cache_key: &str, results: &[SearchResult]) {
        let cache_file = CACHE_DIR.join(format!("{}.cache", cache_key.replace("/", "_")));
        if let Ok(mut file) = fs::File::create(&cache_file) {
            for result in results {
                let _ = writeln!(file, "{}", result.to_output_format());
            }
        }
    }
    
    // 🦆 says ⮞ directory search (TV shows, movies, music artists, ...)
    fn search_directories(dir: &str, search_query: &str, threshold: i32, max_results: usize) -> Vec<SearchResult> {
        let mut results = Vec::new();
        
        println!("Searching directories in: {}", dir);
        println!("Query: '{}'", search_query);
        
        let walker = WalkDir::new(dir)
            .max_depth(1)
            .min_depth(1)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_dir());
    
        for entry in walker {
            let path = entry.path().to_string_lossy().to_string();
            let dir_name = entry.file_name().to_string_lossy().to_string();
            
            let similarity = calculate_similarity(search_query, &dir_name);
            
            if similarity >= threshold {
                results.push(SearchResult {
                    score: similarity,
                    path,
                    name: dir_name,
                });
                
                if results.len() >= max_results {
                    break;
                }
            }
        }
        
        // 🦆 says ⮞ order by score
        results.sort_by(|a, b| b.score.cmp(&a.score));
        results
    }
    
    // 🦆 says ⮞ file search (songs, other videos)
    fn search_files(dir: &str, search_query: &str, extensions: &[String], threshold: i32, max_results: usize) -> Vec<SearchResult> {
        let mut results = Vec::new();
        
        println!("Searching files in: {}", dir);
        println!("Query: '{}'", search_query);
        
        let walker = WalkDir::new(dir)
            .follow_links(false)
            .max_depth(5)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_file());
    
        for entry in walker {
            // 🦆 says ⮞ extension filter
            if !extensions.is_empty() {
                let path = entry.path();
                if let Some(ext) = path.extension() {
                    let ext_str = ext.to_string_lossy().to_lowercase();
                    let ext_pattern = format!("*.{}", ext_str);
                    if !extensions.iter().any(|e| {
                        e == "*" || e.to_lowercase() == ext_pattern
                    }) {
                        continue;
                    }
                } else {
                    continue;
                }
            }
            
            let path = entry.path().to_string_lossy().to_string();
            let filename = entry.file_name().to_string_lossy().to_string();
            let base_name = Path::new(&filename)
                .file_stem()
                .unwrap_or_default()
                .to_string_lossy()
                .to_string();
            
            let similarity = calculate_similarity(search_query, &base_name);
            
            if similarity >= threshold {
                results.push(SearchResult {
                    score: similarity,
                    path,
                    name: base_name,
                });
                
                if results.len() >= max_results * 2 {
                    break;
                }
            }
        }
        
        results.sort_by(|a, b| b.score.cmp(&a.score));
        results.truncate(max_results);
        
        results
    }
    
    // 🦆 says ⮞ playlist generator
    struct PlaylistGenerator {
        webserver_url: String,
        intro_url: String,
        shuffle: bool,
        max_items: usize,
    }
    
    // 🦆 says ⮞ adb requires https load domain  
    impl PlaylistGenerator {
        fn new() -> Self {
            Self {
                webserver_url: env::var("WEBSERVER")
                    .unwrap_or_else(|_| "https://mydomain.com".to_string()),
                intro_url: env::var("INTRO_URL")
                    .unwrap_or_else(|_| "https://mydomain.com/intro.mp4".to_string()),
                shuffle: env::var("SHUFFLE")
                    .map(|v| v == "true")
                    .unwrap_or(true),
                max_items: env::var("MAX_ITEMS")
                    .map(|v| v.parse().unwrap_or(200))
                    .unwrap_or(200),
            }
        }
        
        fn generate_directory_playlist(
            &self,
            dir_path: &str,
            media_type: &str,
            output_path: &str,
        ) -> io::Result<String> {
            let base_dir = match media_type {
                "tv" => env::var("TVDIR").unwrap_or_else(|_| "/Pool/TV".to_string()),
                "movie" => env::var("MOVIEDIR").unwrap_or_else(|_| "/Pool/Movies".to_string()),
                "music" => env::var("MUSICDIR").unwrap_or_else(|_| "/Pool/Music".to_string()),
                "podcast" => env::var("PODCASTDIR").unwrap_or_else(|_| "/Pool/Podcasts".to_string()),
                "audiobook" => env::var("AUDIOBOOKDIR").unwrap_or_else(|_| "/Pool/Audiobooks".to_string()),
                "musicvideo" => env::var("MUSICVIDEODIR").unwrap_or_else(|_| "/Pool/Music_Videos".to_string()),
                _ => "/Pool".to_string(),
            };
            
            let folder_name = Path::new(&base_dir)
                .file_name()
                .unwrap_or_default()
                .to_string_lossy();
            
            // 🦆 says ⮞ exclude metadata
            let mut files: Vec<PathBuf> = Vec::new();
            
            for entry in WalkDir::new(dir_path)
                .follow_links(false)
                .max_depth(5)
                .into_iter()
                .filter_map(|e| e.ok())
                .filter(|e| e.file_type().is_file())
            {
                let path = entry.path();
                if let Some(ext) = path.extension() {
                    let ext_lower = ext.to_string_lossy().to_lowercase();
                    match ext_lower.as_str() {
                        "nfo" | "png" | "gif" | "jpg" | "jpeg" | "m3u" => continue,
                        _ => {}
                    }
                }
                files.push(path.to_path_buf());
            }
            
            // 🦆 says ⮞ shuflfe?
            if self.shuffle && files.len() > 1 {
                files.shuffle(&mut thread_rng());
            }
            
            // 🦆 says ⮞ limit to $MAX_ITEMS
            if files.len() > self.max_items {
                files.truncate(self.max_items);
            }
            
            let mut playlist = String::new();
            playlist.push_str("#EXTM3U\n");
            playlist.push_str(&format!("{}\n", self.intro_url));
            
            for file in files {
                let relative_path = file.strip_prefix(&base_dir)
                    .ok()
                    .and_then(|p| p.to_str())
                    .unwrap_or("");
                
                // 🦆 says ⮞ url encode
                let encoded_path = relative_path.replace(" ", "%20");
                let url = format!("{}/{}/{}", self.webserver_url, folder_name, encoded_path);
                playlist.push_str(&format!("{}\n", url));
            }            
            fs::write(output_path, &playlist)?;
    
            Ok(playlist)
        }
        
        fn generate_file_playlist(
            &self,
            files: &[SearchResult],
            media_type: &str,
            output_path: &str,
        ) -> io::Result<String> {
            let base_dir = match media_type {
                "song" => env::var("MUSICDIR").unwrap_or_else(|_| "/Pool/Music".to_string()),
                "othervideo" => env::var("VIDEOSDIR").unwrap_or_else(|_| "/Pool/Other_Videos".to_string()),
                _ => "/Pool".to_string(),
            };
            
            let folder_name = Path::new(&base_dir)
                .file_name()
                .unwrap_or_default()
                .to_string_lossy();
            
            let mut playlist = String::new();
            playlist.push_str("#EXTM3U\n");
            playlist.push_str(&format!("{}\n", self.intro_url));
            
            for result in files {
                let relative_path = Path::new(&result.path)
                    .strip_prefix(&base_dir)
                    .ok()
                    .and_then(|p| p.to_str())
                    .unwrap_or("");
                
                let encoded_path = relative_path.replace(" ", "%20");
                let url = format!("{}/{}/{}", self.webserver_url, folder_name, encoded_path);
                playlist.push_str(&format!("{}\n", url));
            }
            
            fs::write(output_path, &playlist)?;
            
            Ok(playlist)
        }
    }
    
    fn main() -> Result<(), Box<dyn Error>> {
        let args: Vec<String> = env::args().collect();
        
        if args.len() < 3 {
            eprintln!("Usage: {} <media_type> <search_query> [--playlist <output_path>]", args[0]);
            eprintln!("Media types: tv, movie, music, song, podcast, audiobook, musicvideo, othervideo");
            std::process::exit(1);
        }
        
        let media_type = args[1].as_str();
        let search_query = args[2].as_str();
        
        let config = config::MediaConfig::from_env();
        
        // 🦆 says ⮞ playlist generation flag?
        let mut generate_playlist = false;
        let mut playlist_path = String::from("/Pool/playlist.m3u");
        
        let mut i = 3;
        while i < args.len() {
            match args[i].as_str() {
                "--playlist" | "-p" => {
                    generate_playlist = true;
                    if i + 1 < args.len() {
                        playlist_path = args[i + 1].clone();
                        i += 1;
                    }
                }
                _ => {}
            }
            i += 1;
        }
        
        let search_dir = match config.search_dir(media_type) {
            Some(dir) => dir,
            None => {
                eprintln!("Unknown media type: {}", media_type);
                std::process::exit(1);
            }
        };
        
        let threshold = config.fuzzy_threshold;
        let max_results = 10;
        let start_time = Instant::now();
        
        // 🦆 says ⮞ cached? 1h TTL
        let cache_key = format!("{}:{}:{}", media_type, search_dir, search_query);
        let mut results = get_cached_results(&cache_key, 3600).unwrap_or_default();
        
        // 🦆 says ⮞ fresh search
        if results.is_empty() {
            results = match media_type {
                "tv" | "movie" | "music" | "podcast" | "audiobook" | "musicvideo" | "jukebox" => {
                    search_directories(&search_dir, search_query, threshold, max_results)
                },
                "song" | "othervideo" => {
                    let extensions = config.get_extensions(media_type);
                    search_files(&search_dir, search_query, &extensions, threshold, max_results)
                },
                _ => {
                    eprintln!("Unknown media type: {}", media_type);
                    Vec::new()
                }
            };
            
            // 🦆 says ⮞ cache it!
            if !results.is_empty() {
                save_to_cache(&cache_key, &results);
            }
        }
        
        let search_duration = start_time.elapsed();
        
        if generate_playlist && !results.is_empty() {
            let playlist_gen = PlaylistGenerator::new();
            
            match media_type {
                "tv" | "movie" | "music" | "podcast" | "audiobook" | "musicvideo" => {
                    if let Some(best_match) = results.first() {
                        playlist_gen.generate_directory_playlist(
                            &best_match.path,
                            media_type,
                            &playlist_path,
                        )?;
                        println!("PLAYLIST_GENERATED:{}", playlist_path);
                    }
                }
                "song" | "othervideo" => {
                    playlist_gen.generate_file_playlist(
                        &results,
                        media_type,
                        &playlist_path,
                    )?;
                    println!("PLAYLIST_GENERATED:{}", playlist_path);
                }
                _ => {}
            }
        }
        
        // 🦆 says ⮞ performance
        println!("SEARCH_TIME:{}ms", search_duration.as_millis());
        
        if results.is_empty() {
            println!("NO_MATCHES");
        } else {
            for result in results {
                println!("{}", result.to_output_format());
            }
        }        
        Ok(())
    }
  '';

  cargoToml = pkgs.writeText "Cargo.toml" ''    
    [package]
    name = "tv-rs"
    version = "0.2.0"
    edition = "2021"

    [dependencies]
    walkdir = "2.5.0"
    regex = "1.10.4"
    serde = { version = "1.0", features = ["derive"] }
    serde_json = "1.0"
    once_cell = "1.19.0"
    dirs = "5.0.1"
    rand = "0.8.5"
    chrono = { version = "0.4", features = ["serde"] }
    colored = "2.1.0"
    thiserror = "1.0.60"

    [profile.release]
    opt-level = 3
    lto = true
    codegen-units = 1
  '';
 
# 🦆 says ⮞ expose da magic! dis builds da NLP
in { 
  yo.scripts = { 
    tv-rs = {
      description = "High performance Media Management written in Rust.";
      category = "🎧 Media Management";
      autoStart = false;
      logLevel = "INFO";
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { name = "type"; description = "Specify the type of command or the media type to search for. Supported commands: on, off, up, down, call, favorites, add. Media Types: tv, movie, livetv, podcast, news, music, song, musicvideo, jukebox (random music), othervideo, youtube, nav_up, nav_down, nav_left, nav_right, nav_select, nav_menu, nav_back"; default = "tv"; optional = true; values = [ "on" "off" "up" "down" "next" "prev" "call" "favorites" "add" "tv" "movie" "livetv" "podcast" "news" "music" "song" "musicvideo" "jukebox" "othervideo" "youtube" "nav_up" "nav_down" "nav_left" "nav_right" "nav_select" "nav_menu" "nav_back" "channel_up" "channel_down" ]; }
        { name = "search"; type = "string"; description = "Media to search"; optional = true; }
        { name = "dir"; description = "Directory path to compile in"; default = "/home/${config.this.user.me.name}/tv-rs"; optional = false; } 
        { name = "build"; type = "bool"; description = "Flag for building the Rust binary"; optional = true; default = false; }            
      ];
      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        WEBSERVER_FILE="${config.sops.secrets.webserver.path}"
        WEBSERVER=$(cat $WEBSERVER_FILE)
        INTRO_URL="$WEBSERVER/intro.mp4"
        
        # 🦆 says ⮞ create the Rust projectz directory and move into it
        mkdir -p "$dir"
        cd "$dir"
        mkdir -p src
        
        # 🦆 says ⮞ create the source filez yo 
        cat ${tv-rs} > src/main.rs
        cat ${cargoToml} > Cargo.toml     
        
        # 🦆 says ⮞ check build bool
        if [ "$build" = true ]; then
          dt_debug "Deleting any possible old versions of the binary"
          rm -f target/release/tv-rs
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release  
          dt_debug "Build complete!"
        fi
        
        # 🦆 says ⮞ if no binary exist - compile it yo
        if [ ! -f "target/release/tv-rs" ]; then
          ${pkgs.cargo}/bin/cargo generate-lockfile     
          ${pkgs.cargo}/bin/cargo build --release
          dt_debug "Build complete!"
        fi

        # 🦆 says ⮞ capture Rust output
        TEMP_OUTPUT=$(mktemp)
        
        # 🦆 says ⮞ debug?
        if [ "$VERBOSE" -ge 1 ]; then
          DEBUG=1 WEBSERVER=$(cat $WEBSERVER_FILE) INTRO_URL="$WEBSERVER/intro.mp4" ./target/release/tv-rs "$type" "$search" --playlist
        else
          DEBUG=0 WEBSERVER=$(cat $WEBSERVER_FILE) INTRO_URL="$WEBSERVER/intro.mp4" ./target/release/tv-rs "$type" "$search" --playlist
        fi
      '';
    };  
  
  };}
