# dotfiles/bin/phone/text.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{  # 🦆 SCREAMS ⮞ SMS MESSAGING
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {
  yo.scripts.text = {
    description = "Text message a phone number from contact list";
    category = "☎️ Phone";
    #aliases = [ "st" ];
    parameters = [
      { name = "contactName"; type = "string"; description = "Contact name to call"; optional = false; }
      { name = "contactFile"; type = "string"; description = "Contact file to load"; optional = false; }
    ];
    code = ''
      # 🦆 says ⮞ todo ..
    '';
    voice = {
      priority = 5;
      sentences = [
        "sms[a] [till] {contact}"
      ];
      lists = {
        contact.wildcard = true;
      };
    };

  };}
