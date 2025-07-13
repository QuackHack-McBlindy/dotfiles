import os
from dotenv import load_dotenv
load_dotenv()
import json
import requests
import sys
import re
from datetime import datetime, timedelta, timezone


API_KEY = os.getenv("TRAFIKLAB_API_KEY")

# Sets Swedish timezone.
GMT_PLUS_2 = timezone(timedelta(hours=2))

def parse_query(query):
    query = query.lower().strip()

    # Define patterns for "från" and "till"
    from_pattern = re.compile(r'från\s+([\w\s]+)\s+till\s+([\w\s]+)')
    to_pattern = re.compile(r'till\s+([\w\s]+)\s+från\s+([\w\s]+)')

    match_from_to = from_pattern.search(query)
    match_to_from = to_pattern.search(query)

    if match_from_to:
        origin = match_from_to.group(1).strip()
        destination = match_from_to.group(2).strip()
    elif match_to_from:
        destination = match_to_from.group(1).strip()
        origin = match_to_from.group(2).strip()
    else:
        raise ValueError("Kunde inte tolka frågan. Använd formatet 'När går bussen från [Start] till [Slut]?' eller 'När går bussen till [Slut] från [Start]?'")
    
    return origin, destination

def get_stop_id(stop_name):
    url = f"https://api.resrobot.se/v2.1/location.name?input={stop_name}&format=json&accessId={API_KEY}"
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Fel: Mottog statuskod {response.status_code} från API.")
        sys.exit(1)
    
    try:
        data = response.json()
    except ValueError:
        print("Fel: Kunde inte tolka JSON-svaret.")
        sys.exit(1)
    
    stop_locations = [item['StopLocation'] for item in data['stopLocationOrCoordLocation'] if 'StopLocation' in item]
    
    if len(stop_locations) == 0:
        print(f"Fel: Inga hållplatser hittades för {stop_name}.")
        sys.exit(1)
    
    stop_id = stop_locations[0]['extId']
    return stop_id

# Function to find the next route using the Route Planner API
def get_next_route(origin_id, dest_id):
    url = f"https://api.resrobot.se/v2.1/trip?format=json&originId={origin_id}&destId={dest_id}&passlist=0&showPassingPoints=0&numF=3&accessId={API_KEY}"
    response = requests.get(url)
    
    if response.status_code == 400:
        print("Fel: Dålig förfrågan - Detta kan bero på en ogiltig kombination av hållplatser eller en inkompatibel rutt.")
        sys.exit(1)
    elif response.status_code != 200:
        print(f"Fel: Mottog statuskod {response.status_code} från API.")
        sys.exit(1)
    
    try:
        data = response.json()
    except ValueError:
        print("Fel: Kunde inte tolka JSON-svaret.")
        sys.exit(1)
    
    if 'Trip' not in data or len(data['Trip']) == 0:
        print("Fel: Inga resor hittades.")
        sys.exit(1)
    
    return data['Trip']

def format_response(trips):
    now = datetime.now(GMT_PLUS_2)  # Get the current time in GMT+2
    
    formatted_response = f"Aktuell tid är {now.strftime('%H:%M')}.\n"  # Include the current time at the beginning
    
    for i, trip in enumerate(trips):
        origin = trip['LegList']['Leg'][0]['Origin']
        destination = trip['LegList']['Leg'][0]['Destination']
        product = trip['LegList']['Leg'][0]['Product'][0]  # Get the product information
        
        dep_time = datetime.strptime(f"{origin['date']} {origin['time']}", "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc).astimezone(GMT_PLUS_2)
        arr_time = datetime.strptime(f"{destination['date']} {destination['time']}", "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc).astimezone(GMT_PLUS_2)
        
        minutes_to_departure = int((dep_time - now).total_seconds() / 60)
        day = dep_time.strftime("%A")  # Get the day of the week in Swedish
        bus_number = product.get('num', 'okänd')
        
        if i == 0:
            formatted_response += (
                f"Nästa resa från {origin['name']} till {destination['name']} med buss {bus_number} avgår om {minutes_to_departure} minuter "
                f"({dep_time.strftime('%H:%M')}) på {day} och anländer kl. {arr_time.strftime('%H:%M')}."
            )
        else:
            formatted_response += (
                f" Nästa avgång efter det med buss {bus_number} är om {minutes_to_departure} minuter ({dep_time.strftime('%H:%M')})."
            )

    return formatted_response


def main():
    if len(sys.argv) != 2:
        print("Användning: python script.py 'När går bussen från [Start] till [Slut]?'")
        sys.exit(1)
    
    query = sys.argv[1]

    try:
        origin_stop, dest_stop = parse_query(query)
    except ValueError as e:
        print(e)
        sys.exit(1)
    
    origin_id = get_stop_id(origin_stop)
    dest_id = get_stop_id(dest_stop)
    
    trips = get_next_route(origin_id, dest_id)

    # ✅ Raw JSON print
    print("----- RAW TRIP DATA -----")
    print(json.dumps(trips, indent=2, ensure_ascii=False)) 
    print("-------------------------\n")

    response = format_response(trips)
    print(response)

if __name__ == "__main__":
    main()
