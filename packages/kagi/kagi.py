# 🦆 says ⮞ Kagi Search
#!/usr/bin/env python3
"""
Kagi search script using session token authentication.
Scrapes search results from Kagi web interface.
"""

import json
import subprocess
import sys
import os
from pathlib import Path
from typing import List, Dict, Optional, Any
from urllib.request import Request, HTTPCookieProcessor, build_opener
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError
from http.cookiejar import CookieJar
import gzip
from bs4 import BeautifulSoup, Tag
import time
import re
from dataclasses import dataclass
import argparse

try:
    from ducktrace import (
        dt_setup, dt_debug, dt_info, dt_warning,
        dt_error, dt_critical, dt_timer, PerformanceTimer
    )
except ImportError:
    import logging
    logging.basicConfig(level=logging.INFO)
    dt_setup = lambda name=None, level=None: logging.getLogger()
    dt_debug = logging.debug
    dt_info = logging.info
    dt_warning = logging.warning
    dt_error = logging.error
    dt_critical = logging.critical
    dt_timer = lambda name=None: (lambda f: f)
    PerformanceTimer = type('PerformanceTimer', (), {
        '__init__': lambda self, name: None,
        '__enter__': lambda self: self,
        '__exit__': lambda self, *args: None,
        'lap': lambda self, lap_name: None
    })



#logger = logging.getLogger(__name__)


def colorize(text: str, color: str = "", bold: bool = False, dim: bool = False) -> str:
    """
    Colorize text if colors are enabled (TTY detected and NO_COLOR not set).

    Args:
        text: The text to colorize
        color: Color name (red, green, yellow, blue, magenta, cyan, white)
        bold: Whether to make text bold
        dim: Whether to make text dim/faint

    Returns:
        Colorized text or plain text based on environment
    """
    # 🦆 says ⮞ check if we should use colors
    if not sys.stdout.isatty() or os.environ.get("NO_COLOR"):
        return text

    colors = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "cyan": "\033[96m",
        "white": "\033[97m",
    }

    # 🦆 says ⮞ start with empty escape sequence
    escape = ""

    if color and color.lower() in colors:
        escape = colors[color.lower()]

    if bold:
        escape = "\033[1m" + escape

    if dim:
        escape = "\033[2m" + escape

    # 🦆 says ⮞ return plain text if no formatting requested
    if not escape:
        return text

    # 🦆 says ⮞ return formatted text
    return f"{escape}{text}\033[0m"


def hyperlink(url: str, text: str = "") -> str:
    """
    Create a terminal hyperlink if supported (TTY detected and NO_COLOR not set).

    Args:
        url: The URL to link to
        text: The text to display (defaults to URL if not provided)

    Returns:
        Hyperlinked text or plain text based on environment
    """
    # 🦆 says ⮞ check if we should use hyperlinks
    if not sys.stdout.isatty() or os.environ.get("NO_COLOR"):
        return text or url

    # 🦆 says ⮞ use the URL as text if no text provided
    display_text = text or url

    # 🦆 says ⮞ OSC 8 hyperlink format: ESC]8;;URL ESC\TEXT ESC]8;; ESC\
    return f"\033]8;;{url}\033\\{display_text}\033]8;;\033\\"


@dataclass
class SearchResult:
    """Represents a single search result from Kagi."""

    title: str
    url: str
    snippet: str


@dataclass
class QuickAnswer:
    """Represents a Kagi Quick Answer response."""

    html: str
    markdown: str
    raw_text: str
    references: List[Dict[str, Any]]


class KagiSearch:
    """Kagi search client using session token authentication."""

    def __init__(self, session_token: Optional[str] = None, config_path: Optional[str] = None):
        """
        Initialize Kagi search client.

        Args:
            session_token: Kagi session token (if not provided, will load from config)
            config_path: Path to config file (defaults to ~/.config/kagi/config.json)
        """
        self.base_url = "https://kagi.com"
        self.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

        # 🦆 says ⮞ load config and get session token
        if not session_token:
            config = self._load_config(config_path)
            session_token = self._get_session_token(config)

        self.session_token = session_token

        # 🦆 says ⮞ set up cookie handling
        self.cookie_jar = CookieJar()
        self.opener = build_opener(HTTPCookieProcessor(self.cookie_jar))

        # 🦆 says ⮞ authenticate with token
        self._authenticate()

    def _load_config(self, config_path: Optional[str] = None) -> Dict[str, Any]:
        """Load configuration from file."""
        if not config_path:
            config_file = Path.home() / ".config" / "kagi" / "config.json"
        else:
            config_file = Path(config_path)

        if not config_file.exists():
            # 🦆 says ⮞ create default config
            config_file.parent.mkdir(parents=True, exist_ok=True)
            default_config = {
                "password_command": "cat /run/secrets/kagi",
                "timeout": 30,
                "max_retries": 5,
            }
            with open(config_file, "w") as f:
                json.dump(default_config, f, indent=2)
            msg = colorize(f"Created default config at {config_file}", color="green")
            print(msg, file=sys.stderr)
            return default_config

        with open(config_file, "r") as f:
            data: Dict[str, Any] = json.load(f)
            return data

    def _get_session_token(self, config: Dict[str, Any]) -> str:
        """Get session token using password command from config."""
        password_command = config.get("password_command", "cat /run/secrets/kagi")

        try:
            # 🦆 says ⮞ execute the password command
            result = subprocess.run(
                password_command.split(), capture_output=True, text=True, check=True
            )
            session_link = result.stdout.strip()

            # 🦆 says ⮞ extract token from session link
            if "token=" in session_link:
                return session_link.split("token=")[1].split("&")[0]
            else:
                # 🦆 says ⮞ assume the entire output is the token
                return session_link

        except subprocess.CalledProcessError as e:
            error_msg = colorize(f"Error executing password command: {e}", color="red", bold=True)
            print(error_msg, file=sys.stderr)
            if e.stderr:
                stderr_msg = colorize(f"stderr: {e.stderr}", color="red")
                print(stderr_msg, file=sys.stderr)
            sys.exit(1)
        except Exception as e:
            error_msg = colorize(f"Error getting session token: {e}", color="red", bold=True)
            print(error_msg, file=sys.stderr)
            sys.exit(1)

    def _authenticate(self) -> None:
        """Authenticate with Kagi using session token."""
        token_url = f"{self.base_url}/html/search?token={self.session_token}"
        request = Request(token_url)
        request.add_header("User-Agent", self.user_agent)

        try:
            response = self.opener.open(request, timeout=30)
            final_url = response.geturl()

            # 🦆 says ⮞ check if we were redirected to home page or html search (successful auth)
            if final_url in [f"{self.base_url}/", self.base_url, f"{self.base_url}/html/search"]:
                return  # 🦆 says ⮞ success
            elif "/signin" in final_url or "/welcome" in final_url:
                raise Exception(f"Authentication failed - redirected to {final_url}")
        except Exception as e:
            raise Exception(f"Failed to authenticate with token: {e}")

    def search(self, query: str, limit: int = 10) -> List[SearchResult]:
        """
        Search Kagi and return results.

        Args:
            query: Search query
            limit: Maximum number of results to return

        Returns:
            List of SearchResult objects
        """
        # 🦆 says ⮞ construct search URL for HTML version (no token needed, we use cookies)
        params = {"q": query}
        search_url = f"{self.base_url}/html/search?{urlencode(params)}"

        max_retries = 5
        retry_delay = 1.0

        for attempt in range(max_retries):
            try:
                # 🦆 says ⮞ create request with headers
                request = Request(search_url)
                request.add_header("User-Agent", self.user_agent)
                request.add_header(
                    "Accept",
                    "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                )
                request.add_header("Accept-Language", "en-US,en;q=0.5")
                request.add_header("DNT", "1")
                request.add_header("Connection", "keep-alive")
                request.add_header("Upgrade-Insecure-Requests", "1")

                # 🦆 says ⮞ make request using opener (with cookies)
                response = self.opener.open(request, timeout=30)

                # 🦆 says ⮞ check if we're redirected to sign in
                final_url = response.geturl()
                if "/signin" in final_url or "/welcome" in final_url:
                    raise Exception(f"Authentication failed - redirected to {final_url}")

                # 🦆 says ⮞ read response
                content = response.read()

                # 🦆 says ⮞ handle gzip encoding if present
                if response.headers.get("Content-Encoding") == "gzip":
                    content = gzip.decompress(content)

                html_content = content.decode("utf-8")

                # 🦆 says ⮞ parse results
                soup = BeautifulSoup(html_content, "html.parser")

                # 🦆 says ⮞ find results container
                results_box = soup.find(class_="results-box")
                if not results_box or isinstance(results_box, str):
                    if attempt < max_retries - 1:
                        time.sleep(retry_delay)
                        continue
                    raise Exception("No results box found on page")

                # 🦆 says ⮞ extract search results
                results = []
                if not isinstance(results_box, Tag):
                    raise Exception("Results box is not a Tag element")
                search_results = results_box.find_all(class_="search-result")

                for result in search_results[:limit]:
                    # 🦆 says ⮞ extract title
                    title_elem = result.find(class_="__sri-title")
                    title = ""
                    if title_elem:
                        # 🦆 says ⮞ Get only the text content, not the UI elements
                        # 🦆 says ⮞ remove "More results from this site", "Remove results from this site", etc.
                        title_text = title_elem.get_text(separator=" ", strip=True)
                        # 🦆 says ⮞ split by common Kagi UI elements and take the first part
                        for separator in [
                            "More results from",
                            "Remove results from",
                            "Open page in",
                        ]:
                            if separator in title_text:
                                title_text = title_text.split(separator)[0]
                        title = title_text.strip()

                    # 🦆 says ⮞ extract URL
                    url_box = result.find(class_="__sri-url-box")
                    url = ""
                    if url_box:
                        link = url_box.find("a", href=True)
                        if link:
                            href = link.get("href", "")
                            url = str(href) if href else ""

                    # 🦆 says ⮞ extract snippet
                    desc_elem = result.find(class_="__sri-desc")
                    snippet = desc_elem.get_text(strip=True) if desc_elem else ""

                    if title and url:
                        results.append(SearchResult(title=title, url=url, snippet=snippet))

                if results:
                    return results
                elif attempt < max_retries - 1:
                    time.sleep(retry_delay)
                    continue

            except (URLError, HTTPError) as e:
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                    continue
                raise Exception(f"Request failed: {e}")

        return []

    def _get_session_cookie(self) -> str:
        """Extract kagi_session cookie value for X-Kagi-Authorization header."""
        for cookie in self.cookie_jar:
            if cookie.name == "kagi_session":
                return str(cookie.value) if cookie.value else ""
        return ""

    def get_quick_answer(self, query: str) -> Optional[QuickAnswer]:
        """
        Get Kagi Quick Answer for a query.

        Args:
            query: Search query

        Returns:
            QuickAnswer object or None if no answer available
        """
        # 🦆 says ⮞ construct Quick Answer URL - POST request with query in URL
        params = {"q": query}
        quick_answer_url = f"{self.base_url}/mother/context?{urlencode(params)}"
        dt_debug(f"Quick Answer URL: {quick_answer_url}")
        dt_debug("Fetching Quick Answer...")

        try:
            # 🦆 says ⮞ get session cookie for authorization header
            session_cookie = self._get_session_cookie()

            request = Request(quick_answer_url, data=b"", method="POST")
            request.add_header("User-Agent", self.user_agent)
            request.add_header("Accept", "application/vnd.kagi.stream")
            request.add_header("Accept-Language", "en-US,en;q=0.5")
            request.add_header("Accept-Encoding", "gzip, deflate")
            request.add_header("Referer", f"{self.base_url}/search?{urlencode(params)}")
            request.add_header("Origin", self.base_url)
            request.add_header("Connection", "keep-alive")
            request.add_header("Content-Length", "0")
            if session_cookie:
                request.add_header("X-Kagi-Authorization", session_cookie)

            # 🦆 says ⮞ make request using opener (with cookies)
            dt_debug("Making Quick Answer POST request...")
            response = self.opener.open(request, timeout=30)
            dt_debug(f"Response status: {response.getcode()}")

            # 🦆 says ⮞ check if we're redirected to sign in
            final_url = response.geturl()
            dt_debug(f"Final URL: {final_url}")
            if "/signin" in final_url or "/welcome" in final_url:
                raise Exception(f"Authentication failed - redirected to {final_url}")

            content = response.read()
            dt_debug(f"Response content length: {len(content)} bytes")

            # 🦆 says ⮞ handle gzip encoding if present
            if response.headers.get("Content-Encoding") == "gzip":
                dt_debug("Decompressing gzip content")
                content = gzip.decompress(content)

            # 🦆 says ⮞ parse streaming response - lines with prefixes like "hi:", "tokens.json:", "new_message.json:"
            content_str = content.decode("utf-8")
            lines = content_str.strip().split("\n")
            dt_debug(f"Response has {len(lines)} lines")

            final_data = None

            for line in lines:
                line = line.strip()
                if not line:
                    continue
                dt_debug(f"Processing line: {line[:100]}...")  # Log first 100 chars

                # 🦆 says ⮞ look for the new_message.json line which contains the final answer
                if line.startswith("new_message.json:"):
                    json_str = line[len("new_message.json:") :]
                    dt_debug(f"Parsing new_message JSON: {json_str[:200]}...")
                    try:
                        # 🦆 says ⮞ use JSONDecoder to parse only the first JSON object
                        # 🦆 says ⮞ this handles cases where there's trailing data after the JSON
                        decoder = json.JSONDecoder()
                        final_data, _ = decoder.raw_decode(json_str)
                        dt_debug("Successfully parsed new_message data")
                    except json.JSONDecodeError as e:
                        dt_error(f"Failed to parse new_message JSON: {e}")
                        dt_debug(f"Full line: {line}")

            if not final_data:
                dt_debug("No new_message data found in response")
                return None

            # 🦆 says ⮞ new response format has fields: md, reply, references_md, etc.
            markdown = final_data.get("md", "")
            html = final_data.get("reply", "")
            references_md = final_data.get("references_md", "")

            # 🦆 says ⮞ parse references from references_md (format: [^1]: [Title](URL) (percent%))
            references = []
            if references_md:
                import re

                ref_pattern = r"\[\^\d+\]:\s*\[([^\]]+)\]\((.+?)\)\s*\((\d+)%\)"
                for match in re.finditer(ref_pattern, references_md):
                    references.append(
                        {
                            "title": match.group(1),
                            "url": match.group(2),
                            "contribution": f"{match.group(3)}%",
                        }
                    )

            # 🦆 says ⮞ if no content, return None
            if not html and not markdown:
                dt_debug("No content found in Quick Answer")
                return None

            dt_debug(f"Quick Answer found with {len(references)} references")

            return QuickAnswer(
                html=html, markdown=markdown, raw_text=markdown, references=references
            )

        except Exception as e:
            # 🦆 says ⮞ Quick Answer might not be available for all queries
            dt_debug(f"Quick Answer error: {type(e).__name__}: {e}")
            return None


def clean_quick_answer_text(text: str) -> str:
    """Remove markdown formatting and footnote markers from Quick Answer text."""
    text = re.sub(r'\[\^\d+\]', '', text)
    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)
    text = re.sub(r'\*(.*?)\*', r'\1', text)
    return re.sub(r'\s+', ' ', text).strip()


def main() -> None:
    """Main entry point for command line usage."""
    parser = argparse.ArgumentParser(description="Search Kagi using session token")
    parser.add_argument("query", nargs="?", help="Search query")
    parser.add_argument("--search", help="Search query (alternative to positional)")
    parser.add_argument(
        "-n", "--num-results", type=int, default=10,
        help="Number of results (default: 10); use 0 to show only Quick Answer"
    )
    parser.add_argument("-t", "--token-file", help="File containing session token (overrides config)")
    parser.add_argument("-c", "--config", help="Config file path")
    parser.add_argument("-j", "--json", action="store_true", help="Output as JSON")
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging to stderr")

    args = parser.parse_args()

    # 🦆 says ⮞ determine query from --search, positional, or stdin
    if args.search:
        query = args.search
    elif args.query:
        query = args.query
    else:
        if sys.stdin.isatty():
            parser.error("No query provided. Use positional argument or --search.")
        query = sys.stdin.read().strip()

    # 🦆 says ⮞ set up ducktrace logging
    level = "DEBUG" if args.debug else "INFO"
    dt_setup(level=level)

    # 🦆 says ⮞ get session token from file if provided
    session_token = None
    if args.token_file:
        try:
            with open(args.token_file, "r") as f:
                session_token = f.read().strip()
            if not session_token:
                parser.error(f"Token file '{args.token_file}' is empty")
        except Exception as e:
            parser.error(f"Failed to read token file: {e}")

    # 🦆 says ⮞ init client
    try:
        client = KagiSearch(session_token=session_token, config_path=args.config)
    except Exception as e:
        error_msg = colorize(f"Error initializing Kagi client: {e}", color="red", bold=True)
        print(error_msg, file=sys.stderr)
        sys.exit(1)

    # 🦆 says ⮞ PERFORM SEARCH
    results = []
    quick_answer = None

    try:
        quick_answer = client.get_quick_answer(query)
        if args.num_results > 0:
            results = client.search(query, limit=args.num_results)
    except Exception as e:
        error_msg = colorize(f"Search failed: {e}", color="red", bold=True)
        print(error_msg, file=sys.stderr)
        sys.exit(1)

    # 🦆 says ⮞ OUTPUT
    if args.json:
        output: Dict[str, Any] = {
            "results": [{"title": r.title, "url": r.url, "snippet": r.snippet} for r in results]
        }
        if quick_answer:
            output["quick_answer"] = {
                "markdown": quick_answer.markdown,
                "raw_text": quick_answer.raw_text,
                "references": quick_answer.references,
            }
        print(json.dumps(output, indent=2))
    else:
        # 🦆 says ⮞ display Quick Answer if available
        if quick_answer:
            qa_title = colorize("Quick Answer", color="cyan", bold=True)
            #print(f"\n{qa_title}")
            #print(colorize("─" * 80, color="cyan", dim=True))

            display_text = quick_answer.raw_text or quick_answer.markdown
            # 🦆 says ⮞ clean the text if only Quick Answer is requested
            if args.num_results == 0:
                display_text = clean_quick_answer_text(display_text)
            print(display_text)

            # 🦆 says ⮞ show references only when also showing search results
            if args.num_results > 0 and quick_answer.references:
                print()
                refs_title = colorize("References:", color="cyan", dim=True)
                print(refs_title)
                for i, ref in enumerate(quick_answer.references[:5], 1):  # Limit to 5 refs
                    ref_num = colorize(f"[{i}]", color="cyan", dim=True)
                    ref_title = ref.get("title", "")
                    ref_url = ref.get("url", "")
                    if ref_title and ref_url:
                        ref_link = hyperlink(ref_url, colorize(ref_title, color="blue"))
                        print(f"  {ref_num} {ref_link}")

            #print(colorize("─" * 80, color="cyan", dim=True))
            print()

        # 🦆 says ⮞ display search results only if requested
        if args.num_results > 0:
            for i, result in enumerate(results, 1):
                # 🦆 says ⮞ result number in yellow/bold
                number = colorize(f"{i}.", color="yellow", bold=True)
                # 🦆 says ⮞ title in blue/bold with hyperlink
                title = colorize(result.title, color="blue", bold=True)
                title_with_link = hyperlink(result.url, title)
                print(f"\n{number} {title_with_link}")

                # 🦆 says ⮞ URL in green with hyperlink
                url_text = colorize(result.url, color="green")
                url_with_link = hyperlink(result.url, url_text)
                print(f"   {url_with_link}")

                if result.snippet:
                    snippet = colorize(result.snippet, dim=True)
                    print(f"   {snippet}")

    # 🦆 says ⮞ if no results and no quick answer and not JSON, show a message
    if not results and not quick_answer and not args.json:
        error_msg = colorize("No results found", color="red")
        print(error_msg, file=sys.stderr)


if __name__ == "__main__":
    main()
