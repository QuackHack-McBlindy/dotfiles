# dotfiles/home/bookmarks.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
# » ★ QuackHack-McBLindy.com ★ «
# 🦆 say ⮞ start-page bookmarkz - order matterz
{

  # 🦆 duck say ⮞ category metadata (icon + description shown in the header)
  categories = {
    Work     = { icon = "⌘"; description = "Development & productivity"; };
    Personal = { icon = "◆"; description = "Everyday essentials"; };
    Media    = { icon = "♫"; description = "Music & entertainment"; };
    Tools    = { icon = "⚙"; description = "Utilities & services"; };
    Other    = { icon = "★"; description = "Frequently visited"; };
  };

  # 🦆 duck say ⮞ the bookmarkz
  # 🦆 ⮞ title    ⮞ optional, falls back to the url
  # 🦆 ⮞ category ⮞ optional, empty/missing dumps it in "Other"
  # 🦆 ⮞ icon     ⮞ optional, falls back to ◇
  bookmarks = [
    { title = "GitHub";          url = "https://github.com";            category = "Work"; icon = "◈"; }
    { title = "Stack Overflow";  url = "https://stackoverflow.com";     category = "Work"; icon = "S"; }
    { title = "GitLab";          url = "https://gitlab.com";            category = "Work"; icon = "◆"; }
    { title = "MDN";             url = "https://developer.mozilla.org"; category = "Work"; icon = "◇"; }

    { title = "Mail";     url = "https://mail.google.com";     category = "Personal"; icon = "✉"; }
    { title = "Calendar"; url = "https://calendar.google.com"; category = "Personal"; icon = "□"; }
    { title = "Drive";    url = "https://drive.google.com";    category = "Personal"; icon = "△"; }
    { title = "Reddit";   url = "https://reddit.com";          category = "Personal"; icon = "●"; }

    { title = "YouTube";    url = "https://youtube.com";    category = "Media"; icon = "▶"; }
    { title = "Spotify";    url = "https://spotify.com";    category = "Media"; icon = "♫"; }
    { title = "Twitch";     url = "https://twitch.tv";      category = "Media"; icon = "◆"; }
    { title = "Letterboxd"; url = "https://letterboxd.com"; category = "Media"; icon = "▣"; }

    { title = "ChatGPT";           url = "https://chatgpt.com";          category = "Tools"; icon = "✦"; }
    { title = "Translate";         url = "https://translate.google.com"; category = "Tools"; icon = "文"; }
    { title = "Speedtest";         url = "https://speedtest.net";        category = "Tools"; icon = "⌁"; }
    { title = "Have I Been Pwned"; url = "https://haveibeenpwned.com";   category = "Tools"; icon = "!"; }

    # 🦆 duck say ⮞ no category ⮞ dumped in "Other"
    { title = "Hacker News";      url = "https://news.ycombinator.com"; icon = "Y"; }
    { title = "Wikipedia";        url = "https://wikipedia.org";        icon = "W"; }
    { title = "Internet Archive"; url = "https://archive.org";          icon = "A"; }
    { title = "DuckDuckGo";       url = "https://duckduckgo.com";       icon = "D"; }

    # 🦆 say ⮞ new bookmarkz added here by a quick-scriopt


  ];}
