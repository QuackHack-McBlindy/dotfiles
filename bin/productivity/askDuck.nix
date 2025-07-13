# dotfiles/bin/productivity/askDuck.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ Ask me anything plz!.  
  self, 
  lib,
  config,
  pkgs,
  cmdHelpers,
  ... 
} : let # 🦆 says ⮞ dependencies  
  pyEnv = pkgs.python3.withPackages (ps: [ 
    ps.requests 
    ps.duckduckgo-search
    ps.beautifulsoup4
    ps.yfinance
    ps.langdetect
    ps.langcodes
    ps.ratelimit
    ps.fake-useragent
  ]);
  
  askDuck = pkgs.writeScript "ask-duck.py" ''
    #!${pyEnv}/bin/python
    import argparse
    import requests
    import bs4
    import re
    import sys
    import time
    import random
    from fake_useragent import UserAgent     
    import yfinance as yf
    from langdetect import detect, LangDetectException
    from langcodes import Language
    import html.parser
    from html.parser import HTMLParser
    from duckduckgo_search import DDGS
    import logging
    import os
    
    class WebPageParser(HTMLParser):
        def __init__(self):
            super().__init__()
            self.json_ld = None
            self.content_attrs = []
            self.visible_text = []
            self.ignore_tags = False
            self.in_json_ld = False
            self.json_ld_buffer = []
        
        def handle_starttag(self, tag, attrs):
            attrs_dict = dict(attrs)
            if tag == "script" and attrs_dict.get("type") == "application/ld+json":
                self.in_json_ld = True
                self.json_ld_buffer = []
            elif tag in ["script", "style"]:
                self.ignore_tags = True
            
            if tag in ["meta", "div", "span"] and "content" in attrs_dict:
                self.content_attrs.append(attrs_dict["content"])
        
        def handle_data(self, data):
            if self.in_json_ld:
                self.json_ld_buffer.append(data)
            elif not self.ignore_tags:
                self.visible_text.append(data)
        
        def handle_endtag(self, tag):
            if tag == "script" and self.in_json_ld:
                self.in_json_ld = False
                self.json_ld = "".join(self.json_ld_buffer)
            elif tag in ["script", "style"]:
                self.ignore_tags = False
        
        def get_visible_text(self):
            return " ".join(self.visible_text)
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--question', type=str, required=True)
    parser.add_argument('--area', type=str, default="wt-wt")
    parser.add_argument('--minScoreThreshold', type=int, default=5)
    parser.add_argument('--phrasesFilePath', type=str, default="")
    parser.add_argument('--searchDepth', type=int, default=3)
    parser.add_argument('--fallback', type=str, default="true")
    parser.add_argument('--loop', type=str, default="false")
    args = parser.parse_args()
    
    # Configure settings
    REGION = args.area
    MIN_SCORE_THRESHOLD = args.minScoreThreshold
    SEARCH_DEPTH = args.searchDepth
    FALLBACK_TO_AI_CHAT = args.fallback.lower() == "true"
    LOOP_UNTIL_SUCCESS = args.loop.lower() == "true"
    

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    ### --> GLOBAL SETTINGS <-- ###
    
    SEARCH_DEPTH = 20
    FALLBACK_TO_AI_CHAT = True # Default = True
    LOOP_UNTIL_SUCCESS = False # Default = False
    # Path where your documents would be searched.
    DOCUMENTS_DIR = os.path.expanduser("~/Documents") # Default = os.path.expanduser("~/Documents") 
    
    # Minimal score for the search result to be considered good 
    # Experiment with this if your getting unsatisfactory results
    MIN_SCORE_THRESHOLD = 0 # Default = 8
    # Add important words here. The search result gets +1 score per word if its on this list.
    important_phrases = [
        'stänger', 'öppettider', 'när', 'tid', 'datum', 'match', 'klockan', 'pris', 
        'väder', 'regn', 'idag', 'imorgon', 'björklöven', 'björklövens'
    ]
    
    # Logging
    DOCS_LOGS = True  # Default = False
    
    # Predefine your stock symbols here. 
    stock_name_to_symbol = {
      # US 
        "apple": "AAPL",
      # Sweden
        "volvo": "VOLV-B.ST",
      # Germany
        "volkswagen": "VOW3.DE",
      # France
        "l'oréal": "OR.PA",
      # Norway
        "equinor": "EQNR.OL",
      # AU
        "asml": "ASML.AS",
    }
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    ### --> TRIGGER WORDS <-- ###
    
    # This word will trigger the search for local documents
    document_terms = {
        "english": "document",
        "swedish": "dokument",
        "german": "dokument",
        "french": "document",
        "spanish": "documento",
        "italian": "documento",
        "norwegian": "dokument",
        "dutch": "document",
    }
    # This word will trigger the search for stock closing price
    stock_terms = {
        "english": "stock",
        "swedish": "aktie",
        "german": "aktie",
        "french": "action",
        "spanish": "acción",
        "italian": "azione",
        "norwegian": "aksje",
        "dutch": "aandeel",
    }
    # Mapping languages to country-specific stock exchange codes
    language_to_country_code = {
        "swedish": ".ST",
        "english": "",  # Default, assumes US stocks
        "german": ".DE",
        "french": ".PA",
        "spanish": ".MC",
        "italian": ".MI",
        "norwegian": ".OL",
        "dutch": ".AS",
    }
    # Translations for output messages
    language_to_output_format = {
        "swedish_kr": "Priset på en {symbol} aktie är: {price:.2f} kr",
        "swedish_dollar": "Priset på en {symbol} aktie är: {price:.2f} dollar",
        "english": "The current price of a {symbol} stock is ${price:.2f}.",
        "german": "Der aktuelle Preis einer {symbol} Aktie beträgt {price:.2f} €.",
        "french": "Le prix actuel d'une action {symbol} est de {price:.2f} €.",
        "spanish": "El precio actual de una acción de {symbol} es {price:.2f} €.",
        "italian": "Il prezzo attuale di un'azione {symbol} è {price:.2f} €.",
        "norwegian": "Prisen på en {symbol} aksje er {price:.2f} kr.",
        "dutch": "De huidige prijs van een {symbol} aandeel is {price:.2f} €.",
    }
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    
    
    logging.basicConfig(level=logging.INFO)
    
    docs_logger = logging.getLogger('docs_logs')
    docs_logger.setLevel(logging.INFO)
    docs_log_handler = logging.StreamHandler()
    docs_logger.addHandler(docs_log_handler)
    
    
    def detect_language(text):
        try:
            language_code = detect(text)
            language_name = Language.get(language_code).language_name().lower()
            return language_name
        except LangDetectException:
            return "english"  # Default to English if language detection fails
    
    def check_for_stock_related_terms(user_input):
        language = detect_language(user_input)
        stock_term = stock_terms.get(language, stock_terms["english"])
        
        if stock_term.lower() in user_input.lower():
            return True
        return False
    
    def check_for_document_related_terms(user_input):
        language = detect_language(user_input)
        document_term = document_terms.get(language, document_terms["english"])
        
        if document_term.lower() in user_input.lower():
            return True
        return False
    
    def clean_query(query, language):
        """Removes document-related terms from the query."""
        document_term = document_terms.get(language, document_terms["english"])
        cleaned_query = re.sub(rf"\b{document_term}\b", "", query, flags=re.IGNORECASE).strip()
        return cleaned_query
    
    def improved_string_matching(description, user_input):
        description = description.lower()
        user_input_words = user_input.lower().split()
        
        score = sum(2 if word in important_phrases else 1 for word in user_input_words if word in description)
        return score
    
    def parse_description_for_answer(results, user_input):
        best_score = 0
        best_answer = None
        
        for result in results:
            description = result['body']
            score = improved_string_matching(description, user_input)
            if score > best_score:
                best_score = score
                best_answer = description
                
            if best_score >= MIN_SCORE_THRESHOLD:
                return best_answer
            
        return None
    
    def inspect_page_source(url, user_input):
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
            
            for attempt in range(3):  # Try up to 3 times with different headers
                try:
                    page = requests.get(url, headers=headers, timeout=10)
                    page.raise_for_status()
                    soup = BeautifulSoup(page.content, 'html.parser')
                    
                    json_ld = soup.find('script', type='application/ld+json')
                    if json_ld:
                        structured_data = json_ld.get_text()
                        if improved_string_matching(structured_data, user_input):
                            return structured_data[:500]
    
                    for tag in ['meta', 'div', 'span']:
                        elements = soup.find_all(tag)
                        for element in elements:
                            if element.get('content'):
                                content = element.get('content').lower()
                                if improved_string_matching(content, user_input):
                                    return content[:500]
    
                    text = soup.get_text().lower()
                    if improved_string_matching(text, user_input):
                        return text[:500]
                    
                    break  # If no errors, break out of retry loop
    
                except requests.RequestException:
                    continue
            
        except Exception as e:
            logging.error(f"Unhandled exception: {e}")
        return None
    
    def fallback_to_ai_chat(user_input, data_block=None):
        try:
            ddg = DDGS()
            if data_block:
                combined_input = f"{user_input}\n\nData Block:\n{data_block}"
            else:
                combined_input = user_input
            response = ddg.chat(combined_input, model="gpt-4o-mini")
            return response
        except Exception:
            return "I couldn't find the information directly, and the AI Chat also encountered an issue."
    
    def ai_chat(user_input):
        query = user_input
        ddgs = DDGS()
        results = ddgs.text(query)
        
        if not results:
            return "No search results were found."
        
        attempt_count = 0
        
        while attempt_count < SEARCH_DEPTH or LOOP_UNTIL_SUCCESS:
            description_answer = parse_description_for_answer(results, user_input)
            if description_answer:
                return description_answer
    
            for index, result in enumerate(results[:SEARCH_DEPTH]):
                url = result['href']
                page_source_answer = inspect_page_source(url, user_input)
                if page_source_answer:
                    return fallback_to_ai_chat(user_input, page_source_answer)
    
            attempt_count += 1
            if not LOOP_UNTIL_SUCCESS:
                break
        
        if FALLBACK_TO_AI_CHAT:
            return fallback_to_ai_chat(user_input)
        else:
            return "I searched the web but couldn't find a clear answer to your question."
    
    def get_stock_price(query):
        detected_language = detect_language(query)
        country_code = language_to_country_code.get(detected_language, "")
        
        for name, symbol in stock_name_to_symbol.items():
            if name.lower() in query.lower():
                try:
                    return fetch_stock_data(symbol)
                except Exception as e:
                    return {"error": str(e)}
    
        ddg = DDGS()
        results = ddg.chat(query + " stock symbol")
    
        if not results:
            return {"error": "No results found"}
    
        match = re.search(r'\b[A-Z0-9]{2,5}(?:-[A-Z])?\b', results)
        if match:
            symbol = match.group(0)
            print(f"Found symbol: {symbol} in chat result: {results}")
            try:
                if country_code and not symbol.endswith(country_code):
                    symbol += country_code
    
                return fetch_stock_data(symbol)
            except Exception as e:
                return {"error": str(e)}
    
        return {"error": "Stock symbol not recognized"}
    
    def fetch_stock_data(symbol):
        stock = yf.Ticker(symbol)
        
        history_data = stock.history(period='1mo')
        if not history_data.empty:
            price = history_data['Close'].iloc[-1]
            return {"symbol": symbol, "price": price}
        
        return {"error": f"No price data found for {symbol}. This stock may be delisted or not available."}
    
    def format_output(symbol, price, language):
        if language == "swedish":
            if symbol.endswith(".ST"):
                output_format = language_to_output_format["swedish_kr"]
            else:
                output_format = language_to_output_format["swedish_dollar"]
        else:
            output_format = language_to_output_format.get(language, language_to_output_format["english"])
        
        return output_format.format(symbol=symbol, price=price)
    
    def load_documents(doc_dir):
        documents = {}
        for root, _, files in os.walk(doc_dir):
            for file in files:
                if file.endswith(".txt"):
                    path = os.path.join(root, file)
                    with open(path, 'r', encoding='utf-8') as file_obj:
                        documents[path] = file_obj.read()
        return documents
    
    def search_documents(queries, documents):
        results = []
        
        for query in queries:
            query = query.lower()
            for path, text in documents.items():
                if DOCS_LOGS:
                    docs_logger.info(f"Searching in file: {path}, with query: '{query}'")
                if query in text.lower():
                    start = text.lower().index(query)
                    snippet = text[max(0, start - 50):start + 500]  # Show some context around the query
                    results.append((path, snippet, query))
        
        return results
    
    
    def format_path(path):
        parts = path.split('/')
        if len(parts) > 1:
            return f"/{parts[-2]}  / {parts[-1]}"
        return path
    
    
    def document_search(query):
        # Detect language and clean query
        language = detect_language(query)
        cleaned_query = clean_query(query, language)
    
        cleaned_query = cleaned_query.lower()
        
        # Load documents
        if DOCS_LOGS:
            docs_logger.info(f"Starting document search in directory: {DOCUMENTS_DIR}")
        documents = load_documents(DOCUMENTS_DIR)
        
        # Search for the cleaned query in documents
        results = search_documents([cleaned_query], documents)
        
        if results:
            for path, snippet, _ in results:
                formatted_path = format_path(path)
                print(f"Your search for '{cleaned_query}' was found in: {formatted_path}\n{snippet}\n")
        else:
            print("No results found.")
        
    if __name__ == "__main__":
        user_query = " ".join(sys.argv[1:])
    
        if check_for_document_related_terms(user_query):
            document_search(user_query)
        elif check_for_stock_related_terms(user_query):
            result = get_stock_price(user_query)
            if "error" in result:
                print(f"Error: {result['error']}")
            else:
                detected_language = detect_language(user_query)
                print(format_output(result["symbol"], result["price"], detected_language))
        else:
            response = ai_chat(user_query)
            print(response)
    

  '';
in {
  yo.scripts.askDuck = {
    description = "Ask da duck any question - Quacktastic assistant";
    category = "⚡ Productivity";
    aliases = [ "duck" ];
    parameters = [
      { name = "question"; description = "Your question for the duck"; optional = false; }
      { name = "area"; description = "Search region (e.g. 'us-en', 'wt-wt')"; optional = true; default = "wt-wt"; }
      { name = "minScoreThreshold"; description = "Minimum match score threshold"; optional = true; default = "5"; }
      { name = "phrasesFilePath"; description = "Path to file with important phrases"; optional = true; default = ""; }
      { name = "searchDepth"; description = "Number of results to inspect"; optional = true; default = "3"; }
      { name = "fallback"; description = "Use AI fallback (true/false)"; optional = true; default = "true"; }
      { name = "loop"; description = "Loop until success (true/false)"; optional = true; default = "false"; }      
    ];        
    code = ''
      ${cmdHelpers}
      ${askDuck} \
        --question "$question" \
        --area "${"$area"}" \
        --minScoreThreshold "${"$minScoreThreshold"}" \
        --phrasesFilePath "${"$phrasesFilePath"}" \
        --searchDepth "${"$searchDepth"}" \
        --fallback "${"$fallback"}" \
        --loop "${"$loop"}"
    '';     
  };}
