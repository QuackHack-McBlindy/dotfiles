
import os
import re
import sys
import time
import random
import subprocess
import difflib
import string
import secrets
import logging
import tempfile
import requests
import json
from difflib import get_close_matches
from urllib.parse import urlencode
from dotenv import load_dotenv
from pathlib import Path

def ensure_dotenv_exists(dotenv_path):
    if not os.path.exists(dotenv_path):
        os.makedirs(os.path.dirname(dotenv_path), exist_ok=True)
        
        env_content = """YOUTUBE_API_KEY="XXXXXXXXXXXXXXXXXX"
INTRO_URL="https://example.mydomain.org/intro.mp4"
WEBSERVER="https://example.mydomain.org"
DEVICE_MAP={"shield": "192.168.1.223", "arris": "192.168.1.152"}

DEFAULT_PLAYLIST="/Pool/Playlists/MyPlaylist2.m3u"
PLAYED_NEWS_FILE="played_news.txt"
MAX_PLAYED_NEWS_ENTRIES="350"
PLAYLIST_SAVE_PATH="/Pool/playlist.m3u"

SEARCH_FOLDERS='{"tv": "/Pool/TV", "music": "/Pool/Music", "movie": "/Pool/Movies", "podcast": "/Pool/Podcasts", "musicvideo": "/Pool/Music_Videos", "audiobooks": "/Pool/Audiobooks", "othervideos": "/Pool/Other_Videos", "jukebox": "/Pool/Music"}'

LIVETV_CHANNELS='{}'

NEWS_API_LIST='["http://api.sr.se/api/v2/news/episodes?format=json", "http://api.sr.se/api/v2/podfiles?programid=178&format=json", "http://api.sr.se/api/v2/podfiles?programid=5524&format=json", "http://api.sr.se/api/v2/podfiles?programid=5413&format=json"]'

CORRECTIONS='{"2,5 men": "two and a half men", "2,5 m": "two and a half men", "två och en halv män": "two and a half men", "test": "House", "2 och en halv män": "two and a half men", "oss": "Oz", "lag och ordning": "Law & Order - Special Victims Unit", "law and order": "Law & Order - Special Victims Unit", "Haus": "House", "haus": "House", "bajskorv": "House", "hus": "House", "färska prinsen": "The Fresh Prince of Bel-Air (1990)", "Pokémon": "Pokémon (1997)", "löven 1": "sport 1", "löven 2": "sport 2", "löven 3": "sport 3", "löven 4": "sport 4", "löven 5": "tv4 hockey", "löven 6": "sportkanalen", "ett": "1", "två": "2", "tre": "3", "fyra": "4", "fem": "5", "sex": "6", "sju": "7", "åtta": "8", "nio": "9", "tio": "10", "elva": "11", "tolv": "12"}'
"""
        

        with open(dotenv_path, 'w') as env_file:
            env_file.write(env_content)
        print(f"Created .env file at {dotenv_path}")
    else:
        print(f"")


dotenv_path = "/home/pungkula/.dotenv/tv.env"
ensure_dotenv_exists(dotenv_path)
load_dotenv(dotenv_path=dotenv_path)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
DEFAULT_PLAYLIST = os.getenv("DEFAULT_PLAYLIST")
PLAYED_NEWS_FILE = os.getenv("PLAYED_NEWS_FILE")
MAX_PLAYED_NEWS_ENTRIES = os.getenv("MAX_PLAYED_NEWS_ENTRIES")
INTRO_URL = os.getenv("INTRO_URL")
WEBSERVER = os.getenv("WEBSERVER")

SEARCH_FOLDERS = json.loads(os.getenv("SEARCH_FOLDERS", "{}"))
LIVETV_CHANNELS = json.loads(os.getenv("LIVETV_CHANNELS", "{}"))
NEWS_API_LIST = json.loads(os.getenv("NEWS_API_LIST", "[]"))
CORRECTIONS = json.loads(os.getenv("CORRECTIONS", "{}"))

PLAYLIST_SAVE_PATH = os.getenv("PLAYLIST_SAVE_PATH")  # The path where the playlist should be saved
YOUTUBE_API_KEY = os.getenv("YOUTUBE_API_KEY")

DEVICE_MAP = json.loads(os.getenv("DEVICE_MAP", "{}"))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
def is_valid_ip(address):
    """Check if the input is a valid IP address."""
    ip_pattern = re.compile(r"^\d{1,3}(\.\d{1,3}){3}$")
    if not ip_pattern.match(address):
        return False
    # Check each octet is between 0 and 255
    octets = address.split('.')
    for octet in octets:
        if not 0 <= int(octet) <= 255:
            return False
    return True

def resolve_device(device_ip):
    """Resolve device name to IP if it exists in DEVICE_MAP, else return the input if it's a valid IP."""
    if is_valid_ip(device_ip):
        logging.debug(f"Using direct IP: {device_ip}")
        return device_ip  # Use the input if it's a valid IP
    resolved_ip = DEVICE_MAP.get(device_ip)
    if resolved_ip:
        logging.debug(f"Resolved {device_ip} -> {resolved_ip}")  # Forced logging
        return resolved_ip
    logging.error(f"Unknown device: {device_ip}")
    return None  # Prevent sending unknown names to ADB

    # Resolve the device name to an IP address using DEVICE_MAP
    if device_ip in DEVICE_MAP:
        device_ip = DEVICE_MAP[device_ip]  # Replace the device name with its corresponding IP
    elif not is_valid_ip(device_ip):  # Check if it's already a valid IP
        logging.error(f"Invalid device identifier: {device_ip}")
        sys.exit(1)

    print(f"Using device IP: {device_ip}")#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

def adb_connect(device_ip):
    resolved_ip = resolve_device(device_ip)
    if not resolved_ip:
        logging.error(f"Invalid device identifier: {device_ip}")
        return None

    command = f"adb connect {resolved_ip}"
    logging.info(f"Executing: {command}")  # Forced logging
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        logging.error(f"Failed to connect to {resolved_ip}: {result.stderr.strip()}")
        return None
    return result.stdout.strip()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

def adb_disconnect(device_ip):
    resolved_ip = resolve_device(device_ip)
    if not resolved_ip:
        logging.error(f"Invalid device identifier: {device_ip}")
        return None

    command = f"adb disconnect {resolved_ip}"
    logging.info(f"Executing: {command}")  # Forced logging
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        logging.error(f"Failed to disconnect from {resolved_ip}: {result.stderr.strip()}")
        return None
    return result.stdout.strip()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
def get_current_playing(ip_address):
    try:
        command = f"timeout 1s adb -s {ip_address} logcat | grep -m 1 'Fetching media from mrl' | awk -F 'mrl: ' '{{print $2}}'"
        result = subprocess.check_output(command, shell=True, text=True).strip()
        
        if result:

            print(parse_and_format_response(result))
        else:
            print("No media currently being played or unable to fetch media info.")
    except subprocess.CalledProcessError:
        print("Failed to retrieve the current playing media.")




def parse_and_format_response(url):
    url = re.sub(r'%20', ' ', url)
    path_parts = url.split('/')
    for media_type, folder_path in SEARCH_FOLDERS.items():
        if media_type in url.lower():
            if media_type == "music":
                artist = path_parts[-2]
                song = re.sub(r'\.(flac|mp3|wav)$', '', path_parts[-1])
                return f"{artist} - {song}"
            elif media_type == "tv":
                show = path_parts[-3].replace('.', ' ')
                season_episode = re.sub(r'\.(mkv|avi|mp4)$', '', path_parts[-1])
                season = re.search(r'S(\d+)', season_episode, re.IGNORECASE)
                episode = re.search(r'E(\d+)', season_episode, re.IGNORECASE)
                if season and episode:
                    return f"{show} - S{season.group(1)}E{episode.group(1)}"
            elif media_type == "movie":
                movie = re.sub(r'\.(mkv|avi|mp4)$', '', path_parts[-1])
                return f"Movie: {movie}"
            elif media_type == "podcast":
                podcast_title = re.sub(r'\.(mp3|flac)$', '', path_parts[-1])
                return f"Podcast: {podcast_title}"
            elif media_type == "musicvideo":
                artist = path_parts[-2]
                song = re.sub(r'\.(mkv|mp4)$', '', path_parts[-1])
                return f"Music Video: {artist} - {song}"
            elif media_type == "audiobooks":
                author = path_parts[-2]
                book_title = re.sub(r'\.(mp3|m4b)$', '', path_parts[-1])
                return f"Audiobook: {author} - {book_title}"
            elif media_type == "othervideos":
                video_title = re.sub(r'\.(mkv|avi|mp4)$', '', path_parts[-1])
                return f"Other Video: {video_title}"
            elif media_type == "jukebox":
                artist = path_parts[-2]
                song = re.sub(r'\.(flac|mp3|wav)$', '', path_parts[-1])
                return f"Jukebox: {artist} - {song}"

    return "Unknown media type or format."

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def wait(seconds):
    time.sleep(seconds)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def adb_command(device_ip, command):
    """
    
    """
    result = subprocess.run(["adb", "-s", device_ip, "shell", command], capture_output=True, text=True)
    if result.returncode != 0:
        logging.error("Error executing ADB command: %s", result.stderr)
    return result.stdout
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def get_current_playing_song(device_ip):
    command = f'timeout 2s adb -s {device_ip} logcat | grep -m 1 "Fetching media from mrl" | awk -F "mrl: " \'{{print $2}}\''
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        logging.error("Error fetching currently playing song or no song found.")
        return None
    return result.stdout.strip()
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def find_remote():   
    adb_command(device_ip, "am start -a android.intent.action.VIEW-d-n com.nvidia.remotelocator/.ShieldRemoteLocatorActivity")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
def add_song_to_playlist(device_ip):
    song_url = get_current_playing_song(device_ip)
    if song_url:
        metadata = f"#EXTINF:-1,{os.path.basename(song_url).replace('.flac', '')}"
        with open(DEFAULT_PLAYLIST, "r+") as playlist:
            content = playlist.read()
            playlist.seek(0, 0)
            playlist.write(metadata.rstrip('\r\n') + '\n' + song_url + '\n\n' + content)
        print(f"Song added to {DEFAULT_PLAYLIST}")
    else:
        print("Failed to retrieve the current playing song.")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def apply_corrections(query):
    query_lower = query.lower()
    corrected_query = CORRECTIONS.get(query_lower)
    if corrected_query:
        return corrected_query
    for wrong_query, corrected_query in CORRECTIONS.items():
        if wrong_query in query_lower:
            corrected_query = corrected_query[0].upper() + corrected_query[1:] if query[0].isupper() else corrected_query.lower()
            pattern = re.compile(re.escape(wrong_query) + r'(?=\W|$)', re.IGNORECASE)
            return pattern.sub(corrected_query, query)
    return query
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def preprocess_search_query():
    if len(sys.argv) > 2:
        search_query = sys.argv[2]
        corrected_query = apply_corrections(search_query)
        sys.argv[2] = corrected_query
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def list_files(directory):
    file_list = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if not file.endswith(('.nfo', '.png', '.gif', '.m3u', '.jpg', '.jpeg')):
                file_list.append(os.path.join(root, file))
    return file_list
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def template_directory_path(directory_paths, media_type):
    urls = []
    base_path = SEARCH_FOLDERS[media_type]
    folder_name = os.path.basename(base_path)

    for directory_path in directory_paths:
        relative_path = directory_path.replace(base_path, f"{folder_name}")
        url = f"{WEBSERVER}/{relative_path}"
        urls.append(url)
    return urls
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def save_media_content_urls(media_content_urls):
    # Save the playlist as "playlist.m3u" in the defined path
    with open(PLAYLIST_SAVE_PATH, "w") as file:
        file.write(INTRO_URL + '\n')
        for url in media_content_urls:
            file.write(url + '\n')
    
    print(f"Playlist saved to {PLAYLIST_SAVE_PATH}")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# DIFFLIB
#def find_closest_directory(query, directories):
#    closest_match = get_close_matches(query, directories, n=1)
#    if closest_match:
#        return closest_match[0]
#    return None
#######################################
# FZF
def find_closest_directory(query, directories):
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
        temp_file.write("\n".join(directories))
        temp_file_path = temp_file.name
    
    fzf_command = f'fzf --filter="{query}" < {temp_file_path}'
    result = subprocess.run(fzf_command, shell=True, stdout=subprocess.PIPE, text=True)
    
    os.remove(temp_file_path)
    
    closest_match = result.stdout.strip().split(os.linesep)
    
    if closest_match:
        return closest_match[0]  # Return the top match
    return None

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# DIFFLIB
#def find_closest_files(query, directory, n=5):
#    closest_matches = []
#    for root, _, files in os.walk(directory):
#        for file in files:
#            filename = os.path.splitext(file)[0]
#            ratio = difflib.SequenceMatcher(None, query, filename).ratio()
#            closest_matches.append((os.path.join(root, file), ratio))
#    closest_matches.sort(key=lambda x: x[1], reverse=True)
#    return closest_matches[:n]
#################

# FZF
def find_closest_files(query, directory, n=5):
    # Get a list of all files in the directory and its subdirectories
    all_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            all_files.append(os.path.join(root, file))
    
    # Use a temporary file to store the list of files
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
        temp_file.write("\n".join(all_files))
        temp_file_path = temp_file.name
    
    # Use fzf to filter the files based on the query, reading from the temp file
    fzf_command = f'fzf --filter="{query}" < {temp_file_path}'
    result = subprocess.run(fzf_command, shell=True, stdout=subprocess.PIPE, text=True)
    
    # Clean up the temporary file
    os.remove(temp_file_path)
    
    # Split the result to get the top n matches
    closest_matches = result.stdout.strip().split(os.linesep)[:n]
    
    return closest_matches

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_power_on_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
    wait(3)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_power_off_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_SLEEP")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_media_play_pause_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_MEDIA_PLAY_PAUSE")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_media_next_track_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_MEDIA_NEXT")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_media_previous_track_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_MEDIA_PREVIOUS")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_volume_up_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_VOLUME_UP")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def call_volume_down_service(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_VOLUME_DOWN")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def play_youtube_video(device_ip, video_url):
    adb_command(device_ip, f"am start -a android.intent.action.VIEW -d {video_url} com.google.android.youtube")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def send_mp3playlist_call(device_ip):
    # Send the correct command to start playing the playlist via ADB
    playlist_url = f"{WEBSERVER}/playlist.m3u"
    command = f'am start -a android.intent.action.VIEW -d "{playlist_url}" -t "audio/x-mpegurl"'
    adb_command(device_ip, command)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def generate_random_filename(length=18):
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(secrets.choice(letters_and_digits) for _ in range(length))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def play_media_content(type_or_entity_id, query_or_file, device_ip):
    if type_or_entity_id == "jukebox":
        files = list_files(SEARCH_FOLDERS["music"])
        random.shuffle(files)
        media_content_urls = template_directory_path(files, "music")
        save_media_content_urls(media_content_urls)
        send_mp3playlist_call(device_ip)
    
    elif type_or_entity_id == "movie":
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["movie"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["movie"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "movie")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching movie found.")
    
    elif type_or_entity_id == "tv":
        #adb_connect(device_ip)
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["tv"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["tv"], closest_directory)
            files = list_files(search_directory)
            random.shuffle(files)
            media_content_urls = template_directory_path(files, "tv")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching TV show found.")
    
    elif type_or_entity_id == "music":
#        wait(6)
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["music"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["music"], closest_directory)
            files = list_files(search_directory)
            random.shuffle(files)
            media_content_urls = template_directory_path(files, "music")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching artist found.")

    elif type_or_entity_id == "song":
        closest_files = find_closest_files(query_or_file, SEARCH_FOLDERS["music"], n=5)
        if closest_files:
            files = closest_files  # Directly use the list of file paths
            media_content_urls = template_directory_path(files, "music")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("Could not find any Song with the title", sys.argv[2])



    elif type_or_entity_id == "podcast":
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["podcast"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["podcast"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "podcast")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching podcast found.")
    
    elif type_or_entity_id == "musicvideo":
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["musicvideo"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["musicvideo"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "musicvideo")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching music video found.")
    
    elif type_or_entity_id == "audiobooks":
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["audiobooks"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["audiobooks"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "audiobooks")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching audiobook found.")
    
    elif type_or_entity_id == "othervideos":
        adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#        wait(3)
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["othervideos"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["othervideos"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "othervideos")
            save_media_content_urls(media_content_urls)
            send_mp3playlist_call(device_ip)
        else:
            print("No matching video found.")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#





#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def fetch_news():
    news_list = []
    for api in NEWS_API_LIST:
        response = requests.get(api)
        if response.status_code == 200:
            data = response.json()
            for item in data.get("episodes", []) + data.get("podfiles", []):
                url = item.get("downloadpodfile", {}).get("url") or item.get("url")
                if url:
                    news_list.append(url)
    return news_list
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def load_played_news():
    if os.path.exists(PLAYED_NEWS_FILE):
        with open(PLAYED_NEWS_FILE, "r") as f:
            return set(f.read().splitlines()[:MAX_PLAYED_NEWS_ENTRIES])
    return set()
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def save_played_news(played_news):
    with open(PLAYED_NEWS_FILE, "w") as f:
        f.write("\n".join(played_news))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def mainnews(device_ip):
    adb_command(device_ip, "input keyevent KEYCODE_WAKEUP")
#    wait(3)
    played_news = load_played_news()
    news_list = fetch_news()
    if len(news_list) == 0:
        print("No new news casts available.")
        return
    new_news = [news_item for news_item in news_list if news_item not in played_news]
    if new_news:
        save_media_content_urls(new_news)
        played_news.update(new_news)
        save_played_news(played_news)
        send_mp3playlist_call(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def search_youtube(query):
    params = {
        'q': query,
        'part': 'snippet',
        'type': 'video',
        'maxResults': 5,
        'key': YOUTUBE_API_KEY
    }
    url = f'https://www.googleapis.com/youtube/v3/search?{urlencode(params)}'
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if 'items' in data and data['items']:
            video_id = data['items'][0]['id']['videoId']
            video_url = f'https://www.youtube.com/watch?v={video_id}'
            return video_url, data['items'][0]['snippet']['title']
        else:
            print("No videos found for the given search query.")
            return None, None
    else:
        print(f"Failed to retrieve videos. Status code: {response.status_code}")
        return None, None
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("🚀🚀 🦆📺❗DUCK-TV❗🦆📺  🚀🚀")
        print("If isssues arise edit config file at /home/pungkula/.dotenv/tv")
        print("🦆📺 USAGE: tv <device> <search> <media type>")
        
        sys.exit(1)

    device_ip = sys.argv[1]
    query_or_file = sys.argv[2]
    type_or_entity_id = sys.argv[3].lower()

    preprocess_search_query()

    # Resolve the device name to an IP address using DEVICE_MAP
    if device_ip in DEVICE_MAP:
        device_ip = DEVICE_MAP[device_ip]  # Replace the device name with its corresponding IP
    elif not is_valid_ip(device_ip):  # Check if it's already a valid IP
        logging.error(f"Invalid device identifier: {device_ip}")
        sys.exit(1)

    print(f"Playing playlist on device IP: {device_ip}")
    

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    if type_or_entity_id == "whats":
        get_current_playing(device_ip)

    elif type_or_entity_id == "news":
        mainnews(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "livetv":
        if query_or_file in livetv_channels:
            playlist_url = livetv_channels[query_or_file]
            send_mp3playlist_call(device_ip)
        else:
            print("Live-TV channel not found.")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "playlist":
        send_mp3playlist_call(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "add":
        add_song_to_playlist(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id in SEARCH_FOLDERS or type_or_entity_id == "song":
        adb_connect(device_ip)
        play_media_content(type_or_entity_id, query_or_file, device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "youtube":
        video_url, video_title = search_youtube(query_or_file)
        if video_url:
            print(f"Playing YouTube video: {video_title}")
            play_youtube_video(device_ip, video_url)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "play":
        call_media_play_pause_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "pause":
        call_media_play_pause_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "next":
        call_media_next_track_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "previous":
        call_media_previous_track_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "up":
        call_volume_up_service(device_ip)
        call_volume_up_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "down":
        call_volume_down_service(device_ip)
        call_volume_down_service(device_ip)
        call_volume_down_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "find":
        find_remote()
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  
    elif type_or_entity_id == "connect":
        adb_connect(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#          
    elif type_or_entity_id == "disconnect":
        adb_disconnect(device_ip)        
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#   
    elif type_or_entity_id == "on":
        call_power_on_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "off":
        call_power_off_service(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    else:
        print("Invalid command.")
