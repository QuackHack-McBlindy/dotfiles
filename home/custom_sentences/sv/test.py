import yaml
import os
import re
from thefuzz import process

# Load all YAML files in the current directory
def load_yaml_files():
    yaml_data = {}
    for file in os.listdir("."):
        if file.endswith(".yaml"):
            with open(file, "r", encoding="utf-8") as f:
                data = yaml.safe_load(f)
                if "intents" in data:
                    for intent, details in data["intents"].items():
                        sentences = []
                        for entry in details.get("data", []):
                            sentences.extend(entry.get("sentences", []))
                        yaml_data[intent] = sentences
    return yaml_data

# Load intents and sentences
intents = load_yaml_files()

# Preprocess sentences: Replace placeholders with wildcards
def preprocess_sentence(sentence):
    sentence = re.sub(r"\{.*?\}", ".*?", sentence)  # Replace {search} with regex wildcard
    sentence = sentence.strip()
    return sentence if len(sentence.split()) > 4 else None  # Ignore very short sentences

sentence_mapping = {
    preprocess_sentence(sentence): intent
    for intent, sentences in intents.items()
    for sentence in sentences
    if preprocess_sentence(sentence)
}
clean_sentences = list(sentence_mapping.keys())

# Force priority matches (manual override for fuzzy bias)
intent_priority = {
    "MediaController": ["spela upp", "spela", "upp"],
    "MusicGenerator": ["skapa en", "generera", "låt"],
    "Joke": ["skämt", "roligt", "kul"],
    "BussDepartures": ["bussen", "går bussen till", "vilken tid går bussen"],
    "MailCheck": ["när kommer posten", "posten", "brevbäraren"]
}

# Function for fuzzy matching
def fuzzy_match_intent(user_input):
    user_input_lower = user_input.lower()

    # First, check priority rules
    for intent, keywords in intent_priority.items():
        if any(keyword in user_input_lower for keyword in keywords):
            return intent  # Enforce category bias

    # Exact match lookup
    if user_input_lower in sentence_mapping:
        return sentence_mapping[user_input_lower]

    # Fuzzy match (ALWAYS returns the best match)
    match, score = process.extractOne(
        user_input_lower, 
        clean_sentences, 
        scorer=lambda x, y: process.fuzz.partial_ratio(x, y) - abs(len(x) - len(y))
    )

    return match  # Always return the best match, no filtering

# Example tests
test_inputs = [
    "Spela upp artisten Billy Bragg",
    "Spela upp serien House",
    "Spela upp filmen Ett SMåKryps Liv",
    "Jag vill höra nyheterna",
    "Skapa en hiphop låt om rymden",
    "när kommer posten",
    "vilken tid går bussen till Stockholm"
    "vad är klockan",
    "säg ett skämt",
    "släck alla lampor"
    "släck",
    "tänd alla lampor",
    "tänd"
]

for user_input in test_inputs:
    matched_intent = fuzzy_match_intent(user_input)
    print(f"Input: {user_input}")
    print(f"Matched Intent: {matched_intent}\n")

