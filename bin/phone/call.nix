# dotfiles/bin/phone/call.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{  # 🦆 SCREAMS ⮞ PHONE CALLING
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {  
  yo.scripts.call = {
    description = "Calls phone number from contact list";
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
        "ring [till] {contact}"
      ];
      lists = {
        contact.wildcard = true;          
      };
          # 🦆 says ⮞ media 
#            { "in" = "[serie|serien|tvserien|tv-serien]"; out = "tv"; }
    };

  };}
