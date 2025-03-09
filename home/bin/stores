#!/nix/store/bfslm177xz9s55l7gry9gf42899skx2b-nix-shell
import os
script_dir = os.path.dirname(os.path.realpath("/home/pungkula/projects/fetch"))
os.chdir(script_dir)
print(f"Running script from {script_dir}")
import sys
import json
import requests
from difflib import get_close_matches

RADIUS = 5000  
DEFAULT_LOCATION = "Umeå, Sweden"

def get_location_lat_lon(location):
    """Fetches the latitude and longitude of a given location using Nominatim API."""
    url = 'https://nominatim.openstreetmap.org/search'
    params = {
        'q': location,
        'format': 'json',
        'limit': 1
    }

    headers = { 
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0 Config/91.2.2121.13'
    }

    response = requests.get(url, params=params, headers=headers)
    if response.status_code == 200:
        data = response.json()
        if data:
            lat = data[0]['lat']
            lon = data[0]['lon']
            return lat, lon
        else:
            return None, None
    else:
        raise Exception(f"Error fetching data: {response.status_code}")

def get_shops_near_location(lat, lon, radius):
    """Fetches nearby shops using Overpass API."""
    print(f"Fetching shops near Latitude: {lat}, Longitude: {lon}, Radius: {radius}")
    url = f"https://overpass-api.de/api/interpreter?data=[out:json];node[%22shop%22](around:{radius},{lat},{lon});out;"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0 Config/91.2.2121.13'
    }

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Error fetching data from Overpass API: {response.status_code}")


def save_to_json(data, filename):
    """Saves the given data to a JSON file."""
    with open(filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)

def fuzzy_search_shops(shops_data, store_name):
    """Returns shops matching the fuzzy search for the store name and extracts opening hours."""
    shops = shops_data.get('elements', [])
    names = [shop['tags'].get('name', '') for shop in shops if 'tags' in shop]
    
    matched_names = get_close_matches(store_name, names, n=10, cutoff=0.8)

    results = []
    for match in matched_names:
        for shop in shops:
            if shop['tags'].get('name') == match:
                shop_info = {
                    'name': match,
                    'opening_hours': shop['tags'].get('opening_hours', 'N/A')  # Extract opening hours if available
                }
                results.append(shop_info)
    
    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 fetchStore.py <store_name> [location] [radius]")
        sys.exit(1)

    store_name = sys.argv[1]
    location = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_LOCATION
    radius = sys.argv[3] if len(sys.argv) > 3 else RADIUS

    # Ensure radius is a string
    radius = str(radius)

    try:
        lat, lon = get_location_lat_lon(location)

        if lat is None or lon is None:
            print("Location not found.")
            sys.exit(1)
            
        #print(f"Latitude: {lat}, Longitude: {lon}")
        shops_data = get_shops_near_location(lat, lon, radius)

        matched_shops = fuzzy_search_shops(shops_data, store_name)

        if matched_shops:
            print(f"Matched Shops for '{store_name}':")
            for shop in matched_shops:
                print(shop)
            save_to_json(matched_shops, f'matched_shops_{store_name}.json')
        else:
            print(f"No shops found matching '{store_name}'.")
    except Exception as e:
        print(f"An error occurred: {e}")
