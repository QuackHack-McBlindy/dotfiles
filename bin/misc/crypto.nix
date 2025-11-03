# dotfiles/bin/misc/crypto.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ provides current crypto currency prices
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let
in {
  yo.scripts.crypto = {
    description = "Crypto currency price fetcher";
    category = "🧩 Miscellaneous";
    aliases = [ "c" ];
    parameters = [
      { 
        name = "crypto";
        type = "string";
        description = "What currency to fetch";
        optional = false;
        default = "btc";
        value = [ "btc" "xmr" ];
      }    
    ];
    code = ''
      ${cmdHelpers}
      
      if [ "$crypto" = "xmr" ]; then
        XMR_PRICE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=usd" | jq -r '.monero.usd')
        echo "$XMR_PRICE $"
        yo say "En Monero kostar just nu $XMR_PRICE dollar"
      elif [ "$crypto" = "btc" ]; then
        BTC_PRICE=$(curl -s https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT | jq -r '.price | tonumber | floor')
        echo "$BTC_PRICE $"
        yo say "En Bitcoin kostar för tillfället $BTC_PRICE dollar"
      else
        echo "Unknown coin"
      fi
    '';
    voice = {
      enabled = true;
      priority = 3;    
      sentences = [
        "(va|vad|hur) [mycket|är] (priset|kostar) [på] [en] {crypto}"
      ];     
      lists = {
        crypto.values = [
          { "in" = "[btc|bitcoin]"; out = "btc"; }
          { "in" = "[xmr|monero]"; out = "xmr"; }              
        ];
      };
    };
    
  };}
