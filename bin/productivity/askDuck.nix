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
  ]);
  
  askDuck = pkgs.writeScript "ask-duck.py" ''
    #!${pyEnv}/bin/python
    import argparse
    import requests
    import re
    import html.parser
    from html.parser import HTMLParser
    from duckduckgo_search import DDGS
    import logging
    import os
    
    # Custom HTML parser
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
    
    # Parse CLI arguments
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
    
    # Load important phrases
    IMPORTANT_PHRASES = []
    if args.phrasesFilePath and os.path.exists(args.phrasesFilePath):
        with open(args.phrasesFilePath, 'r') as f:
            IMPORTANT_PHRASES = [line.strip() for line in f]
    
    # Initialize DDGS with region
    ddgs = DDGS()
    
    # String matching function
    def improved_string_matching(description, user_input):
        description = description.lower()
        user_input_words = user_input.lower().split()
        score = sum(2 if word in IMPORTANT_PHRASES else 1 
                   for word in user_input_words if word in description)
        return score
    
    # Result parsing
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
    
    # Page inspection
    def inspect_page_source(url, user_input):
        try:
            headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
            
            for _ in range(3):  # Retry up to 3 times
                try:
                    response = requests.get(url, headers=headers, timeout=10)
                    response.raise_for_status()
                    
                    parser = WebPageParser()
                    parser.feed(response.text)
                    
                    if parser.json_ld and improved_string_matching(parser.json_ld, user_input):
                        return parser.json_ld[:500]
                    
                    for content in parser.content_attrs:
                        if improved_string_matching(content, user_input):
                            return content[:500]
                    
                    visible_text = parser.get_visible_text()
                    if improved_string_matching(visible_text, user_input):
                        return visible_text[:500]
                    
                    break
                except requests.RequestException:
                    continue
        except Exception as e:
            logging.error(f"Error: {e}")
        return None
    
    # Fallback to AI chat
    def fallback_to_ai_chat(user_input, data_block=None):
        try:
            if data_block:
                combined_input = f"{user_input}\\n\\nData Block:\\n{data_block}"
            else:
                combined_input = user_input
            response = ddgs.chat(combined_input, model="gpt-4o-mini")
            return response
        except Exception:
            return "I couldn't find the information directly, and the AI Chat also encountered an issue."
    
    # Main search function
    def search_web_for_answer(query):
        results = ddgs.text(query, region=REGION)
        
        if not results:
            return "No search results were found."
        
        attempt_count = 0
        while attempt_count < SEARCH_DEPTH or LOOP_UNTIL_SUCCESS:
            # Try to find answer in descriptions
            description_answer = parse_description_for_answer(results, query)
            if description_answer:
                return description_answer
            
            # Inspect individual pages
            for result in results[:SEARCH_DEPTH]:
                page_answer = inspect_page_source(result['href'], query)
                if page_answer:
                    return fallback_to_ai_chat(query, page_answer)
            
            attempt_count += 1
            if not LOOP_UNTIL_SUCCESS:
                break
        
        # Final fallback
        if FALLBACK_TO_AI_CHAT:
            return fallback_to_ai_chat(query)
        return "I searched the web but couldn't find a clear answer to your question."
    
    # Execute and print result
    print(search_web_for_answer(args.question))
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
