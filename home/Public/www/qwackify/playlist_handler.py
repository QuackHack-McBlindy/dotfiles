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
import requests
import tempfile
from difflib import get_close_matches
from urllib.parse import urlencode
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
### --> Define your shit here please <-- ###

DEFAULT_PLAYLIST = "/srv/mergerfs/Pool/Playlists/MyPlaylist2.m3u"
PLAYED_NEWS_FILE = "played_news.txt"
MAX_PLAYED_NEWS_ENTRIES = 350
INTRO_URL = "https://qwackify.duckdns.org/intro.mp4"
WEBSERVER = "https://qwackify.duckdns.org"  # The base URL for serving the files
#WEBSERVER = "smb://192.168.1.28"
PLAYLIST_SAVE_PATH = "/srv/mergerfs/Pool/playlist.m3u"  # The path where the playlist should be saved
YOUTUBE_API_KEY = 'AIzaSyCIZngO4fsJ8-q-o19plqCwcex3D5IcGYY'

SEARCH_FOLDERS = {
    "tv": "/srv/mergerfs/Pool/TV",
    "music": "/srv/mergerfs/Pool/Music",
    "movie": "/srv/mergerfs/Pool/Movies",
    "podcast": "/srv/mergerfs/Pool/Podcasts",
    "musicvideo": "/srv/mergerfs/Pool/Music_Videos",
    "audiobooks": "/srv/mergerfs/Pool/Audiobooks",
    "othervideos": "/srv/mergerfs/Pool/Other_Videos",
    "jukebox": "/srv/mergerfs/Pool/Music",
}
livetv_channels = {
    "1": "http://lol.bz:2095/awUxdP31/bBx8gWe/24639",
    "2": "http://lol.bz:2095/awUxdP31/bBx8gWe/9654",
    "3": "http://lol.bz:2095/awUxdP31/bBx8gWe/9651",
    "4": "http://lol.bz:2095/awUxdP31/bBx8gWe/38080",
    "5": "http://lol.bz:2095/awUxdP31/bBx8gWe/10051",
    "6": "http://lol.bz:2095/awUxdP31/bBx8gWe/8155",
    "7": "http://lol.bz:2095/awUxdP31/bBx8gWe/9633",
    "8": "http://lol.bz:2095/awUxdP31/bBx8gWe/80900",    
    "9": "http://lol.bz:2095/awUxdP31/bBx8gWe/11304",
    "10": "http://lol.bz:2095/awUxdP31/bBx8gWe/11118",
    "11": "http://lol.bz:2095/awUxdP31/bBx8gWe/9638",
    "12": "http://lol.bz:2095/awUxdP31/bBx8gWe/11923",
    "kunskapskanalen": "http://lol.bz:2095/awUxdP31/bBx8gWe/13258", 
    "sportkanalen": "http://lol.bz:2095/awUxdP31/bBx8gWe/35921",
    "TV4 hockey": "http://lol.bz:2095/awUxdP31/bBx8gWe/35259",     
    "sport 1": "http://lol.bz:2095/awUxdP31/bBx8gWe/8168",
    "sport 2": "http://lol.bz:2095/awUxdP31/bBx8gWe/46225",
    "sport 3": "http://lol.bz:2095/awUxdP31/bBx8gWe/46227",
    "sport 4": "http://lol.bz:2095/awUxdP31/bBx8gWe/46228",
}
NEWS_API_LIST = [
    "http://api.sr.se/api/v2/news/episodes?format=json",
    "http://api.sr.se/api/v2/podfiles?programid=178&format=json",
    "http://api.sr.se/api/v2/podfiles?programid=5524&format=json",
    "http://api.sr.se/api/v2/podfiles?programid=5413&format=json"
]
CORRECTIONS = {
    "2,5 men": "two and a half men",
    "2,5 m": "two and a half men",
    "två och en halv män": "two and a half men",
    "test": "House",    
    "2 och en halv män": "two and a half men",
    "två och en halv män": "two and a half men",
    "oss": "Oz",
    "lag och ordning": "Law & Order - Special Victims Unit",
    "law and order": "Law & Order - Special Victims Unit",
    "Haus": "House",
    "haus": "House",
    "bajskorv": "House",
    "hus": "House",
    "färska prinsen": "The Fresh Prince of Bel-Air (1990)",
    "Pokémon": "Pokémon (1997)",
    "löven 1": "sport 1",
    "löven 2": "sport 2",
    "löven 3": "sport 3",
    "löven 4": "sport 4",
    "löven 5": "tv4 hockey",
    "löven 6": "sportkanalen",
    "ett": "1",
    "två": "2",
    "tre": "3",
    "fyra": "4",
    "fem": "5",
    "sex": "6",
    "sju": "7",
    "åtta": "8",
    "nio": "9",
    "tio": "10",
    "elva": "11",
    "tolv": "12", 
}

### --> Thank you! <-- ###
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
def parse_and_format_response(url):
    # Remove URL encoding (e.g., %20 -> space)
    url = re.sub(r'%20', ' ', url)

    # Split the URL path to identify its parts
    path_parts = url.split('/')

    # Identify the media type based on folder name
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

    # Fallback if no specific pattern is matched
    return "Unknown media type or format."

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def wait(seconds):
    time.sleep(seconds)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    

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
def write_media_to_new_playlist(media_content_urls):
    # Save the playlist as "playlist.m3u" in the defined path
    with open(PLAYLIST_SAVE_PATH, "w") as file:
        file.write(INTRO_URL + '\n')
        for url in media_content_urls:
            file.write(url + '\n')
    
    print(f"Playlist saved to {PLAYLIST_SAVE_PATH}")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def append_media_to_playlist(media_content_urls):
    # Read existing content, if any
    try:
        with open(PLAYLIST_SAVE_PATH, "r") as file:
            existing_content = file.read()
    except FileNotFoundError:
        existing_content = ""

    # Write INTRO_URL and new URLs, then append existing content
    with open(PLAYLIST_SAVE_PATH, "w") as file:
        file.write(INTRO_URL + '\n')
        for url in media_content_urls:
            file.write(url + '\n')
        file.write(existing_content)
    
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
    # Use a temporary file to store the list of directories
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
        temp_file.write("\n".join(directories))
        temp_file_path = temp_file.name
    
    # Use fzf to filter the directories based on the query, reading from the temp file
    fzf_command = f'fzf --filter="{query}" < {temp_file_path}'
    result = subprocess.run(fzf_command, shell=True, stdout=subprocess.PIPE, text=True)
    
    # Clean up the temporary file
    os.remove(temp_file_path)
    
    # Get the closest match (top result)
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def generate_random_filename(length=18):
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(secrets.choice(letters_and_digits) for _ in range(length))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
def generate_playlist(type_or_entity_id, query_or_file, device_ip):
    if type_or_entity_id == "movie":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["movie"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["movie"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "movie")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching movie found.")
    elif type_or_entity_id == "tv":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["tv"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["tv"], closest_directory)
            files = list_files(search_directory)
            #random.shuffle(files)
            media_content_urls = template_directory_path(files, "tv")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching TV show found.")
    elif type_or_entity_id == "music":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["music"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["music"], closest_directory)
            files = list_files(search_directory)
            #random.shuffle(files)
            media_content_urls = template_directory_path(files, "music")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching artist found.")

    elif type_or_entity_id == "song":
        closest_files = find_closest_files(query_or_file, SEARCH_FOLDERS["music"], n=5)
        if closest_files:
            files = closest_files  # Directly use the list of file paths
            media_content_urls = template_directory_path(files, "music")
            append_media_to_playlist(media_content_urls)
        else:
            print("Could not find any Song with the title", sys.argv[2])

    elif type_or_entity_id == "podcast":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["podcast"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["podcast"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "podcast")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching podcast found.")
    elif type_or_entity_id == "musicvideo":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["musicvideo"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["musicvideo"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "musicvideo")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching music video found.")
    
    elif type_or_entity_id == "audiobooks":
        closest_directory = find_closest_directory(query_or_file, os.listdir(SEARCH_FOLDERS["audiobooks"]))
        if closest_directory:
            search_directory = os.path.join(SEARCH_FOLDERS["audiobooks"], closest_directory)
            files = list_files(search_directory)
            media_content_urls = template_directory_path(files, "audiobooks")
            append_media_to_playlist(media_content_urls)
        else:
            print("No matching audiobook found.")
 
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
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: playlist_handler.py <search_query/m3u_file> <type>")
        sys.exit(1)

    query_or_file = sys.argv[1]
    type_or_entity_id = sys.argv[2].lower()

    preprocess_search_query()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    if type_or_entity_id == "news":
        mainnews(device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
        else:
            print("Live-TV channel not found.")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id in SEARCH_FOLDERS or type_or_entity_id == "song":
        generate_playlist(type_or_entity_id, query_or_file, device_ip)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    
    elif type_or_entity_id == "youtube":
        video_url, video_title = search_youtube(query_or_file)
        if video_url:
            print(f"Playing YouTube video: {video_title}")
            play_youtube_video(device_ip, video_url)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#    

