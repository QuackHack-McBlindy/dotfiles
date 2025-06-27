# dotfiles/lib/duckTrace.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 duck say ⮞ for simple duck debuggin' please
  lib,
} : let # 🦆 duck say ⮞ message constructor  
  duckSay = prefix: msg:
    builtins.trace "[🦆📜] [${prefix}] ${msg}" msg;
    
  # 🦆 duck say ⮞ debugging levels
  debug = msg: duckSay "✅ INFO" msg;
  warning = msg: duckSay "⚠️ WARNING" msg; 
  error = msg: duckSay "fuck ❌ ERROR" msg;
  
  # 🦆 duck say ⮞ attrSet
  traceAttrSet = prefix: attrs:
    builtins.trace "[🦆📜] [${prefix}] Attrs:\n${lib.generators.toPretty {} attrs}" attrs;
in {
  inherit debug warning error traceAttrSet;
  }
