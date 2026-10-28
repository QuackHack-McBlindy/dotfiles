# dotfiles/bin/home/countdown.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
# 🦆 ⮞ my house - qwack! u wanna copy pasta?
{ #  » ★ github.com/QuackHack-McBlindy/zigduck ★ «
  self,
  lib,
  config,
  pkgs,
  ...
} : let
  zigbeeDevices = config.house.zigbee.devices;

  swedishNumbers = [
    "noll" "ett" "två" "tre" "fyra" "fem" "sex" "sju" "åtta" "nio" "tio"
    "elva" "tolv" "tretton" "fjorton" "femton" "sexton" "sjutton" "arton" "nitton"
    "tjugo" "tjugoett" "tjugotvå" "tjugotre" "tjugofyra" "tjugofem" "tjugosex" "tjugosju" "tjugoåtta" "tjugonio"
    "trettio" "trettioett" "trettiotvå" "trettiotre" "trettiofyra" "trettiofem" "trettiosex" "trettiosju" "trettioåtta" "trettionio"
    "fyrtio" "fyrtioett" "fyrtiotvå" "fyrtiotre" "fyrtiofyra" "fyrtiofem" "fyrtiosex" "fyrtiosju" "fyrtioåtta" "fyrtionio"
    "femtio" "femtioett" "femtiotvå" "femtiotre" "femtiofyra" "femtiofem" "femtiosex" "femtiosju" "femtioåtta" "femtionio"
    "sextio" "sextioett" "sextiotvå" "sextiotre" "sextiofyra" "sextiofem" "sextiosex" "sextiosju" "sextioåtta" "sextionio"
    "sjuttio" "sjuttioett" "sjuttiotvå" "sjuttiotre" "sjuttiofyra" "sjuttiofem" "sjuttiosex" "sjuttiosju" "sjuttioåtta" "sjuttionio"
    "åttio" "åttioett" "åttiotvå" "åttiotre" "åttiofyra" "åttiofem" "åttiosex" "åttiosju" "åttioåtta" "åttionio"
    "nittio" "nittioett" "nittiotvå" "nittiotre" "nittiofyra" "nittiofem" "nittiosex" "nittiosju" "nittioåtta" "nittionio"
    "etthundra"
  ];

  swedishNumber = n: builtins.elemAt swedishNumbers n;

in {
  yo.scripts.countdown = {
    description = "Set a countdown on a Zigbee device (turns off after N seconds).";
    category = "🛖 Home Automation";
    autoStart = false;
    logLevel = "WARNING";

    parameters = [
      { name = "device";  description = "Device to set countdown on"; }
      { name = "seconds"; description = "Seconds until device turns off"; default = "0"; }
    ];

    code = ''
      zigduck-cli --publish \
        --topic "zigbee2mqtt/''${device}/set" \
        --payload "{\"countdown\": ''${seconds}}"
    '';

    voice = {
      priority = 2;
      fuzzy.enable = true;
      fuzzy.threshold = 0.5;
      sentences = [
        "sätt {seconds} sekunders countdown på {device}"
        "låt {device} stänga om {seconds} sekunder"
        "sätt {device} att stänga om {seconds} sekunder"
        "stäng {device} om {seconds} sekunder"
        "sätt countdown {seconds} på {device}"
        "sätt {device} countdown {seconds}"
        "stoppa countdown på {device}"
        "avbryt countdown på {device}"
      ];
      lists = {
        device = { wildcard = true; values = []; };
        seconds = {
          values =
            # 🦆 says ⮞ 0–100: digit + Swedish word, both map to the digit
            (builtins.concatLists (builtins.genList
              (i: [
                { "in" = toString i;       out = toString i; }
                { "in" = swedishNumber i;  out = toString i; }
              ])
              101))
            # 🦆 says ⮞ common longer durations, with minute-based aliases
            ++ [
              { "in" = "120|två minuter|2 minuter";                 out = "120"; }
              { "in" = "180|tre minuter|3 minuter";                 out = "180"; }
              { "in" = "240|fyra minuter|4 minuter";                out = "240"; }
              { "in" = "300|fem minuter|5 minuter";                 out = "300"; }
              { "in" = "600|tio minuter|10 minuter";                out = "600"; }
              { "in" = "900|femton minuter|15 minuter|en kvart";    out = "900"; }
              { "in" = "1200|tjugo minuter|20 minuter";             out = "1200"; }
              { "in" = "1800|trettio minuter|30 minuter|en halvtimme"; out = "1800"; }
              { "in" = "2700|fyrtiofem minuter|45 minuter";         out = "2700"; }
              { "in" = "3600|sextio minuter|60 minuter|en timme";   out = "3600"; }
            ];
        };
      };
    };

  };}
