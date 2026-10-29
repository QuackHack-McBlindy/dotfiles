# dotfiles/modules/pokemon.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#    »  ★ QuackHack-McBLindy.com ★ «
{  # 🦆 ⮞ gotta catch 'em all!
  lib,
  config,
  ...
} : let
  balls   = [
    "safari" "sport" "fast" "friend" "heavy"
    "level" "love" "lure" "moon" "dream" "beast"
  ];

  mkBalls = flags: lib.genAttrs balls (_: flags);
  none    = { ball = false; ha = false; eggMoves = false; };  # not caught
  ball    = { ball = true;  ha = false; eggMoves = false; };  # caught, no extras
  HA      = { ball = true;  ha = true;  eggMoves = false; };  # caught + HA
  HAEM    = { ball = true;  ha = true;  eggMoves = true;  };  # caught + HA + EM
  allNone = mkBalls none;
  allBall = mkBalls ball;
  allHA   = mkBalls HA;
  allDone = mkBalls HAEM;
in {
  link."pokemon.html" = "${config.pokenix.html}/index.html";

  # » ★ github.com/QuackHack-McBlindy/pokenix ★ «
  pokenix = {
    # 🦆 ⮞ TRAINER CARD
    trainer = {
      name       = "pungkula";
      picture    = ./../home/profile.png;
      about      = "★ breeding master ★ shiny hunter ★ ducklett lover ★";
      region     = "Sweden";
      timezone   = "Europe/Stockholm";
      contact    = "Discord pungkula#0001";
      friendCode = "SW-1234-5678-9012";
      switchName = "pungkula";
      trainerId  = "082409";
    };


    # 🦆 ⮞ SPECIAL POKÉMON
    specials."mewtwo-ribbon-master" = {
      species    = "mewtwo";
      ball       = "master";
      shiny      = true;
      selfObtained = true;
      level      = 100;
      nature     = "Timid";
      ability    = "Pressure";
      heldItem   = "Life Orb";
      teraType   = "Psychic";
      evs        = { hp = 4; spa = 252; spe = 252; };
      ivs        = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
      moves      = [ "Psystrike" "Aura Sphere" "Ice Beam" "Calm Mind" ];
      ribbons    = [ "Effort Ribbon" "Master Rank Ribbon" ];
      marks      = [ "The Unrivaled" ];
      ot         = "pungkula";
      id         = "082409";
      region     = "ENG";
      obtained   = "2023/08/15";
      notes      = "SR 3 days";
    };

    # » GENERATION 1 - KANTO REGION
    specials."articuno-1" = { species = "articuno"; ball = "poke"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Lets Go"; };
    specials."articuno-2" = { species = "articuno"; ball = "moon"; shiny = true; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "2020-11-08 - Max Lair"; };
    specials."zapdos-1"   = { species = "zapdos"; ball = "fast"; selfObtained = true; ability = "Pressure"; region = "ENG"; };
    specials."zapdos-2"   = { species = "zapdos"; ball = "fast"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Max Lair - Fast ball"; };
    specials."moltres-1"  = { species = "moltres"; ball = "poke"; selfObtained = true; ability = "Pressure"; region = "ENG"; };
    specials."moltres-2"  = { species = "moltres"; ball = "safari"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Nax Lair"; };
    specials."mewtwo-1"   = { species = "mewtwo"; ball = "poke"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Nax Lair"; };
    specials."mewtwo-2"   = { species = "mewtwo"; ball = "beast"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Nax Lair"; };
    specials."mewtwo-3"   = { species = "mewtwo"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Unnerve"; region = "ENG"; notes = "Play 2016"; };
    specials."mew-1"      = { species = "mew"; ball = "poke"; selfObtained = false; ability = "Synchronize"; region = "ENG"; };
    specials."mew-2"      = { species = "mew"; ball = "poke"; shiny = true; selfObtained = false; ability = "Synchronize"; region = "JPN"; };

    # » GENERATION 2
    specials."raikou-1"  = { species = "raikou"; ball = "poke"; selfObtained = false; };
    specials."raikou-2"  = { species = "raikou"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; notes = "GAMESTP"; };
    specials."entei-1"   = { species = "entei"; ball = "poke"; selfObtained = false; region = "ENG"; notes = "GTS"; };
    specials."entei-2"   = { species = "entei"; ball = "safari"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Max Lair"; };
    specials."suicune-1" = { species = "suicune"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; notes = "GAMESTP"; };
    specials."lugia-1"   = { species = "lugia"; ball = "moon"; selfObtained = true; notes = "Max Lair"; };
    specials."ho-oh-1"   = { species = "ho-oh"; ball = "dream"; selfObtained = false; region = "ENG"; notes = "GTS"; };
    specials."celebi-1"  = { species = "celebi"; ball = "cherish"; selfObtained = false; ability = "Natural Cure"; region = "ENG"; notes = "GF"; };
    specials."celebi-2"  = { species = "celebi"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Natural Cure"; region = "JPN"; notes = "Jungle"; };

    # » GENERATION 3
    specials."regirock-1"  = { species = "regirock"; ball = "beast"; selfObtained = true; ability = "Clear Body"; region = "ENG"; notes = "2020-11-23 (9 BBall attempts) (decent att & SpA)"; };
    specials."regice-1"    = { species = "regice"; ball = "beast"; selfObtained = true; ability = "Clear Body"; region = "ENG"; notes = "2020-11-26 (145 BBall attempts) (decent att)"; };
    specials."registeel-1" = { species = "registeel"; ball = "beast"; selfObtained = true; ability = "Clear Body"; region = "ENG"; notes = "2020-11-23 (89 BBall attempts) (decent att & SpA)"; };
    specials."latias-1"    = { species = "latias"; ball = "premier"; selfObtained = true; ability = "Levitate"; region = "ENG"; notes = "Max Lair"; };
    specials."latios-1"    = { species = "latios"; ball = "poke"; selfObtained = false; };
    specials."kyogre-1"    = { species = "kyogre"; ball = "beast"; selfObtained = true; ability = "Drizzle"; region = "ENG"; notes = "Max Lair"; };
    specials."groudon-1"   = { species = "groudon"; ball = "beast"; selfObtained = true; ability = "Drought"; region = "ENG"; notes = "Max Lair"; };
    specials."groudon-2"   = { species = "groudon"; ball = "friend"; shiny = true; selfObtained = false; ability = "Drought"; region = "ENG"; };
    specials."rayquaza-1"  = { species = "rayquaza"; ball = "safari"; selfObtained = true; ability = "Air Lock"; region = "ENG"; notes = "Max Lair"; };
    specials."jirachi-1"   = { species = "jirachi"; ball = "poke"; shiny = true; selfObtained = false; ability = "Serene Grace"; region = "ENG"; notes = "2003 WISHMKR"; };
    specials."jirachi-2"   = { species = "jirachi"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Serene Grace"; region = "ENG"; notes = "NINTENDO HK"; };
    specials."deoxys-1"    = { species = "deoxys"; ball = "poke"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; };

    # » GENERATION 4
    specials."uxie-1"     = { species = "uxie"; ball = "moon"; selfObtained = true; ability = "Levitate"; region = "ENG"; notes = "Nax Lair (decent attack)"; };
    specials."uxie-2"     = { species = "uxie"; ball = "poke"; selfObtained = false; };
    specials."mesprit-1"  = { species = "mesprit"; ball = "poke"; selfObtained = false; ability = "Levitate"; notes = "gts"; };
    specials."mesprit-2"  = { species = "mesprit"; ball = "moon"; selfObtained = true; ability = "Levitate"; region = "ENG"; notes = "Nax Lair"; };
    specials."mesprit-3"  = { species = "mesprit"; ball = "poke"; selfObtained = false; };
    specials."azelf-1"    = { species = "azelf"; ball = "moon"; selfObtained = true; ability = "Levitate"; notes = "Nax Lair"; };
    specials."azelf-2"    = { species = "azelf"; ball = "poke"; selfObtained = false; };
    specials."dialga-1"   = { species = "dialga"; ball = "heavy"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Nax Lair"; };
    specials."dialga-2"   = { species = "dialga"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; notes = "SUM2013 2020/08/24"; };
    specials."palkia-1"   = { species = "palkia"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; notes = "SUM2013 2020/08/24"; };
    specials."heatran-1"  = { species = "heatran"; ball = "safari"; selfObtained = true; notes = "Max Lair"; };
    specials."regigigas-1"= { species = "regigigas"; ball = "cherish"; selfObtained = false; ability = "Slow Start"; notes = "TRU"; };
    specials."giratina-1" = { species = "giratina"; ball = "safari"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Max Lair"; };
    specials."giratina-2" = { species = "giratina"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Pressure"; region = "ENG"; notes = "SUM2013"; };
    specials."cresselia-1"= { species = "cresselia"; ball = "dream"; selfObtained = true; ability = "Levitate"; region = "ENG"; notes = "2020-11-08 Max Lair (1 attack)"; };
    specials."phione-1"   = { species = "phione"; ball = "poke"; selfObtained = false; ability = "Hydration"; region = "ENG"; notes = "Got from OT 2020/08/16"; };
    specials."manaphy-1"  = { species = "manaphy"; ball = "cherish"; selfObtained = false; ability = "Hydration"; region = "ENG"; notes = "GF"; };
    specials."darkrai-1"  = { species = "darkrai"; ball = "cherish"; selfObtained = false; ability = "Bad Dreams"; region = "ENG"; notes = "2012MAY . 2020/08/21"; };
    specials."darkrai-2"  = { species = "darkrai"; ball = "poke"; shiny = true; selfObtained = false; ability = "Bad Dreams"; region = "JPN"; notes = "2020/08/21"; };
    specials."shaymin-1"  = { species = "shaymin"; ball = "cherish"; selfObtained = false; ability = "Natural Cure"; notes = "20th Anniversary"; };
    specials."shaymin-2"  = { species = "shaymin"; ball = "luxury"; shiny = true; selfObtained = false; ability = "Natural Cure"; region = "ENG"; notes = "Deivid09#3259 > pungkula"; };
    specials."arceus-1"   = { species = "arceus"; ball = "cherish"; selfObtained = false; ability = "Multitype"; region = "ENG"; notes = "TRU"; };
    specials."victini-1"  = { species = "victini"; ball = "cherish"; selfObtained = false; ability = "Victory Star"; region = "ENG"; notes = "Movie DIstribution"; };

    # » GENERATION 5
    specials."ducklett-the-driven-1" = { species = "ducklett"; ball = "luxury"; selfObtained = true; notes = "Pumped-Up Mark 2023/09/23"; };
    specials."cobalion-1"  = { species = "cobalion"; ball = "ultra"; selfObtained = false; ability = "Justified"; region = "ENG"; notes = "2020/08/16"; };
    specials."cobalion-2"  = { species = "cobalion"; ball = "moon"; shiny = true; selfObtained = false; ability = "Justified"; region = "ENG"; notes = "2020/08/16"; };
    specials."terrakion-1" = { species = "terrakion"; ball = "ultra"; selfObtained = false; ability = "Justified"; region = "ENG"; };
    specials."terrakion-2" = { species = "terrakion"; ball = "friend"; shiny = true; selfObtained = false; ability = "Justified"; region = "ENG"; };
    specials."virizion-1"  = { species = "virizion"; ball = "ultra"; selfObtained = false; ability = "Justified"; region = "ENG"; notes = "2020/08/16"; };
    specials."virizion-2"  = { species = "virizion"; ball = "love"; shiny = true; selfObtained = false; ability = "Justified"; region = "ENG"; notes = "2020/08/16"; };
    specials."tornadus-1"  = { species = "tornadus"; ball = "safari"; selfObtained = true; ability = "Prankster"; region = "ENG"; notes = "Max Lair"; };
    specials."reshiram-1"  = { species = "reshiram"; ball = "poke"; selfObtained = false; ability = "Turboblaze"; region = "ENG"; };
    specials."reshiram-2"  = { species = "reshiram"; ball = "moon"; selfObtained = true; ability = "Turboblaze"; region = "ENG"; notes = "Max Lair"; };
    specials."reshiram-3"  = { species = "reshiram"; ball = "beast"; selfObtained = true; ability = "Turboblaze"; region = "ENG"; notes = "Max Lair"; };
    specials."reshiram-4"  = { species = "reshiram"; ball = "ultra"; shiny = true; selfObtained = false; ability = "Turboblaze"; region = "FRE"; };
    specials."zekrom-1"    = { species = "zekrom"; ball = "cherish"; selfObtained = false; ability = "Teravolt"; region = "ENG"; notes = "event \"SPR2012\" 2020/08/16"; };
    specials."zekrom-2"    = { species = "zekrom"; ball = "beast"; selfObtained = true; ability = "Teravolt"; region = "ENG"; notes = "Max Lair"; };
    specials."landorus-1"  = { species = "landorus"; ball = "safari"; selfObtained = true; ability = "Sand Force"; region = "ENG"; notes = "Max Lair"; };
    specials."kyurem-1"    = { species = "kyurem"; ball = "ultra"; shiny = true; selfObtained = false; ability = "Pressure"; region = "JPN"; };
    specials."kyurem-2"    = { species = "kyurem"; ball = "beast"; selfObtained = true; ability = "Pressure"; region = "ENG"; notes = "Max Lair"; };
    specials."keldeo-1"    = { species = "keldeo"; ball = "cherish"; selfObtained = false; ability = "Justified"; region = "ENG"; };
    specials."meloetta-1"  = { species = "meloetta"; ball = "cherish"; selfObtained = false; ability = "Serene Grace"; region = "ENG"; };
    specials."genesect-1"  = { species = "genesect"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Download"; region = "ENG"; notes = "Movie DIstribution"; };

    # » GENERATION VI
    specials."xerneas-1"  = { species = "xerneas"; ball = "beast"; selfObtained = true; };
    specials."yveltal-1"  = { species = "yveltal"; ball = "beast"; selfObtained = true; ability = "Dark Aura"; notes = "Max Lair"; };
    specials."diancie-1"  = { species = "diancie"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Clear Body"; region = "ENG"; };
    specials."hoopa-1"    = { species = "hoopa"; ball = "cherish"; selfObtained = false; };
    specials."volcanion-1"= { species = "volcanion"; ball = "cherish"; selfObtained = false; };

    # » GENERATION VII
    specials."type-null-1" = { species = "type-null"; ball = "poke"; selfObtained = true; ability = "RKS System"; region = "ENG"; };
    specials."silvally-1"  = { species = "silvally"; ball = "poke"; selfObtained = true; ability = "RKS System"; region = "ENG"; };
    specials."silvally-2"  = { species = "silvally"; ball = "cherish"; shiny = true; selfObtained = false; ability = "RKS System"; region = "ENG"; };
    specials."tapu-koko-1" = { species = "tapu-koko"; ball = "timer"; selfObtained = false; ability = "Electric Surge"; region = "ITA"; notes = "GTS"; };
    specials."tapu-lele-1" = { species = "tapu-lele"; ball = "ultra"; selfObtained = false; ability = "Psychic Surge"; region = "SPA"; notes = "GTS"; };
    specials."tapu-lele-2" = { species = "tapu-lele"; ball = "level"; selfObtained = true; ability = "Psychic Surge"; region = "ENG"; notes = "Max Lair"; };
    specials."tapu-bulu-1" = { species = "tapu-bulu"; ball = "poke"; selfObtained = false; ability = "Grassy Surge"; region = "ITA"; notes = "GTS"; };
    specials."tapu-bulu-2" = { species = "tapu-bulu"; ball = "luxury"; selfObtained = true; ability = "Grassy Surge"; region = "ENG"; notes = "Max Lair"; };
    specials."tapu-fini-1" = { species = "tapu-fini"; ball = "luxury"; selfObtained = true; ability = "Misty Surge"; region = "ENG"; notes = "Max Lair"; };
    specials."cosmog-1"    = { species = "cosmog"; ball = "poke"; selfObtained = false; ability = "Unaware"; region = "ENG"; notes = "2020/11/12"; };
    specials."cosmog-2"    = { species = "cosmog"; ball = "poke"; selfObtained = false; ability = "Unaware"; region = "ENG"; notes = "2020/08/16"; };
    specials."cosmoem-1"   = { species = "cosmoem"; ball = "poke"; selfObtained = false; };
    specials."solgaleo-1"  = { species = "solgaleo"; ball = "dusk"; selfObtained = false; ability = "Full Metal Body"; region = "ENG"; notes = "Got from OT 2020/07/12"; };
    specials."solgaleo-2"  = { species = "solgaleo"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Full Metal Body"; region = "ENG"; notes = "Eclipse 2020/08/16"; };
    specials."lunala-1"    = { species = "lunala"; ball = "luxury"; selfObtained = false; ability = "Shadow Shield"; region = "ENG"; };
    specials."lunala-2"    = { species = "lunala"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Shadow Shield"; region = "ENG"; };
    specials."nihilego-1"  = { species = "nihilego"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "JPN"; notes = "GTS"; };
    specials."buzzwole-1"  = { species = "buzzwole"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."pheromosa-1" = { species = "pheromosa"; ball = "safari"; selfObtained = true; ability = "Beast Boost"; region = "ENG"; notes = "Max Lair"; };
    specials."pheromosa-2" = { species = "pheromosa"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."xurkitree-1" = { species = "xurkitree"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."celesteela-1"= { species = "celesteela"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."kartana-1"   = { species = "kartana"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."guzzlord-1"  = { species = "guzzlord"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."necrozma-1"  = { species = "necrozma"; ball = "ultra"; selfObtained = false; ability = "Prism Armor"; region = "ENG"; notes = "Got from OT 2020/07/10"; };
    specials."necrozma-2"  = { species = "necrozma"; ball = "cherish"; shiny = true; selfObtained = false; ability = "Prism Armor"; region = "JPN"; notes = "event"; };
    specials."magearna-1"  = { species = "magearna"; ball = "cherish"; selfObtained = false; ability = "Soul-Heart"; region = "ENG"; };
    specials."marshadow-1" = { species = "marshadow"; ball = "cherish"; selfObtained = false; ability = "Technician"; region = "ENG"; notes = "Mt Tenei"; };
    specials."poipole-1"   = { species = "poipole"; ball = "beast"; selfObtained = true; ability = "Beast Boost"; region = "ENG"; notes = "0 speed 2021/02/26"; };
    specials."poipole-2"   = { species = "poipole"; ball = "poke"; shiny = true; selfObtained = false; ability = "Beast Boost"; region = "SPA"; notes = "GTS"; };
    specials."naganadel-1" = { species = "naganadel"; ball = "poke"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."stakataka-1" = { species = "stakataka"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; notes = "GTS"; };
    specials."blacephalon-1"= { species = "blacephalon"; ball = "beast"; selfObtained = false; ability = "Beast Boost"; region = "ENG"; notes = "GTS"; };
    specials."zeraora-1"   = { species = "zeraora"; ball = "cherish"; selfObtained = true; ability = "Volt Absorb"; region = "ENG"; };
    specials."zeraora-2"   = { species = "zeraora"; ball = "cherish"; shiny = true; selfObtained = true; ability = "Volt Absorb"; region = "ENG"; };
    specials."meltan-1"    = { species = "meltan"; ball = "ultra"; selfObtained = false; ability = "Magnet Pull"; region = "ENG"; notes = "got from OT 2020/10/11"; };
    specials."melmetal-1"  = { species = "melmetal"; ball = "premier"; selfObtained = false; ability = "Iron Fist"; region = "ENG"; notes = "got from OT 2020/08/25"; };
    specials."melmetal-2"  = { species = "melmetal"; ball = "poke"; shiny = true; selfObtained = false; region = "ENG"; notes = "2020/12/25 hc 700479142096797797"; };
    specials."melmetal-3"  = { species = "melmetal"; ball = "cherish"; selfObtained = true; ability = "Iron Fist"; region = "ENG"; notes = "OT 2020/11/19 (0 speed)"; };

    # » GENERATION 8
    specials."zacian-1"     = { species = "zacian"; ball = "beast"; selfObtained = true; ability = "Intrepid Sword"; region = "ENG"; ot = "pungkula"; id = "996385"; notes = "caught 2021/03/02 31 beast balls"; };
    specials."zamazenta-1"  = { species = "zamazenta"; ball = "beast"; selfObtained = true; ability = "Dauntless Shield"; region = "ENG"; ot = "pungkula"; id = "384971"; notes = "caught 2021/02/28 29 beast balls"; };
    specials."eternatus-1"  = { species = "eternatus"; ball = "beast"; selfObtained = true; ability = "Pressure"; region = "ENG"; ot = "pungkula"; id = "384971"; notes = "14 attack caught 2021/02/28"; };
    specials."eternatus-2"  = { species = "eternatus"; ball = "beast"; selfObtained = true; ability = "Pressure"; region = "ENG"; ot = "pungkula"; id = "996385"; notes = "1 attack caught 2021/03/01"; };
    specials."eternatus-3"  = { species = "eternatus"; ball = "luxury"; selfObtained = true; ability = "Pressure"; region = "ENG"; };
    specials."kubfu-1"      = { species = "kubfu"; name = "Pungfu"; ball = "poke"; selfObtained = true; ability = "Inner Focus"; region = "ENG"; notes = "2021-02-26 0 speed"; };
    specials."urshifu-1"    = { species = "urshifu"; ball = "poke"; selfObtained = true; ability = "Unseen Fist"; region = "ENG"; notes = "0 speed (Single Strike)"; };
    specials."urshifu-2"    = { species = "urshifu"; ball = "poke"; selfObtained = true; ability = "Unseen Fist"; region = "ENG"; notes = "Rapid Strike"; };
    specials."zarude-1"     = { species = "zarude"; ball = "cherish"; selfObtained = false; ability = "Leaf Guard"; region = "ENG"; notes = "2020-09-26"; };
    specials."zarude-dada-1"= { species = "zarude"; ball = "cherish"; selfObtained = false; notes = "Dada form"; };
    specials."regieleki-1"  = { species = "regieleki"; ball = "beast"; selfObtained = true; notes = "2021-02-26"; };
    specials."regieleki-2"  = { species = "regieleki"; ball = "poke"; shiny = true; selfObtained = false; };
    specials."regidrago-1"  = { species = "regidrago"; ball = "poke"; selfObtained = false; ability = "Dragon's Maw"; region = "ENG"; };
    specials."regidrago-2"  = { species = "regidrago"; ball = "poke"; shiny = true; selfObtained = false; };
    specials."glastrier-1"  = { species = "glastrier"; ball = "beast"; selfObtained = true; ability = "Chilling Neigh"; region = "ENG"; notes = "2020-11-21 (17 BBall attempts) (4iv 5 SpA)"; };
    specials."spectrier-1"  = { species = "spectrier"; ball = "beast"; selfObtained = true; region = "ENG"; notes = "2020-11-12 (13 BBall attempts) (4iv)"; };
    specials."calyrex-1"    = { species = "calyrex"; ball = "beast"; selfObtained = true; region = "ENG"; notes = "2020-11-12 (5iv 10 speed)"; };
    specials."calyrex-2"    = { species = "calyrex"; ball = "beast"; selfObtained = true; region = "ENG"; };
    specials."ice-rider-1"  = { species = "calyrex"; ball = "beast"; selfObtained = true; ability = "As One"; region = "ENG"; notes = "Ice Rider form; 2020-11-12 (13 BBall attempts)"; };
    specials."shadow-rider-1" = { species = "calyrex"; ball = "beast"; selfObtained = true; ability = "As One"; region = "ENG"; notes = "Shadow Rider form"; };
    specials."articuno-g-1" = { species = "articuno-galar"; ball = "beast"; selfObtained = true; ability = "Competitive"; region = "ENG"; notes = "2020-11-12 (413 BBall attempts)"; };
    specials."zapdos-g-1"   = { species = "zapdos-galar"; name = "Zapduck"; ball = "beast"; selfObtained = true; ability = "Defiant"; region = "ENG"; notes = "2020-11-08 (870 BBall attempts)"; };
    specials."zapdos-g-2"   = {
      species = "zapdos-galar";
      name = "Zapduck";
      ball = "luxury";
      shiny = false;
      selfObtained = true;
      ability = "Defiant";
      region = "ENG";
      marks = [ "Sleepy Time" ];
      notes = "Zzzleepy Marked 2021-02-26";
    };
    specials."moltres-g-1"  = { species = "moltres-galar"; ball = "beast"; selfObtained = true; ability = "Berserk"; region = "ENG"; notes = "2020-11-10 (15 BBall attempts)"; };

    specials."okidogi-1"     = { species = "okidogi"; ball = "poke"; selfObtained = false; };
    specials."munkidori-1"   = { species = "munkidori"; ball = "poke"; selfObtained = false; };
    specials."fezandipiti-1" = { species = "fezandipiti"; ball = "poke"; selfObtained = false; };
    specials."ogerpon-1"     = { species = "ogerpon"; ball = "beast"; selfObtained = true; notes = "2023/09/23"; };


    # 🦆 ⮞ EVENT POKÉMON
    events = {
      # »  2003  «
      "farfetchd-2003-jemma" = {
        species="farfetchd"; dex=83; name="Farfetch'd"; ball="pokeball"; year="2003"; ot="Jemma"; id="17749"; region="ENG"; notes="WiSHMKR";
        proof="friend of OT TC"; obtained="2021/02/16"; moves=[ "Wish" "Yawn" ]; tradeHistory="GoroMajimaIsMyIdol#8508 > pungkula";
      };
      "jirachi-2003-wishmkr-1" = {
        species="jirachi"; dex=385; name="Jirachi"; ball="pokeball"; shiny=true; year="2003"; ot="WISHMKR"; id="20043"; region="ENG"; notes="WiSHMKR"; moves=[ "Wish" "Confusion" "Rest" ];
      };
      "jirachi-2003-wishmkr-2" = {
        species="jirachi"; dex=385; name="Jirachi"; ball="pokeball"; shiny=true; year="2003"; ot="WISHMKR"; id="20043"; region="ENG"; notes="WiSHMKR"; moves=[ "Wish" "Confusion" "Rest" ];
      };

      # »  2005-2006  «
      "mew-2005-old-sea" = {
        species="mew"; dex=151; name="Mew"; ball="pokeball"; shiny=true; year="2005"; ot="JPN??"; region="JPN"; notes="Old Sea"; moves=[ "Aerobatics" "Giga Drain" "False Swipe" "Thunder Wave" ];
      };
      "articuno-2006-10aniv" = {
        species="articuno"; dex=144; name="Articuno"; ball="pokeball"; year="2006"; ot="10ANIV"; id="06227"; region="ENG"; notes="10th Anniversary";
        moves=[ "Agility" "Mind Reader" "Ice Beam" "Reflect" ];
      };
      "celebi-2006-10aniv" = {
        species="celebi"; dex=251; name="Celebi"; ball="pokeball"; year="2006"; ot="10 ANIV"; id="00010"; region="ENG"; notes="10th Anniversary";
        moves=[ "Ancient Power" "Giga Drain" "Baton Pass" "Future Sight" ];
      };

      # »  2009  «
      "regigigas-2009-tru" = {
        species="regigigas"; dex=486; name="Regigigas"; ball="cherish"; year="2009"; ot="TRU"; id="03089"; region="ENG"; notes="Toys 'R Us"; obtained="2020/11/20";
        moves=[ "Iron Head" "Rock Slide" "Icy Wind" "Crush Grip" ];
      };
      "arceus-2009-tru" = {
        species="arceus"; dex=493; name="Arceus"; ball="cherish"; year="2009"; ot="TRU"; id="11079"; region="ENG"; notes="Toys 'R Us"; proof="WC from OT"; obtained="2020/08/24";
        moves=[ "Judgment" "Roar of Time" "Spacial Rend" "Shadow Force" ]; tradeHistory="Omega Galaxy#2683 -> pungkula";
      };

      # »  2011  «
      "raikou-2011-gamestp" = {
        species="raikou"; dex=243; name="Raikou"; ball="cherish"; shiny=true; year="2011"; ot="GAMESTP"; id="01031"; region="ENG"; notes="GAMESTP"; proof="WC from OT"; obtained="2020/08/24";
        moves=[ "Zap Cannon" "Aura Sphere" "Extreme Speed" "Weather Ball" ]; tradeHistory="Omega Galaxy#2683 -> pungkula";
      };
      "suicune-2011-gamestp" = {
        species="suicune"; dex=245; name="Suicune"; ball="cherish"; shiny=true; year="2011"; ot="GAMESTP"; id="01311"; region="ENG"; notes="GAMESTP"; proof="WC from OT"; obtained="2020/08/24";
        moves=[ "Sheer Cold" "Hydro Pump" "Extreme Speed" "Blizzard" ]; tradeHistory="Omega Galaxy#2683 -> pungkula";
      };

      # »  2012  «
      "pikachu-2012-world12" = {
        species="pikachu"; ball="cherish"; dex=25; name="Pikachu"; year="2012"; ot="WORLD12"; id="08122"; region="ENG"; notes="World12"; obtained="2021/02/16";
        moves=[ "Fly" "Thunderbolt" "Grass Knot" "Protect" ]; tradeHistory="Deathbane98#5493 -> pungkula";
      };
      "tyranitar-2012-vgc12" = {
        species="tyranitar"; ball="cherish"; dex=248; name="Tyranitar"; shiny=true; year="2012"; ot="VGC12"; id="03032"; region="ENG"; notes="VGC12"; obtained="2020/02/16";
        moves=[ "Earthquake" "Crunch" "Stone Edge" "Superpower" ]; tradeHistory="Deathbane98#5493 -> pungkula";
      };
      "darkrai-2012-2012may" = {
        species="darkrai"; ball="cherish"; dex=491; name="Darkrai"; year="2012"; ot="2012MAY"; id="05092"; region="ENG"; notes="Dark Explorers"; obtained="2020/08/21";
        moves=[ "Dark Void" "Ominous Wind" "Feint Attack" "Nightmare" ]; tradeHistory="Alto#0457 -> pungkula";
      };
      "victini-2012-movie14" = {
        species="victini"; ball="cherish"; dex=494; name="Victini"; year="2012"; ot="Movie14"; id="12031"; region="ENG"; notes="Black and White Movie"; obtained="2020/10/06";
        moves=[ "V-create" "Fusion Flare" "Fusion Bolt" "Searing Shot" ]; tradeHistory="chips#8386 -> pungkula";
      };
      "zekrom-2012-spr2012-1" = {
        species="zekrom"; ball="cherish"; dex=644; name="Zekrom"; year="2012"; ot="SPR2012"; id="03102"; region="ENG"; notes="1st Anniversary"; moves=[ "Bolt Strike" "Fusion Bolt" "Haze" "Outrage" ];
      };
      "zekrom-2012-spr2012-2" = {
        species="zekrom"; ball="cherish"; dex=644; name="Zekrom"; year="2012"; ot="SPR2012"; id="03102"; region="ENG"; notes="1st Anniversary"; obtained="2021/02/16";
        #mark="∆";
        moves=[ "Bolt Strike" "Fusion Bolt" "Haze" "Outrage" ]; tradeHistory="Deathbane98#5493 -> pungkula";
      };
      "keldeo-2012-smr2012" = {
        species="keldeo"; ball="cherish"; dex=647; name="Keldeo"; year="2012"; ot="SMR2012"; id="08272"; region="ENG"; notes="SMR2012";
        #mark="∆";
        obtained="2020/08/29"; moves=[ "Sacred Sword" "Aqua Tail" "Double Kick" "Bubble Beam" ]; tradeHistory="Waterfly#8598 -> pungkula";
      };
      "keldeo-2012-ver2012" = {
        species="keldeo"; ball="cherish"; dex=647; name="Keldeo"; year="2012"; ot="VER2012"; id="08272"; region="SPA"; notes="VER";
        moves=[ "Aqua Jet" "Sacred Sword" "Double Kick" "Surf" ];
      };

      # »  2013  «
      "smeargle-2013-world13" = {
        species="smeargle"; ball="cherish"; dex=235; name="Smeargle"; year="2013"; ot="WORLD13"; id="08113"; region="ENG"; notes="VGC Ultimate Smeargle"; obtained="2020/12/26";
        moves=[ "False Swipe" "Spore" "Odor Sleuth" "Mean Look" ];
      };
      "dialga-2013-sum2013" = {
        species="dialga"; ball="cherish"; dex=483; name="Dialga"; shiny=true; year="2013"; ot="SUM2013"; id="08303"; region="ENG"; notes="GAMESTP"; obtained="2020/08/26"; moves=[ "Dragon Pulse" "Draco Meteor" "Aura Sphere" "Roar of Time" ]; tradeHistory="Alto#0457";
      };
      "palkia-2013-sum2013-1" = {
        species="palkia"; ball="cherish"; dex=484; name="Palkia"; shiny=true; year="2013"; ot="SUM2013"; id="09133"; region="ENG"; notes="GAME Distribution"; obtained="2020/08/26";
        moves=[ "Aura Sphere" "Spacial Rend" "Hydro Pump" "Draco Meteor" ]; tradeHistory="Alto#0457";
      };
      "palkia-2013-sum2013-2" = {
        species="palkia"; ball="cherish"; dex=484; name="Palkia"; shiny=true; year="2013"; ot="SUM2013"; id="09133"; region="ENG"; obtained="2021/02/16";
        moves=[ "Aura Sphere" "Spacial Rend" "Hydro Pump" "Draco Meteor" ]; tradeHistory="Deathbane98#5493 -> pungkula";
      };
      "giratina-2013-sum2013" = {
        species="giratina"; ball="cherish"; dex=487; name="Giratina"; shiny=true; year="2013"; ot="SUM2013"; id="09303"; region="ENG"; notes="Gamestop Distribution"; obtained="2020/10/06"; moves=[ "Dragon Pulse" "Dragon Claw" "Aura Sphere" "Shadow Force" ]; tradeHistory="chips#8386 -> pungkula";
      };
      "meloetta-2013-spr2013" = {
        species="meloetta"; ball="cherish"; dex=648; name="Meloetta"; year="2013"; ot="SPR2013"; id="03013"; region="ENG"; notes="Gamestop"; obtained="2020/08/27";
        moves=[ "Round" "Teeter Dance" "Psychic" "Close Combat" ]; tradeHistory="Alto#0457 -> pungkula";
      };
      "genesect-2013-jpn" = {
        species="genesect"; ball="cherish"; dex=649; name="Genesect"; shiny=true; year="2013"; ot="JPN????"; id="07133"; region="ENG"; notes="Genesect Movie Event";
        obtained="2020/10/06"; moves=[ "Extreme Speed" "Techno Blast" "Blaze Kick" "Shift Gear" ]; tradeHistory="chips#8386 -> pungkula";
      };

      # »  2014  «
      "vivillon-2014-gts" = {
        species="vivillon"; ball="cherish"; dex=666; name="Vivillon"; year="2014"; ot="GTS"; id="00108"; region="ENG"; notes="Fancy Pattern"; obtained="2021/03/16";
        moves=[ "Gust" "Light Screen" "Struggle Bug" "Hold Hands" ]; tradeHistory="GoroMajimaIsMyIdol#8508 > pungkula";
      };
      "vivillon-2014-sum2014" = {
        species="vivillon"; ball="pokeball"; dex=666; name="Vivillon"; year="2014"; ot="SUM2014"; id="08064"; region="ENG"; notes="Pokeball Pattern"; obtained="2021/03/16";
        moves=[ "Stun Spore" "Gust" "Light Screen" "Struggle Bug" ]; tradeHistory="GoroMajimaIsMyIdol#8508 > pungkula";
      };

      # »  2015  «
      "rayquaza-2015-galileo" = {
        species="rayquaza"; ball="cherish"; dex=384; name="Rayquaza"; shiny=true; year="2015"; ot="Galileo"; id="08055"; region="ENG"; notes="Ancient Origins Galileo";
        obtained="2021/02/07"; moves=[ "Dragon Pulse" "Extreme Speed" "Hyper Voice" "Dragon Ascent" ];
      };
      "jirachi-2015-nintendo-hk" = {
        species="jirachi"; ball="cherish"; dex=385; name="Jirachi"; shiny=true; year="2015"; ot="Nintendo HK"; id="12015"; region="SPA"; notes="Nintendo HK";
        moves=[ "Wish" "Confusion" "Swift" "Happy Hour" ];
      };
      "diancie-2015-jpn" = {
        species="diancie"; ball="cherish"; dex=719; name="Diancie"; shiny=true; year="2015"; ot="JPN???"; id="12125"; region="ENG"; notes="Mega Evolution Promo"; obtained="2020/10/06";
        moves=[ "Diamond Storm" "Moonblast" "Reflect" "Return" ]; tradeHistory="chips#8386 -> pungkula";
      };

      # »  2016  «
      "mewtwo-2016-play-2016" = {
        species="mewtwo"; ball="cherish"; dex=150; name="Mewtwo"; shiny=true; year="2016"; ot="Play! 2016"; id="07266"; region="ENG"; notes="Play!"; obtained="2020/08/25";
        moves=[ "Psystrike" "Psychic" "Recover" "Aura Sphere" ]; tradeHistory="Jaro#6218 -> pungkula";
      };
      "ho-oh-2016-pc-kyoto" = {
        species="ho-oh"; ball="cherish"; dex=250; name="Ho-Oh"; shiny=true; year="2016"; ot="PCキョウト"; id="03166"; region="ENG"; obtained="2021/02/16";
        moves=[ "Sacred Fire" "Brave Bird" "Recover" "Celebrate" ]; tradeHistory="doodle pie#5495 > pungkula";
      };
      "celebi-2016-gf" = {
        species="celebi"; ball="cherish"; dex=251; name="Celebi"; year="2016"; ot="GF"; id="03016"; region="ENG"; notes="20th Anniversary";
        moves=[ "Confusion" "Recover" "Heal Bell" "Safeguard" ];
      };
      "manaphy-2016-gf" = {
        species="manaphy"; ball="cherish"; dex=490; name="Manaphy"; year="2016"; ot="GF"; id="06016"; region="ENG"; notes="20th Anniversary"; obtained="2020/10/10"; moves=[ "Tail Glow" "Bubble" "Water Sport" ]; tradeHistory="SoulChameleon#5664 -> pungkula";
      };
      "darkrai-2016-gf" = {
        species="darkrai"; ball="cherish"; dex=491; name="Darkrai"; year="2016"; ot="GF"; id="05016"; region="ENG"; notes="GF"; obtained="2021/02/09";
        moves=[ "Dark Void" "Ominous Wind" "Nightmare" "Feint Attack" ]; tradeHistory="Bees’that-ramble#0728 > pungkula";
      };
      "yveltal-2016-xyz" = {
        species="yveltal"; ball="cherish"; dex=717; name="Yveltal"; shiny=true; year="2016"; ot="XYZ"; id="05206"; region="ENG"; notes="Pokémon Fates Collide XYZ";
        obtained="2021/02/05"; moves=[ "Oblivion Wing" "Sucker Punch" "Dark Pulse" "Foul Play" ];
      };
      "greninja-2016-ash" = {
        species="greninja"; ball="pokeball"; dex=658; name="Greninja"; year="2016"; ot="Ash"; id="131017"; region="ENG"; notes="Ash's Greninja"; obtained="2020/10/28";
        #mark="∆❤️️";
        moves=[ "Water Shuriken" "Aerial Ace" "Double Team" "Night Slash" ]; tradeHistory="seret42#0924 -> pungkula";
      };
      "volcanion-2016-nebel" = {
        species="volcanion"; ball="cherish"; dex=721; name="Volcanion"; year="2016"; ot="Nebel"; id="11036"; region="ENG"; notes="Volcanion & Mechanical Marvel";
        #mark="∆";
        obtained="2020/10/28"; moves=[ "Steam Eruption" "Overheat" "Hydro Pump" "Mist" ]; tradeHistory="seret42#0924 -> pungkula";
      };
      "hoopa-2016-alexander" = {
        species="hoopa"; ball="cherish"; dex=720; name="Hoopa"; year="2016"; ot="Alexander"; id="10036"; region="ENG"; proof="WC from OT"; obtained="2021/02/19";
        moves=[ "Hyperspace Hole" "Psychic" "Astonish" "Nasty Plot" ]; tradeHistory="kaeluxx#5799 -> pungkula";
      };
      "magearna-2016-kano" = {
        species="magearna"; ball="cherish"; dex=801; name="Magearna"; year="2016"; ot="Kano"; id="890324"; region="ENG"; notes="Code Distribution"; obtained="2020/08/19";
        moves=[ "Fleur Cannon" "Flash Cannon" "Crafty Shield" "Helping Hand" ];
      };
      "xerneas-2016-xyz" = {
        species="xerneas"; ball="cherish"; dex=716; name="Xerneas"; shiny=true; year="2016"; ot="XYZ"; id="05116"; region="ENG"; obtained="2021/03/15";
        moves=[ "Geomancy" "Moonblast" "Aromatherapy" "Focus Blast" ]; tradeHistory="Protest#2763 -> pungkula";
      };

      # »  2017  «
      "pikachu-2017-unova-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2017"; ot="サトシ"; id="100923"; region="ENG"; notes="Unova Cap";
      };
      "pikachu-2017-kalos-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2017"; ot="Ash"; id="120516"; region="ENG"; notes="Kalos Cap";
      };
      "pikachu-2017-alola-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2017"; ot="サトシ"; id="161117"; region="JPN"; notes="Alola Cap";
      };
      "pikachu-2017-partner-cap-ger" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2017"; ot="Ash"; id="170715"; region="GER"; notes="Partner Cap";
      };
      "pikachu-2017-partner-cap-eng" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2017"; ot="Ash"; id="170715"; region="ENG"; notes="Partner Cap";
      };
      "silvally-2017-aether" = {
        species="silvally"; ball="cherish"; dex=773; name="Silvally"; shiny=true; year="2017"; ot="Aether"; id="102317"; region="ENG"; notes="Aether"; obtained="2020/09/04";
        moves=[ "Multi-Attack" "Parting Shot" "Swift" "Scary Face" ]; tradeHistory="HeadPool#0836 -> pungkula";
      };
      "marshadow-2017-mt-tensei-1" = {
        species="marshadow"; ball="cherish"; dex=802; name="Marshadow"; year="2017"; ot="MT. Tensei"; id="100917"; region="ENG";
        #mark="❤";
        moves=[ "Spectral Thief" "Close Combat" "Shadow Sneak" "Throat Chop" ];
      };
      "marshadow-2017-mt-tensei-2" = {
        species="marshadow"; ball="cherish"; dex=802; name="Marshadow"; year="2017"; ot="MT. Tensei"; id="100917"; region="ENG";
        #mark="∆";
        moves=[ "Spectral Thief" "Close Combat" "Force Palm" "Shadow Ball" ];
      };
      "exeggutor-alola-2017-worlds17" = {
        species="exeggutor-alola"; ball="cherish"; dex=103; name="Exeggutor (Alola)"; year="2017"; ot="Worlds17"; id="081817"; region="ENG"; notes="World 2017"; proof="Video";
        obtained="2021/03/01"; moves=[ "Power Swap" "Celebrate" "Leaf Storm" "Draco Meteor" ]; tradeHistory="SIT0#7561 > pungkula";
      };

      # »  2018  «
      "pikachu-2018-original-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2018"; ot="Satoshi"; id="970401"; region="ENG"; notes="Original Cap";
      };
      "pikachu-2018-sinnoh-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; year="2018"; ot="Ash"; id="060407"; region="ENG"; notes="Sinnoh Cap";
      };
      "raichu-alola-2018" = {
        species="raichu-alola"; ball="cherish"; dex=26; name="Raichu (Alola)"; shiny=true; year="2018"; ot="JPN??"; id="337500"; region="ENG"; notes="Evolved Alola Pika";
        obtained="2020/10/06"; moves=[ "Thunder" "Expanding Force" "Volt Switch" "Rising Voltage" ]; tradeHistory="Steez#0420 -> pungkula";
      };
      "zygarde-2018-legends" = {
        species="zygarde"; ball="cherish"; dex=718; name="Zygarde"; shiny=true; year="2018"; region="ENG"; notes="2018 Legends"; obtained="2021/03/09";
      };
      "shaymin-2018-jpn" = {
        species="shaymin"; ball="cherish"; dex=492; name="Shaymin"; year="2018"; ot="JPN???"; id="180425"; region="ENG"; notes="20th Anniversary"; obtained="2020/10/06";
        moves=[ "Energy Ball" "Sweet Kiss" "Healing Wish" "Seed Flare" ]; tradeHistory="chips#8386 -> pungkula";
      };
      "tapu-lele-2018-akala" = {
        species="tapu-lele"; ball="cherish"; dex=786; name="Tapu Lele"; shiny=true; year="2018"; ot="Akala"; id="181130"; region="ENG"; obtained="2021/02/22";
        moves=[ "Magic Room" "Dazzling Gleam" "Nature's Madness" "Psychic" ]; tradeHistory="Protest#2763 -> pungkula";
      };

      # »  2019  «
      "solgaleo-2019-eclipse" = {
        species="solgaleo"; ball="cherish"; dex=791; name="Solgaleo"; shiny=true; year="2019"; ot="Eclipse"; id="100419"; region="ENG"; notes="Gamestop Eclipse"; obtained="2020/08/16";
        moves=[ "Sunsteel Strike" "Zen Headbutt" "Noble Roar" "Morning Sun" ];
      };
      "lunala-2019-eclipse" = {
        species="lunala"; ball="cherish"; dex=792; name="Lunala"; shiny=true; year="2019"; ot="Eclipse"; id="100419"; region="ENG"; notes="Gamestop Eclipse"; obtained="2020/08/25";
        moves=[ "Moongeist Beam" "Psyshock" "Moonblast" "Moonlight" ]; tradeHistory="Jaro#6218 -> pungkula";
      };
      "zeraora-2019-fula-city" = {
        species="zeraora"; ball="cherish"; dex=807; name="Zeraora"; selfObtained=true; year="2019"; ot="Fula City"; id="100118"; region="ENG"; notes="EB Games Distribution";
        #mark="🔴";
        moves=[ "Plasma Fists" "Thunder Punch" "Close Combat" "Thunder" ];
      };
      "tapu-fini-2019-poni" = {
        species="tapu-fini"; ball="cherish"; dex=788; name="Tapu Fini"; shiny=true; year="2019"; ot="Poni"; id="190524"; region="ENG"; notes="International Challenge May";
        obtained="2021/02/07"; moves=[ "Hydro Pump" "Ice Beam" "Moonblast" "Calm Mind" ]; tradeHistory="PicEm09#4880 -> pungkula";
      };
      "tapu-koko-2019-melemele" = {
        species="tapu-koko"; ball="cherish"; dex=785; name="Tapu Koko"; shiny=true; year="2019"; ot="Melemele"; id="191004"; region="ENG"; obtained="2021/02/20";
        moves=[ "Thunderbolt" "Dazzling Gleam" "Volt Switch" "Nature's Madness" ]; tradeHistory="Protest#2763 -> pungkula";
      };
      "tapu-koko-2019-ulaula" = {
        species="tapu-koko"; ball="cherish"; dex=785; name="Tapu Koko"; shiny=true; year="2019"; ot="Ula'ula"; id="190222"; region="ENG"; obtained="2021/02/24";
        moves=[ "Nature's Madness" "Zen Headbutt" "Megahorn" "Skull Bash" ]; tradeHistory="Protest#2763 -> pungkula";
      };

      # »  2020  «
      "pikachu-2020-original-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Original Cap"; proof="WC"; obtained="2020/09/26";
        #mark="🔴";
      };
      "pikachu-2020-partner-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Partner Cap"; proof="WC"; obtained="2020/09/29";
        #mark="🔴";
      };
      "pikachu-2020-hoenn-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Hoenn Cap"; proof="WC"; obtained="2020/10/02";
        #mark="🔴";
      };
      "pikachu-2020-sinnoh-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Sinnoh Cap"; proof="WC"; obtained="2020/10/09";
        #mark="🔴";
      };
      "pikachu-2020-unova-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Unova Cap: October 16"; proof="WC";
        #mark="🔴";
      };
      "pikachu-2020-kalos-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Kalos Cap: October 18"; proof="WC";
        #mark="🔴";
      };
      "pikachu-2020-alola-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="Alola Cap: October 23"; proof="WC";
        #mark="🔴";
      };
      "pikachu-2020-world-cap" = {
        species="pikachu"; ball="pokeball"; dex=25; name="Pikachu"; selfObtained=true; year="2020"; ot="Ash"; id="201023"; region="ENG"; notes="World Cap: October 30"; proof="WC";
        #mark="🔴";
      };
      "meowth-galar-2020" = {
        species="meowth-galar"; ball="cherish"; dex=52; name="Meowth (Galar)"; selfObtained=true; year="2020"; ot="pungkula"; id="082409"; region="ENG"; notes="Sword & Shield"; proof="WC";
        moves=[ "Fake Out" "Growl" "Hone Claws" "Pay Day" ];
      };
      "ponyta-galar-2020" = {
        species="ponyta-galar"; ball="cherish"; dex=77; name="Ponyta (Galar)"; year="2020"; ot="PasDer"; id="705133"; region="ENG"; notes="Sword & Shield"; obtained="2020/08/26";
        moves=[ "Tackle" "Growl" "Confusion" "Fairy Wind" ]; tradeHistory="PasDer#4937";
      };
      "mr-mime-galar-2020" = {
        species="mr-mime-galar"; ball="cherish"; dex=122; name="Mr. Mime (Galar)"; selfObtained=true; year="2020"; ot="pungkula"; id="082409"; region="ENG"; notes="Sword & Shield";
        proof="WC"; moves=[ "Copycat" "Encore" "Ice Shard" "Confusion" ];
      };
      "corsola-galar-2020" = {
        species="corsola-galar"; ball="cherish"; dex=222; name="Corsola (Galar)"; selfObtained=true; year="2020"; ot="pungkula"; id="082409"; region="ENG"; notes="Sword & Shield";
        proof="WC"; moves=[ "Tackle" "Astonish" "Disable" "Spite" ];
      };
      "porygon2-2020" = {
        species="porygon2"; ball="cherish"; dex=233; name="Porygon2"; selfObtained=true; year="2020"; ot="pungkula"; id="082409"; region="ENG"; notes="Players Cup Gift"; proof="WC";
        moves=[ "Recover" "Trick Room" "Ice Beam" "Thunderbolt" ];
      };
      "celebi-2020-coco" = {
        species="celebi"; ball="cherish"; dex=251; name="Celebi"; shiny=true; year="2020"; ot="JPN"; id="200807"; region="JPN"; notes="Pokémon Movie Coco"; obtained="2020/08/21";
        moves=[ "Magical Leaf" "Future Sight" "Life Dew" "Heal Bell" ];
      };
      "gastrodon-2020-japan-championships" = {
        species="gastrodon"; ball="cherish"; dex=423; name="Gastrodon"; selfObtained=true; year="2020"; ot="JPN???"; id="200822"; region="JPN"; notes="Japan Championships";
        proof="WC"; obtained="2020/08/22"; moves=[ "Protect" "Surf" "Ice Beam" "Earth Power" ];
      };
      "amoonguss-2020-baik-jongyoon" = {
        species="amoonguss"; ball="cherish"; dex=591; name="Amoonguss"; shiny=true; year="2020"; ot="JPN???"; id="200809"; region="KOR"; notes="Baik Jongyoon's";
        moves=[ "Clear Smog" "Spore" "Protect" "Rage Powder" ];
      };
      "zeraora-2020-home-1" = {
        species="zeraora"; ball="cherish"; dex=807; name="Zeraora"; shiny=true; selfObtained=true; year="2020"; ot="HOME"; id="200630"; region="ENG"; notes="Max Raid Battle Gift";
        #mark="🔴";
        proof="Picture"; obtained="2020/06/30"; moves=[ "Plasma Fists" "Close Combat" "Blaze Kick" "Outrage" ];
      };
      "zeraora-2020-home-2" = {
        species="zeraora"; ball="cherish"; dex=807; name="Zeraora"; shiny=true; year="2020"; ot="HOME"; id="200630"; region="ENG"; notes="Max Raid Battle Gift";
        #mark="∆";
        moves=[ "Plasma Fists" "Close Combat" "Blaze Kick" "Outrage" ];
      };
      "zarude-2020-jungle-1" = {
        species="zarude"; ball="cherish"; dex=893; name="Zarude"; year="2020"; ot="Jungle"; id="200807"; region="ENG"; notes="Pokémon Movie Coco"; obtained="2020/09/26";
        moves=[ "Close Combat" "Power Whip" "Swagger" "Snarl" ];
      };
      "zarude-2020-jungle-2" = {
        species="zarude"; ball="cherish"; dex=893; name="Zarude"; selfObtained=true; year="2020"; ot="Jungle"; id="2001113"; region="ENG"; notes="Coco Movie NL Distribution";
        #mark="🔴❤️️";
        proof="WC"; obtained="2020/11/24"; moves=[ "Close Combat" "Power Whip" "Swagger" "Snarl" ];
      };
      "zarude-dada-2020-coco" = {
        species="zarude-dada"; ball="cherish"; dex=893; name="Zarude (Dada)"; year="2020"; ot="JPN???"; id="201225"; region="JPN"; notes="Pokémon Movie Coco"; obtained="2020/12/25";
        #mark="∆";
        moves=[ "Jungle Healing" "Hammer Arm" "Power Whip" "Energy Ball" ];
      };
      "melmetal-gmax-2020-home" = {
        species="melmetal-gmax"; ball="cherish"; dex=809; name="Melmetal (GMax)"; selfObtained=true; year="2020"; ot="HOME"; id="808809"; region="ENG"; notes="PoGO Transfer";
        #mark="🔴";
        proof="Picture"; obtained="2020/11/19"; moves=[ "Double Iron Bash" "Hyper Beam" "Dynamic Punch" "Thunder Punch" ];
      };

      # »  2021  «
      "pikachu-2021-kibo" = {
        species="pikachu"; ball="cherish"; dex=25; name="Pikachu"; selfObtained=true; year="2021"; ot="KIBO"; id="210101"; region="ENG"; notes="Space Sunrise Gift";
        #mark="🔴❤";
        proof="WC"; obtained="2021/01/05"; moves=[ "Thunderbolt" "Swift" "Wish" "Celebrate" ];
      };
      "magearna-2021-pungkula" = {
        species="magearna"; ball="cherish"; dex=801; name="Magearna"; selfObtained=true; year="2021"; ot="Pungkula"; id="585967"; region="ENG"; notes="National Pokédex Completion";
        #mark="🔴";
        proof="Picture"; obtained="2021/01/05"; moves=[ "Fleur Cannon" "Flash Cannon" "Defense Curl" "Rest" ];
      };
      "pikachu-2021-gf-1" = {
        species="pikachu"; ball="cherish"; dex=25; name="Pikachu"; selfObtained=true; year="2021"; ot="GF"; id="210227"; region="ENG"; proof="Video + WC";
        obtained="2021/02/25"; moves=[ "Sing" "Encore" "Celebrate" "Electro Ball" ];
      };
      "pikachu-2021-gf-2" = {
        species="pikachu"; ball="cherish"; dex=25; name="Pikachu"; selfObtained=true; year="2021"; ot="GF"; id="210227"; region="ENG"; proof="Video + WC"; obtained="2021/02/25";
        moves=[ "Sing" "Encore" "Celebrate" "Electro Ball" ];
      };
      "melmetal-gmax-2021-home" = {
        species="melmetal-gmax"; ball="cherish"; dex=809; name="Melmetal (GMax)"; selfObtained=true; year="2021"; ot="HOME"; id="808809"; region="ENG"; notes="PoGO Transfer";
        #mark="🔴";
        proof="Picture"; obtained="2021/04/06"; moves=[ "Double Iron Bash" "Hyper Beam" "Dynamic Punch" "Thunder Punch" ];
      };
      "toxtricity-2021-rock-star" = {
        species="toxtricity"; ball="cherish"; dex=849; name="Toxtricity"; shiny=true; selfObtained=true; year="2021"; ot="Rock Star"; id="210219"; region="ENG"; notes="Shining Fates Tie-In";
        #mark="🔴";
        proof="WC + code"; obtained="2021/02/20"; moves=[ "Overdrive" "Sludge Wave" "Boomburst" "Rising Voltage" ];
      };
      "bulbasaur-2021-home-june" = {
        species="bulbasaur"; ball="cherish"; dex=1; name="Bulbasaur"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift";
        #mark="🔴❤";
        proof="WC"; obtained="2021/06/17";
      };
      "ivysaur-2021-home-june" = {
        species="ivysaur"; ball="cherish"; dex=2; name="Ivysaur"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "venusaur-2021-home-june" = {
        species="venusaur"; ball="cherish"; dex=3; name="Venusaur"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "squirtle-2021-home-june" = {
        species="squirtle"; ball="cherish"; dex=7; name="Squirtle"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; proof="WC"; obtained="2021/06/17";
        #mark="🔴❤";
      };
      "wartortle-2021-home-june" = {
        species="wartortle"; ball="cherish"; dex=8; name="Wartortle"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "blastoise-2021-home-june" = {
        species="blastoise"; ball="cherish"; dex=9; name="Blastoise"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "bulbasaur-2021-home-june-2" = {
        species="bulbasaur"; ball="cherish"; dex=1; name="Bulbasaur"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift";
        #mark="🔴❤";
        proof="WC"; obtained="2021/06/17";
      };
      "squirtle-2021-home-june-2" = {
        species="squirtle"; ball="cherish"; dex=7; name="Squirtle"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; proof="WC"; obtained="2021/06/17";
        #mark="🔴❤";
      };
      "bulbasaur-2021-home-june-3" = {
        species="bulbasaur"; ball="cherish"; dex=1; name="Bulbasaur"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "squirtle-2021-home-june-3" = {
        species="squirtle"; ball="cherish"; dex=7; name="Squirtle"; selfObtained=true; year="2021"; ot="HOME"; id="210601"; region="ENG"; notes="HOME June Update Gift"; obtained="2021/06/17";
        #mark="🔴";
      };
      "torkoal-2021-japan-championships-1" = {
        species="torkoal"; ball="cherish"; dex=324; name="Torkoal"; selfObtained=true; year="2021"; ot="クララ"; id="210718"; region="JPN"; notes="Japan Championships 2021";
        #mark="🔴";
        proof="Video"; obtained="2021/07/18"; moves=[ "Burning Jealousy" "Body Press" "Yawn" "Protect" ];
      };
      "torkoal-2021-japan-championships-2" = {
        species="torkoal"; ball="cherish"; dex=324; name="Torkoal"; selfObtained=true; year="2021"; ot="クララ"; id="210718"; region="JPN"; notes="Japan Championships 2021";
        #mark="🔴";
        proof="WC"; obtained="2021/07/18"; moves=[ "Burning Jealousy" "Body Press" "Yawn" "Protect" ];
      };
      "torkoal-2021-japan-championships-3" = {
        species="torkoal"; ball="cherish"; dex=324; name="Torkoal"; selfObtained=true; year="2021"; ot="クララ"; id="210718"; region="JPN"; notes="Japan Championships 2021";
        #mark="🔴";
        proof="WC"; obtained="2021/07/18"; moves=[ "Burning Jealousy" "Body Press" "Yawn" "Protect" ];
      };
      "porygon-z-2021-jeong-1" = {
        species="porygon-z"; ball="cherish"; dex=474; name="Porygon-Z"; selfObtained=true; year="2021"; ot="정상윤"; id="210807"; region="KOR";
        #mark="🔴";
        notes="Jeong Sang-yoon's Porygon-Z"; proof="WC"; obtained="2021/08/21"; moves=[ "Hyper Beam" "Thunderbolt" "Dark Pulse" "Nasty Plot" ];
      };
      "porygon-z-2021-jeong-2" = {
        species="porygon-z"; ball="cherish"; dex=474; name="Porygon-Z"; selfObtained=true; year="2021"; ot="정상윤"; id="210807"; region="KOR";
        #mark="🔴";
        notes="Jeong Sang-yoon's Porygon-Z"; proof="WC"; obtained="2021/08/21"; moves=[ "Hyper Beam" "Thunderbolt" "Dark Pulse" "Nasty Plot" ];
      };
      "porygon-z-2021-jeong-3" = {
        species="porygon-z"; ball="cherish"; dex=474; name="Porygon-Z"; selfObtained=true; year="2021"; ot="정상윤"; id="210807"; region="KOR";
        #mark="🔴";
        notes="Jeong Sang-yoon's Porygon-Z"; proof="WC"; obtained="2021/08/21"; moves=[ "Hyper Beam" "Thunderbolt" "Dark Pulse" "Nasty Plot" ];
      };
      "coalossal-2021-wolfe" = {
        species="coalossal"; ball="cherish"; dex=839; name="Coalossal"; year="2021"; notes="wolfe"; proof="WC"; obtained="2021/09/03"; tradeHistory="Popski'#5621 > pungkula";
      };
      "hoopa-2021-pogo" = {
        species="hoopa"; ball="pokeball"; dex=720; name="Hoopa"; selfObtained=true; year="2021"; notes="PoGo - Hoopa's Arrival"; obtained="2021/09/05";
      };
      "hoopa-unbound-2021-pogo" = {
        species="hoopa-unbound"; ball="pokeball"; dex=720; name="Hoopa (Unbound)"; selfObtained=true; year="2021"; notes="PoGo - Hoopa's Arrival"; obtained="2021/09/05";
      };
      "zacian-2021-shiny" = {
        species="zacian"; ball="cherish"; dex=888; name="Zacian"; shiny=true; selfObtained=true; year="2021"; proof="WC"; obtained="2021/10/23";
      };
      "zamazenta-2021-shiny" = {
        species="zamazenta"; ball="cherish"; dex=889; name="Zamazenta"; shiny=true; selfObtained=true; year="2021"; proof="WC"; obtained="2021/10/23";
      };
      "charizard-2021-leonardo" = {
        species="charizard"; ball="cherish"; dex=6; name="Charizard"; year="2021"; ot="Leonardo"; id="211031"; region="ITA"; obtained="2021/11/07";
        moves=[ "Heat Wave" "Blast Burn" "Hurricane" "Protect" ]; tradeHistory="Kira > pungkula";
      };

      # »  2022  «
      "articuno-galar-2022-crown" = {
        species="articuno-galar"; ball="cherish"; dex=144; name="Articuno (Galar)"; shiny=true; selfObtained=true; year="2022"; ot="Crown"; id="220218"; region="ENG"; proof="WC";
        #mark="🔴";
        obtained="2022/02/22"; moves=[ "Freezing Glare" "Hurricane" "Psycho Cut" "Psycho Shift" ];
      };
      "zapdos-galar-2022-wild" = {
        species="zapdos-galar"; ball="cherish"; dex=145; name="Zapdos (Galar)"; shiny=true; selfObtained=true; year="2022"; ot="Wild"; id="220311"; region="ENG"; proof="WC";
        #mark="🔴";
        obtained="2022/03/14"; moves=[ "Thunderous Kick" "Drill Peck" "Reversal" "Focus Energy" ];
      };
      "moltres-galar-2022-armor" = {
        species="moltres-galar"; ball="cherish"; dex=146; name="Moltres (Galar)"; shiny=true; selfObtained=true; year="2022"; ot="Armor"; id="220415"; region="ENG"; proof="WC";
        #mark="🔴";
        obtained="2022/04/20"; moves=[ "Fiery Wrath" "Hurricane" "Sucker Punch" "Nasty Plot" ];
      };
      "dracovish-2022" = {
        species="dracovish"; ball="pokeball"; dex=882; name="Dracovish"; selfObtained=true; year="2022"; id="210108"; region="JPN"; proof="WC"; obtained="2022/08/13";
        moves=[ "Fishious Rend" "Dragon Rush" "Ice Fang" "Water Gun" ];
      };
      "victini-2022-victory-1" = {
        species="victini"; ball="cherish"; dex=494; name="Victini"; selfObtained=true; year="2022"; ot="Victory"; id="220818"; region="ENG"; proof="WC"; obtained="2022/08/18";
        #mark="🔴";
        moves=[ "V-create" "Zen Headbutt" "Work Up" "Flame Charge" ];
      };
      "victini-2022-victory-2" = {
        species="victini"; ball="cherish"; dex=494; name="Victini"; selfObtained=true; year="2022"; ot="Victory"; id="220818"; region="ENG"; proof="WC"; obtained="2022/08/21";
        #mark="❤";
        moves=[ "V-create" "Zen Headbutt" "Work Up" "Flame Charge" ]; tradeHistory="troll7 account";
      };
      "victini-2022-victory-3" = {
        species="victini"; ball="cherish"; dex=494; name="Victini"; selfObtained=true; year="2022"; ot="Victory"; id="220818"; region="ENG"; proof="WC"; obtained="2022/08/21";
        #mark="∆";
        moves=[ "V-create" "Zen Headbutt" "Work Up" "Flame Charge" ]; tradeHistory="2nd switch 996385";
      };
      "sinistea-2022-wc22-eng" = {
        species="sinistea"; ball="cherish"; dex=854; name="Sinistea"; year="2022"; ot="WC22"; id="220818"; region="ENG"; obtained="2022/08/22"; moves=[ "Memento" "Metronome" "Aromatherapy" "Celebrate" ];
      };
      "sinistea-2022-wc22-cht" = {
        species="sinistea"; ball="cherish"; dex=854; name="Sinistea"; selfObtained=true; year="2022"; ot="W C S 2 2"; id="220818"; region="CHT"; obtained="2022/08/22";
        moves=[ "Memento" "Metronome" "Aromatherapy" "Celebrate" ];
      };
      "jirachi-2022-jpn" = {
        species="jirachi"; ball="cherish"; dex=385; name="Jirachi"; year="2022"; id="030719"; region="JPN"; obtained="2022/08/22";
        #mark="∆";
        moves=[ "Meteor Mash" "Psychic" "Rest" "Wish" ];
      };
      "dragonite-2022-jpn-1" = {
        species="dragonite"; ball="pokeball"; dex=149; name="Dragonite"; selfObtained=true; year="2022"; id="200126"; region="JPN"; proof="WC"; obtained="2022/08/26";
        #mark="🔴";
        moves=[ "Dragon Claw" "Draco Meteor" "Hurricane" "Dragon Dance" ];
      };
      "dragonite-2022-jpn-2" = {
        species="dragonite"; ball="pokeball"; dex=149; name="Dragonite"; selfObtained=true; year="2022"; id="200126"; region="JPN"; proof="WC"; obtained="2022/08/26";
        #mark="∆";
        moves=[ "Dragon Claw" "Draco Meteor" "Hurricane" "Dragon Dance" ]; tradeHistory="517650 acc";
      };
      "gengar-gmax-2022-jpn-1" = {
        species="gengar-gmax"; ball="pokeball"; dex=94; name="Gengar (GMax)"; selfObtained=true; year="2022"; id="200308"; region="JPN"; proof="WC"; obtained="2022/09/02";
        #mark="∆";
        moves=[ "Shadow Ball" "Sludge Bomb" "Dazzling Gleam" "Will-O-Wisp" ]; tradeHistory="996365 acc";
      };
      "gengar-gmax-2022-jpn-2" = {
        species="gengar-gmax"; ball="pokeball"; dex=94; name="Gengar (GMax)"; selfObtained=true; year="2022"; id="200308"; region="JPN"; proof="WC"; obtained="2022/09/02";
        #mark="🔴";
        moves=[ "Shadow Ball" "Sludge Bomb" "Dazzling Gleam" "Will-O-Wisp" ]; tradeHistory="082409 acc";
      };
      "sirfetchd-2022-jpn-1" = {
        species="sirfetchd"; ball="pokeball"; dex=865; name="Sirfetch'd"; selfObtained=true; year="2022"; id="200705"; region="JPN"; proof="WC"; obtained="2022/09/09";
        #mark="🔴";
        moves=[ "Meteor Assault" "Brutal Swing" "Fury Cutter" "Detect" ]; tradeHistory="082409 acc";
      };
      "sirfetchd-2022-jpn-2" = {
        species="sirfetchd"; ball="pokeball"; dex=865; name="Sirfetch'd"; selfObtained=true; year="2022"; id="200705"; region="JPN"; proof="WC"; obtained="2022/09/09";
        #mark="∆";
        moves=[ "Meteor Assault" "Brutal Swing" "Fury Cutter" "Detect" ]; tradeHistory="996385 acc";
      };
      "marshadow-2022-mythical22" = {
        species="marshadow"; ball="cherish"; dex=802; name="Marshadow"; selfObtained=true; year="2022"; ot="Mythical22"; id="220909"; region="ENG"; proof="WC + Code Card";
        #mark="🔴❤️️";
        obtained="2022/09/14"; moves=[ "Spectral Thief" "Drain Punch" "Force Palm" "Shadow Sneak" ]; tradeHistory="082409 acc";
      };
      "genesect-2022-mythical22" = {
        species="genesect"; ball="cherish"; dex=649; name="Genesect"; selfObtained=true; year="2022"; ot="Mythical22"; id="220909"; region="ENG"; proof="WC + Code Card";
        #mark="🔴❤️️";
        obtained="2022/09/14"; moves=[ "Techno Blast" "X-Scissor" "Metal Claw" "Fell Stinger" ]; tradeHistory="082409 acc";
      };
      "volcanion-2022-mythical22" = {
        species="volcanion"; ball="cherish"; dex=721; name="Volcanion"; selfObtained=true; year="2022"; ot="Mythical22"; id="220909"; region="ENG"; proof="WC + Code Card";
        #mark="🔴❤️️";
        obtained="2022/09/14"; moves=[ "Steam Eruption" "Flare Blitz" "Incinerate" "Haze" ]; tradeHistory="082409 acc";
      };
      "lucario-2022-jpn-1" = {
        species="lucario"; ball="pokeball"; dex=448; name="Lucario"; selfObtained=true; year="2022"; id="200412"; region="JPN"; proof="WC"; obtained="2022/09/17";
        #mark="∆";
        moves=[ "Aura Sphere" "Bullet Punch" "Reversal" "Steel Beam" ]; tradeHistory="996385 acc";
      };
      "eternatus-2022-galar" = {
        species="eternatus"; ball="cherish"; dex=890; name="Eternatus"; shiny=true; selfObtained=true; year="2022"; ot="Galar"; id="221118"; region="ENG";
        #mark="🔴";
        proof="WC + Code Card"; obtained="2022/09/20"; moves=[ "Eternabeam" "Dynamax Cannon" "Sludge Bomb" "Flamethrower" ]; tradeHistory="082409 acc";
      };
      "lucario-2022-jpn-2" = {
        species="lucario"; ball="pokeball"; dex=448; name="Lucario"; selfObtained=true; year="2022"; id="200412"; region="JPN"; proof="WC"; obtained="2022/09/20";
        #mark="🔴";
        moves=[ "Aura Sphere" "Bullet Punch" "Reversal" "Steel Beam" ]; tradeHistory="082409 acc";
      };
      "poipole-ultra" = {
        species="poipole"; ball="cherish"; dex=803; name="Poipole"; shiny=true; year=""; ot="Ultra"; id="091718"; region="ENG"; proof="HC"; obtained="2022/10/22";
        #mark="blue star";
        moves=[ "Venom Drench" "Nasty Plot" "Poison Jab" "Dragon Pulse" ]; tradeHistory="Striker#0962 > pungkula";
      };
      "jirachi-nintendo-hk-2" = {
        species="jirachi"; ball="cherish"; dex=385; name="Jirachi"; shiny=true; ot="Nintendo HK"; id="12015"; region="ENG"; obtained="2022/10/22";
        #mark="blue star";
        moves=[ "Wish" "Confusion" "Swift" "Happy Hour" ]; tradeHistory="Striker#0962 > pungkula";
      };
      "raikou-win2011" = {
        species="raikou"; ball="cherish"; dex=243; name="Raikou"; shiny=true; ot="WIN2011"; id="02071"; region="ENG"; obtained="2022/10/22";
        #mark="blue star";
        moves=[ "Thunderbolt" "Aura Sphere" "Extreme Speed" "Weather Ball" ]; tradeHistory="Striker#0962 > pungkula";
      };
      "lechonk-2022" = {
        species="lechonk"; ball="cherish"; dex=915; name="Lechonk";
      };

      # »  2023  «
      "bronzong-2023" = {
        species="bronzong"; ball="cherish"; dex=437; name="Bronzong"; selfObtained=true; year="2023"; id="230610"; region="JPN"; notes="Yasuharu Shimizu's Bronzong"; proof="WC";
        #mark="🔴❤️️";
        obtained="2023/06/10"; moves=[ "Body Press" "Iron Defense" "Protect" "Trick Room" ];
      };
      "gastrodon-2023-kor-1" = {
        species="gastrodon"; ball="cherish"; dex=423; name="Gastrodon"; selfObtained=true; year="2023"; id="230603"; region="KOR"; proof="WC"; obtained="2023/06/17";
        #mark="🔴";
        moves=[ "Earth Power" "Ice Beam" "Yawn" "Protect" ];
      };
      "gastrodon-2023-kor-2" = {
        species="gastrodon"; ball="cherish"; dex=423; name="Gastrodon"; selfObtained=true; year="2023"; id="230603"; region="KOR"; proof="WC"; obtained="2023/06/17";
        #mark="🔴❤️️";
        moves=[ "Earth Power" "Ice Beam" "Yawn" "Protect" ];
      };
      "charizard-2023-dark-tera-1" = {
        species="charizard"; ball="cherish"; dex=6; name="Charizard"; selfObtained=true; year="2023"; notes="Dark Tera Type"; proof="WC"; obtained="2023/07/23";
        moves=[ "Crunch" "Flare Blitz" "Acrobatics" "Belly Drum" ];
      };
      "charizard-2023-dark-tera-2" = {
        species="charizard"; ball="cherish"; dex=6; name="Charizard"; selfObtained=true; year="2023"; ot="★ pungkula"; id="385844"; region="ENG"; notes="Dark Tera Type"; proof="WC";
        #mark="🔴";
        obtained="2023/07/23"; moves=[ "Crunch" "Flare Blitz" "Acrobatics" "Belly Drum" ];
      };
      "grimmsnarl-2023-shiny" = {
        species="grimmsnarl"; ball="cherish"; dex=861; name="Grimmsnarl"; shiny=true; selfObtained=true; year="2023"; proof="WC"; obtained="2023/08/08";
      };
      "mew-2023-gety0urmew-1" = {
        species="mew"; ball="pokeball"; dex=151; name="Mew"; selfObtained=true; year="2023"; region="ENG"; notes="GETY0URMEW"; proof="WC"; obtained="2023/08/08";
      };
      "mew-2023-gety0urmew-2" = {
        species="mew"; ball="pokeball"; dex=151; name="Mew"; selfObtained=true; year="2023"; ot="★ pungkula"; id="385844"; region="ENG"; notes="Fire Tera Type"; proof="WC";
        #mark="∆";
        obtained="2023/08/12"; moves=[ "Flamethrower" "Swift" "Light Screen" "Life Dew" ];
      };
      "gastrodon-2023-eduardo" = {
        species="gastrodon"; ball="cherish"; dex=423; name="Gastrodon"; selfObtained=true; year="2023"; ot="Eduardo"; id="230811"; region="ENG"; notes="23WCSGASTR0D0N"; proof="WC";
        #mark="∆";
        obtained="2023/08/12"; moves=[ "Earth Power" "Icy Wind" "Yawn" "Protect" ];
      };
      "lucario-2023-shiny" = {
        species="lucario"; ball="pokeball"; dex=448; name="Lucario"; shiny=true; selfObtained=true; year="2023"; notes="sh1nybuddy"; obtained="2023/12/15";
        #mark="🔴";
      };
      "darkrai-2023-newm00nisc0ming" = {
        species="darkrai"; ball="cherish"; dex=491; name="Darkrai"; selfObtained=true; year="2023"; notes="newm00nisc0ming"; obtained="2023/12/15";
        #mark="🔴";
      };
      "gimmighoul-2023-seey0u1npaldea" = {
        species="gimmighoul"; ball="cherish"; dex=999; name="Gimmighoul"; selfObtained=true; year="2023"; notes="SEEY0U1NPALDEA"; obtained="2023/12/15";
        #mark="🔴";
      };
      "revavroom-2023" = {
        species="revavroom"; ball="cherish"; dex=966; name="Revavroom"; selfObtained=true; year="2023"; obtained="2023/12/22";
        #mark="🔴";
      };
      "cetitan-2023" = {
        species="cetitan"; ball="cherish"; dex=975; name="Cetitan"; selfObtained=true; year="2023";
      };
    };



    # 🦆 ⮞ TRUE SHINY LIVING DEX ♀️/♂️
    shiny = {
      # » GENERATION 1 - KANTO REGION
      bulbasaur = { ball = "friend"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      ivysaur   = { ball = "friend"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      venusaur-f = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
        moves = [ "Giga Drain" "Sludge Bomb" "Earth Power" "Growth" ];
      };
      venusaur-m = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
        moves = [ "Sleep Powder" "Growth" "Giga Drain" "Sludge Bomb" ];
      };
      venusaur-gmax = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Giga Drain" "Sludge Bomb" "Earth Power" "Growth" ];
      };

      charmander = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Blaze"; teraType = "Fire"; };
      charmeleon = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Blaze"; teraType = "Fire"; };
      charizard = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Blaze"; teraType = "Fire";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        ivs = { hp = 31; atk = 31; def = 31; spa = 0; spd = 31; spe = 31; };
        moves = [ "Dragon Dance" "Flare Blitz" "Earthquake" "Roost" ];
      };
      charizard-gmax = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Blaze"; teraType = "Fire";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Dragon Dance" "Flare Blitz" "Earthquake" "Roost" ];
      };

      squirtle = { ball = "net"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Torrent"; teraType = "Water"; };
      wartortle = { ball = "moon"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Torrent"; teraType = "Water"; };
      blastoise = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Rain Dish"; teraType = "Water";
        heldItem = "Leftovers";
        evs = { hp = 252; spa = 4; spd = 252; };
        moves = [ "Rapid Spin" "Scald" "Ice Beam" "Roost" ];
      };
      blastoise-gmax = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Rain Dish"; teraType = "Water";
        heldItem = "Leftovers";
        evs = { hp = 252; spa = 4; spd = 252; };
        moves = [ "Rapid Spin" "Scald" "Ice Beam" "Roost" ];
      };

      caterpie = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Shield Dust"; teraType = "Bug"; };
      metapod  = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Shed Skin"; teraType = "Bug"; };
      butterfree-f = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Compound Eyes"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
        moves = [ "Sleep Powder" "Quiver Dance" "Bug Buzz" "Hurricane" ];
      };
      butterfree-m = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Compound Eyes"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Sleep Powder" "Quiver Dance" "Bug Buzz" "Hurricane" ];
        style = "square"; egg = true; notes = "egg hatch";
      };
      butterfree-gmax = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Compound Eyes"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Sleep Powder" "Quiver Dance" "Bug Buzz" "Hurricane" ];
        style = "square"; egg = true; notes = "Egg hatch";
      };

      weedle   = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Shield Dust"; teraType = "Bug"; };
      kakuna   = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Shed Skin"; teraType = "Bug"; };
      beedrill = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Swarm"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        ivs = { hp = 31; atk = 31; def = 31; spa = 0; spd = 31; spe = 31; };
        moves = [ "Swords Dance" "U-turn" "Poison Jab" "Drill Run" ];
      };

      pidgey    = { ball = "fast"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Keen Eye"; teraType = "Normal"; };
      pidgeotto = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Keen Eye"; teraType = "Normal"; };
      pidgeot   = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Tangled Feet"; teraType = "Normal";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Brave Bird" "U-turn" "Return" "Roost" ];
      };

      rattata-f      = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Guts"; teraType = "Normal"; };
      rattata-m      = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Guts"; teraType = "Normal"; };
      rattata-alola  = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Hustle"; teraType = "Dark"; };
      raticate-f     = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Guts"; teraType = "Normal"; };
      raticate-m     = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Guts"; teraType = "Normal"; };
      raticate-alola = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Hustle"; teraType = "Dark"; };

      spearow = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Keen Eye"; teraType = "Normal"; };
      fearow  = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Sniper"; teraType = "Normal";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Drill Run" "Drill Peck" "U-turn" "Roost" ];
      };

      ekans = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Intimidate"; teraType = "Poison"; };
      arbok = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Intimidate"; teraType = "Poison";
        heldItem = "Black Sludge";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Coil" "Gunk Shot" "Earthquake" "Sucker Punch" ];
      };

      pikachu-f = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Static"; teraType = "Electric";
        heldItem = "Light Ball";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Fake Out" "Volt Tackle" "Surf" "Knock Off" ];
      };
      pikachu-m = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Static"; teraType = "Electric";
        heldItem = "Light Ball";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Fake Out" "Volt Tackle" "Surf" "Knock Off" ];
      };
      pikachu-gmax = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Static"; teraType = "Electric";
        heldItem = "Light Ball";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Fake Out" "Volt Tackle" "Surf" "Knock Off" ];
      };
      raichu-f = {
        ball = "moon"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Static"; teraType = "Electric";
        heldItem = "Choice Specs";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Thunderbolt" "Volt Switch" "Surf" "Focus Blast" ];
      };
      raichu-m = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Static"; teraType = "Electric";
        heldItem = "Choice Specs";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Thunderbolt" "Volt Switch" "Surf" "Focus Blast" ];
      };
      raichu-alola = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Surge Surfer"; teraType = "Electric";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Thunderbolt" "Psychic" "Grass Knot" "Volt Switch" ];
      };

      sandshrew       = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Sand Veil"; teraType = "Ground"; };
      sandshrew-alola = { ball = "beast"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Slush Rush"; teraType = "Ice"; };
      sandslash = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Sand Rush"; teraType = "Ground";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Earthquake" "Iron Head" "Rapid Spin" ];
      };
      sandslash-alola = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Slush Rush"; teraType = "Ice";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Icicle Crash" "Triple Axel" "Iron Head" "Rapid Spin" ];
      };

      nidoran-f  = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Poison Point"; teraType = "Poison"; };
      nidorina   = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Poison Point"; teraType = "Poison"; };
      nidoqueen  = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Sheer Force"; teraType = "Ground";
        heldItem = "Life Orb";
        evs = { hp = 252; spa = 252; spd = 4; };
        moves = [ "Stealth Rock" "Earth Power" "Sludge Wave" "Ice Beam" ];
      };
      nidoran-m  = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Poison Point"; teraType = "Poison"; };
      nidorino   = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Poison Point"; teraType = "Poison"; };
      nidoking   = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Sheer Force"; teraType = "Ground";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Earth Power" "Sludge Wave" "Ice Beam" "Flamethrower" ];
      };

      clefairy = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Magic Guard"; teraType = "Fairy"; };
      clefable = {
        ball = "heavy"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Magic Guard"; teraType = "Fairy";
        heldItem = "Leftovers";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Moonblast" "Soft-Boiled" "Stealth Rock" "Knock Off" ];
      };

      vulpix        = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Flash Fire"; teraType = "Fire"; };
      vulpix-alola  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Snow Warning"; teraType = "Ice"; };
      ninetales = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Drought"; teraType = "Fire";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Fire Blast" "Solar Beam" "Psyshock" ];
      };
      ninetales-alola = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Snow Warning"; teraType = "Fairy";
        heldItem = "Light Clay";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Aurora Veil" "Freeze-Dry" "Moonblast" "Hypnosis" ];
      };

      jigglypuff = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Cute Charm"; teraType = "Normal"; };
      wigglytuff = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Competitive"; teraType = "Normal";
        heldItem = "Leftovers";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Wish" "Protect" "Dazzling Gleam" "Body Slam" ];
      };

      zubat-f  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Inner Focus"; teraType = "Poison"; };
      zubat-m  = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Inner Focus"; teraType = "Poison"; };
      golbat-f = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Inner Focus"; teraType = "Poison"; };
      golbat-m = { ball = "fast"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Inner Focus"; teraType = "Poison"; };

      oddish      = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      gloom-f     = { ball = "friend"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      gloom-m     = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      vileplume-f = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Sleep Powder" "Growth" "Giga Drain" "Sludge Bomb" ];
      };
      vileplume-m = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Sleep Powder" "Growth" "Giga Drain" "Sludge Bomb" ];
      };

      paras    = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Effect Spore"; teraType = "Bug"; };
      parasect = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Dry Skin"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Spore" "Swords Dance" "Leech Life" "Seed Bomb" ];
      };

      venonat  = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Compound Eyes"; teraType = "Bug"; };
      venomoth = {
        ball = "quick"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Tinted Lens"; teraType = "Bug";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Quiver Dance" "Sleep Powder" "Bug Buzz" "Sludge Bomb" ];
      };

      diglett       = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Sand Veil"; teraType = "Ground"; };
      diglett-alola = { ball = "beast"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Tangling Hair"; teraType = "Steel"; };
      dugtrio = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Sand Force"; teraType = "Ground";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Earthquake" "Sucker Punch" "Stone Edge" "Memento" ];
      };
      dugtrio-alola = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Tangling Hair"; teraType = "Steel";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Earthquake" "Iron Head" "Sucker Punch" "Memento" ];
      };

      meowth        = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Pickup"; teraType = "Normal"; };
      meowth-alola  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Pickup"; teraType = "Dark"; };
      meowth-galar  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Pickup"; teraType = "Steel"; };
      meowth-gmax   = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Pickup"; teraType = "Normal"; };
      persian       = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Technician"; teraType = "Normal"; };
      persian-alola = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Fur Coat"; teraType = "Dark"; };

      psyduck = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Cloud Nine"; teraType = "Water"; };
      golduck = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Swift Swim"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Hydro Pump" "Ice Beam" "Psyshock" ];
      };

      mankey   = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Vital Spirit"; teraType = "Fighting"; };
      primeape = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Defiant"; teraType = "Fighting";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Close Combat" "U-turn" "Stone Edge" "Ice Punch" ];
      };

      growlithe = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Intimidate"; teraType = "Fire"; };
      arcanine = {
        ball = "repeat"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Intimidate"; teraType = "Fire";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Flare Blitz" "Extreme Speed" "Wild Charge" "Morning Sun" ];
      };

      poliwag   = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Swift Swim"; teraType = "Water"; };
      poliwhirl = { ball = "heavy"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Swift Swim"; teraType = "Water"; };
      poliwrath = {
        ball = "love"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Water Absorb"; teraType = "Water";
        heldItem = "Leftovers";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Bulk Up" "Drain Punch" "Waterfall" "Ice Punch" ];
      };

      abra       = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Magic Guard"; teraType = "Psychic"; };
      kadabra-f  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Magic Guard"; teraType = "Psychic"; };
      kadabra-m  = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Magic Guard"; teraType = "Psychic"; };
      alakazam-f = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Magic Guard"; teraType = "Psychic";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Psychic" "Focus Blast" "Shadow Ball" ];
      };
      alakazam-m = {
        ball = "heavy"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Magic Guard"; teraType = "Psychic";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Psychic" "Focus Blast" "Shadow Ball" ];
      };

      machop  = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Guts"; teraType = "Fighting"; };
      machoke = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Guts"; teraType = "Fighting"; };
      machamp = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "No Guard"; teraType = "Fighting";
        heldItem = "Assault Vest";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Dynamic Punch" "Knock Off" "Stone Edge" "Bullet Punch" ];
      };
      machamp-gmax = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "No Guard"; teraType = "Fighting";
        heldItem = "Assault Vest";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Dynamic Punch" "Knock Off" "Stone Edge" "Bullet Punch" ];
      };

      bellsprout = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      weepinbell = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      victreebel = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Leaf Blade" "Poison Jab" "Sucker Punch" ];
      };

      tentacool = { ball = "lure"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Liquid Ooze"; teraType = "Water"; };
      tentacruel = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Liquid Ooze"; teraType = "Water";
        heldItem = "Black Sludge";
        evs = { hp = 252; spa = 4; spe = 252; };
        moves = [ "Rapid Spin" "Scald" "Sludge Bomb" "Knock Off" ];
      };

      geodude        = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Rock"; };
      geodude-alola  = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Magnet Pull"; teraType = "Rock"; };
      graveler       = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Rock"; };
      graveler-alola = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Magnet Pull"; teraType = "Rock"; };
      golem = {
        ball = "great"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Rock Head"; teraType = "Ground";
        heldItem = "Leftovers";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Stealth Rock" "Earthquake" "Stone Edge" "Explosion" ];
      };
      golem-alola = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Galvanize"; teraType = "Electric";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Stealth Rock" "Wild Charge" "Stone Edge" "Explosion" ];
      };

      ponyta       = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Flash Fire"; teraType = "Fire"; };
      ponyta-galar = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Pastel Veil"; teraType = "Psychic"; };
      rapidash = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Flash Fire"; teraType = "Fire";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Flare Blitz" "High Horsepower" "Wild Charge" ];
      };
      rapidash-galar = {
        ball = "repeat"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Pastel Veil"; teraType = "Fairy";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Play Rough" "High Horsepower" "Zen Headbutt" ];
      };

      slowpoke       = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Regenerator"; teraType = "Water"; };
      slowpoke-galar = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Quick Draw"; teraType = "Psychic"; };
      slowbro = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Regenerator"; teraType = "Water";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 252; def = 252; spa = 4; };
        moves = [ "Scald" "Slack Off" "Future Sight" "Ice Beam" ];
      };
      slowbro-galar = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Regenerator"; teraType = "Poison";
        heldItem = "Assault Vest";
        evs = { hp = 252; spa = 252; spd = 4; };
        moves = [ "Sludge Bomb" "Psyshock" "Fire Blast" "Ice Beam" ];
      };

      magnemite = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Magnet Pull"; teraType = "Electric"; };
      magneton  = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Magnet Pull"; teraType = "Electric"; };

      farfetchd       = { ball = "love"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Defiant"; teraType = "Normal"; };
      farfetchd-galar = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Scrappy"; teraType = "Fighting"; };

      doduo-f  = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Early Bird"; teraType = "Normal"; };
      doduo-m  = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Early Bird"; teraType = "Normal"; };
      dodrio-f = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Early Bird"; teraType = "Normal";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Brave Bird" "Drill Peck" "Quick Attack" "Knock Off" ];
      };
      dodrio-m = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Early Bird"; teraType = "Normal";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Brave Bird" "Drill Peck" "Quick Attack" "Knock Off" ];
      };

      seel    = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Calm"; ability = "Thick Fat"; teraType = "Water"; };
      dewgong = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Calm"; ability = "Thick Fat"; teraType = "Water";
        heldItem = "Leftovers";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Toxic" "Protect" "Surf" "Ice Beam" ];
      };

      grimer       = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Poison Touch"; teraType = "Poison"; };
      grimer-alola = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Poison Touch"; teraType = "Poison"; };
      muk = {
        ball = "great"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Poison Touch"; teraType = "Poison";
        heldItem = "Assault Vest";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Poison Jab" "Shadow Sneak" "Drain Punch" "Fire Punch" ];
      };
      muk-alola = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Poison Touch"; teraType = "Poison";
        heldItem = "Assault Vest";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Poison Jab" "Knock Off" "Drain Punch" "Shadow Sneak" ];
      };


      shellder = { ball = "lure"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Skill Link"; teraType = "Water"; };
      cloyster = {
        ball = "dive"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Skill Link"; teraType = "Ice";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Shell Smash" "Icicle Spear" "Rock Blast" "Ice Shard" ];
      };

      gastly  = { ball = "moon"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Levitate"; teraType = "Ghost"; };
      haunter = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Levitate"; teraType = "Ghost"; };
      gengar = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Cursed Body"; teraType = "Ghost";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
        moves = [ "Nasty Plot" "Shadow Ball" "Sludge Wave" "Focus Blast" ];
      };
      gengar-gmax = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Cursed Body"; teraType = "Ghost";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Shadow Ball" "Sludge Wave" "Focus Blast" ];
      };


      onix    = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Sturdy"; teraType = "Rock"; };
      drowzee = { ball = "heal"; ot = true; selfObtained = true; level = 100; nature = "Calm"; ability = "Insomnia"; teraType = "Psychic"; };
      hypno-f = { ball = "quick"; ot = true; selfObtained = true; level = 100; nature = "Calm"; ability = "Insomnia"; teraType = "Psychic"; };
      hypno-m = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Calm"; ability = "Insomnia"; teraType = "Psychic"; };

      krabby = { ball = "net"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Sheer Force"; teraType = "Water"; };
      kingler = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Sheer Force"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Liquidation" "X-Scissor" "Rock Slide" ];
      };
      kingler-gmax = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Sheer Force"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Liquidation" "X-Scissor" "Rock Slide" ];
      };

      voltorb   = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Static"; teraType = "Electric"; };
      electrode = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Aftermath"; teraType = "Electric";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Volt Switch" "Thunderbolt" "Taunt" "Explosion" ];
      };
      exeggcute = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass"; };
      exeggutor = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Chlorophyll"; teraType = "Grass";
        heldItem = "Focus Sash";
        evs = { hp = 252; spa = 252; spd = 4; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 0; };
        moves = [ "Trick Room" "Psychic" "Giga Drain" "Sludge Bomb" ];
      };
      exeggutor-alola = {
        ball = "ultra"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Frisk"; teraType = "Dragon";
        heldItem = "Choice Specs";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Draco Meteor" "Leaf Storm" "Flamethrower" "Giga Drain" ];
      };
      cubone  = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Ground"; };
      marowak = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Rock Head"; teraType = "Ground";
        heldItem = "Thick Club";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Bonemerang" "Fire Punch" "Knock Off" ];
      };
      marowak-alola = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Rock Head"; teraType = "Ghost";
        heldItem = "Thick Club";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Shadow Bone" "Flare Blitz" "Bonemerang" ];
      };

      hitmonlee = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Reckless"; teraType = "Fighting";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Close Combat" "High Jump Kick" "Knock Off" "Rapid Spin" ];
      };
      hitmonchan = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Iron Fist"; teraType = "Fighting";
        heldItem = "Assault Vest";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Drain Punch" "Mach Punch" "Ice Punch" "Rapid Spin" ];
      };
      lickitung = { ball = "beast"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Oblivious"; teraType = "Normal"; };

      koffing = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Bold"; ability = "Levitate"; teraType = "Poison"; };
      weezing = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Levitate"; teraType = "Poison";
        heldItem = "Black Sludge";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Will-O-Wisp" "Sludge Bomb" "Flamethrower" "Pain Split" ];
      };
      weezing-galar = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Misty Surge"; teraType = "Fairy";
        heldItem = "Black Sludge";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Strange Steam" "Flamethrower" "Defog" "Pain Split" ];
      };

      rhyhorn-f = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Ground"; };
      rhyhorn-m = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Ground"; };
      rhydon-f  = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Ground"; };
      rhydon-m  = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Rock Head"; teraType = "Ground"; };

      chansey = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Natural Cure"; teraType = "Normal";
        heldItem = "Eviolite";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Soft-Boiled" "Seismic Toss" "Toxic" "Heal Bell" ];
      };
      tangela = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Regenerator"; teraType = "Grass";
        heldItem = "Eviolite";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Sleep Powder" "Leech Seed" "Giga Drain" "Knock Off" ];
      };
      kangaskhan = { ball = "dusk"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Scrappy"; teraType = "Normal"; };
      horsea = { ball = "lure"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Swift Swim"; teraType = "Water"; };
      seadra = { ball = "lure"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Poison Point"; teraType = "Water"; };

      goldeen-f = { ball = "friend"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Swift Swim"; teraType = "Water"; };
      goldeen-m = { ball = "lure"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Swift Swim"; teraType = "Water"; };
      seaking-f = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Swift Swim"; teraType = "Water";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Waterfall" "Megahorn" "Knock Off" "Drill Run" ];
      };
      seaking-m = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Swift Swim"; teraType = "Water";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Waterfall" "Megahorn" "Knock Off" "Drill Run" ];
      };
      staryu  = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Natural Cure"; teraType = "Water"; };
      starmie = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Natural Cure"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Rapid Spin" "Hydro Pump" "Ice Beam" "Thunderbolt" ];
      };
      mr-mime       = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Filter"; teraType = "Psychic"; };
      mr-mime-galar = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Screen Cleaner"; teraType = "Ice"; };
      scyther-f     = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Technician"; teraType = "Bug"; };
      scyther-m     = { ball = "premier"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Technician"; teraType = "Bug"; };
      jynx = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Dry Skin"; teraType = "Ice";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Ice Beam" "Psyshock" "Focus Blast" ];
      };
      electabuzz = { ball = "master"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Static"; teraType = "Electric"; };
      magmar     = { ball = "sport"; ot = true; selfObtained = true; level = 100; nature = "Timid"; ability = "Flame Body"; teraType = "Fire"; };
      pinsir = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Moxie"; teraType = "Bug";
        heldItem = "Choice Scarf";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Close Combat" "X-Scissor" "Stone Edge" "Earthquake" ];
      };
      tauros = {
        ball = "level"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Intimidate"; teraType = "Normal";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Close Combat" "Rock Slide" "Earthquake" "Zen Headbutt" ];
      };
      tauros-paldea = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Intimidate"; teraType = "Fighting";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Close Combat" "Raging Bull" "Earthquake" "Rock Slide" ];
      };
      tauros-blaze = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Cud Chew"; teraType = "Fire";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Flare Blitz" "Raging Bull" "Close Combat" "Wild Charge" ];
      };
      tauros-aqua = {
        ball = "heavy"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Intimidate"; teraType = "Water";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Aqua Jet" "Wave Crash" "Raging Bull" "Close Combat" ];
      };

      magikarp-f = { ball = "friend"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Swift Swim"; teraType = "Water"; };
      magikarp-m = { ball = "great"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Swift Swim"; teraType = "Water"; };
      gyarados-f = {
        ball = "dive"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Moxie"; teraType = "Flying";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Dragon Dance" "Waterfall" "Bounce" "Earthquake" ];
      };
      gyarados-m = {
        ball = "dive"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Moxie"; teraType = "Flying";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Dragon Dance" "Waterfall" "Bounce" "Earthquake" ];
      };

      lapras = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Water Absorb"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Dragon Dance" "Hydro Pump" "Freeze-Dry" "Thunderbolt" ];
      };
      lapras-gmax = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Water Absorb"; teraType = "Water";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Dragon Dance" "Hydro Pump" "Freeze-Dry" "Thunderbolt" ];
      };
      ditto = {
        ball = "master"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Imposter"; teraType = "Normal";
        heldItem = "Choice Scarf";
        evs = { hp = 252; spd = 4; spe = 252; };
        moves = [ "Transform" ];
      };

      eevee-f    = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Adaptability"; teraType = "Normal"; };
      eevee-m    = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Adaptability"; teraType = "Normal"; };
      eevee-gmax = { ball = "luxury"; ot = true; selfObtained = true; level = 100; nature = "Jolly"; ability = "Adaptability"; teraType = "Normal"; };
      vaporeon = {
        ball = "love"; ot = true; selfObtained = true; level = 100;
        nature = "Bold"; ability = "Water Absorb"; teraType = "Water";
        heldItem = "Leftovers";
        evs = { hp = 252; def = 252; spd = 4; };
        moves = [ "Wish" "Protect" "Scald" "Heal Bell" ];
      };
      jolteon = {
        ball = "fast"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Volt Absorb"; teraType = "Electric";
        heldItem = "Choice Specs";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Thunderbolt" "Volt Switch" "Shadow Ball" "Hyper Voice" ];
      };
      flareon = {
        ball = "sport"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Flash Fire"; teraType = "Fire";
        heldItem = "Choice Band";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Flare Blitz" "Superpower" "Quick Attack" "Facade" ];
      };

      porygon = { ball = "poke"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Trace"; teraType = "Normal"; };
      omanyte = { ball = "ultra"; ot = true; selfObtained = true; level = 100; nature = "Modest"; ability = "Swift Swim"; teraType = "Water"; };
      omastar = {
        ball = "dream"; ot = true; selfObtained = true; level = 100;
        nature = "Modest"; ability = "Swift Swim"; teraType = "Water";
        heldItem = "Focus Sash";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Shell Smash" "Hydro Pump" "Ice Beam" "Earth Power" ];
      };
      kabuto = { ball = "safari"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Swift Swim"; teraType = "Rock"; };
      kabutops = {
        ball = "friend"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Swift Swim"; teraType = "Rock";
        heldItem = "Life Orb";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Swords Dance" "Stone Edge" "Liquidation" "Aqua Jet" ];
      };
      aerodactyl = {
        ball = "safari"; ot = true; selfObtained = true; level = 100;
        nature = "Jolly"; ability = "Rock Head"; teraType = "Rock";
        heldItem = "Focus Sash";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Stealth Rock" "Stone Edge" "Earthquake" "Roost" ];
      };

      snorlax = {
        ball = "dusk"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Thick Fat"; teraType = "Normal";
        heldItem = "Leftovers";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Curse" "Body Slam" "Crunch" "Rest" ];
      };
      snorlax-gmax = {
        ball = "dusk"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Thick Fat"; teraType = "Normal";
        heldItem = "Leftovers";
        evs = { hp = 252; atk = 252; spd = 4; };
        moves = [ "Curse" "Body Slam" "Crunch" "Rest" ];
      };

      articuno = {
        ball = "moon"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Pressure"; teraType = "Ice";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 252; spd = 4; spe = 252; };
        moves = [ "Roost" "Freeze-Dry" "Hurricane" "Defog" ];
      };
      articuno-galar = {
        ball = "cherish"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Competitive"; teraType = "Psychic";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Calm Mind" "Freezing Glare" "Hurricane" "Recover" ];
      };
      zapdos = {
        ball = "luxury"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Static"; teraType = "Electric";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 252; spa = 4; spe = 252; };
        moves = [ "Roost" "Hurricane" "Volt Switch" "Thunderbolt" ];
      };
      moltres = {
        ball = "beast"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Flame Body"; teraType = "Fire";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 252; spa = 4; spe = 252; };
        moves = [ "Roost" "Flamethrower" "Hurricane" "U-turn" ];
      };
      moltres-galar = {
        ball = "cherish"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Berserk"; teraType = "Dark";
        heldItem = "Weakness Policy";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Fiery Wrath" "Hurricane" "Agility" ];
      };
      dratini   = { ball = "level"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Marvel Scale"; teraType = "Dragon"; };
      dragonair = { ball = "level"; ot = true; selfObtained = true; level = 100; nature = "Adamant"; ability = "Marvel Scale"; teraType = "Dragon"; };
      dragonite = {
        ball = "level"; ot = true; selfObtained = true; level = 100;
        nature = "Adamant"; ability = "Multiscale"; teraType = "Normal";
        heldItem = "Heavy-Duty Boots";
        evs = { hp = 4; atk = 252; spe = 252; };
        moves = [ "Dragon Dance" "Extreme Speed" "Earthquake" "Roost" ];
      };
      mewtwo = {
        ball = "cherish"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Pressure"; teraType = "Psychic";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        ivs = { hp = 31; atk = 0; def = 31; spa = 31; spd = 31; spe = 31; };
        moves = [ "Psystrike" "Aura Sphere" "Ice Beam" "Calm Mind" ];
        notes = "Play! 2016 distribution";
      };
      mew = {
        ball = "poke"; ot = true; selfObtained = true; level = 100;
        nature = "Timid"; ability = "Synchronize"; teraType = "Psychic";
        heldItem = "Life Orb";
        evs = { hp = 4; spa = 252; spe = 252; };
        moves = [ "Nasty Plot" "Psychic" "Aura Sphere" "Soft-Boiled" ];
      };

      # » GENERATION 2 - JOHTO
      chikorita       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      bayleef         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      meganium-f      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      meganium-m      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      cyndaquil       = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      quilava         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      typhlosion      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      totodile        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      croconaw        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      feraligatr      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      sentret         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      furret          = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      hoothoot        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      noctowl         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      ledyba-f        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      ledyba-m        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      ledian-f        = { ball = "quick";   ot = true; style = "star"; egg = false; notes = ""; };
      ledian-m        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      spinarak        = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      ariados         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      crobat          = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      chinchou        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      lanturn         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pichu           = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      cleffa          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      igglybuff       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      togepi          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      togetic         = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      natu            = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      xatu-f          = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      xatu-m          = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      mareep          = { ball = "heal";    ot = true; style = "star"; egg = false; notes = ""; };
      flaaffy         = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      ampharos        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      bellossom       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      marill          = { ball = "heal";    ot = true; style = "star"; egg = false; notes = ""; };
      azumarill       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      sudowoodo-f     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sudowoodo-m     = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      politoed-f      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      politoed-m      = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      hoppip          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      skiploom        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      jumpluff        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      aipom-f         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      aipom-m         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      sunkern         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      sunflora        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      yanma           = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      wooper-f        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wooper-m        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      quagsire-f      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      quagsire-m      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      espeon          = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      umbreon         = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      murkrow-f       = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      murkrow-m       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      slowking        = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      slowking-galar  = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      misdreavus      = { ball = "heal";    ot = true; style = "star"; egg = false; notes = ""; };
      # unown-a            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-b            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-c            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-d            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-e            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-exclamation  = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      unown-f             = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      unown-g             = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      # unown-h            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-i            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-j            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-k            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-l            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-m            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-n            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-o            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-p            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-q            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-question     = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-r            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-s            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-t            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      unown-u             = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-v            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-w            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-x            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-y            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # unown-z            = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      wobbuffet-f     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wobbuffet-m     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      girafarig-f     = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      girafarig-m     = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      pineco          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      forretress      = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      dunsparce       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      gligar-f        = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      gligar-m        = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      steelix-f       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      steelix-m       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      snubbull        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      granbull        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      qwilfish        = { ball = "net";     ot = true; style = "star"; egg = false; notes = ""; };
      scizor-f        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      scizor-m        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      shuckle         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      heracross-f     = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      heracross-m     = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      sneasel-f       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      sneasel-m       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      teddiursa       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      ursaring-f      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      ursaring-m      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      slugma          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      magcargo        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      swinub          = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      piloswine-f     = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      piloswine-m     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      corsola         = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      corsola-galar   = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      remoraid        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      octillery-f     = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      octillery-m     = { ball = "heal";    ot = true; style = "star"; egg = false; notes = ""; };
      delibird        = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      mantine         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      skarmory        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      houndour        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      houndoom-f      = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      houndoom-m      = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      kingdra         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      phanpy          = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      donphan-f       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      donphan-m       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      porygon2        = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      stantler        = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      smeargle        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      tyrogue         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      hitmontop       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      smoochum        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      elekid          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      magby           = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      miltank         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      blissey         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      raikou          = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      entei           = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      suicune         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      larvitar        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      pupitar         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      tyranitar       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      lugia           = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      ho-oh           = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      celebi          = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };

      # GENERATION 3 — HOENN
      treecko         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      grovyle         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      sceptile        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      torchic-f       = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      torchic-m       = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      combusken-f     = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      combusken-m     = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      blaziken-f      = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      blaziken-m      = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      mudkip          = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      marshtomp       = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      Swampert        = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      poochyena       = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      mightyena       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      zigzagoon       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      zigzagoon-galar = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      linoone         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      linoone-galar   = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      wurmple         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      silcoon         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      beautifly-f     = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      beautifly-m     = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      cascoon         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      dustox-f        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      dustox-m        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lotad           = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lombre          = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      ludicolo-f      = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      ludicolo-m      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      seedot          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      nuzleaf-f       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      nuzleaf-m       = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      shiftry-f       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      shiftry-m       = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      taillow         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      swellow         = { ball = "quick";   ot = true; style = "star"; egg = false; notes = ""; };
      wingull         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pelipper        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      ralts           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      kirlia          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      gardevoir       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      surskit         = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      masquerain      = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      shroomish       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      breloom         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      slakoth         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      vigoroth        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      slaking         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      nincada         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      ninjask         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      shedinja        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      whismur         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      loudred         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      exploud         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      makuhita        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      hariyama        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      azurill         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      nosepass        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      skitty          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      delcatty        = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      sableye         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      mawile          = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      aron            = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lairon          = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      aggron          = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      meditite-f      = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      meditite-m      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      medicham-f      = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      medicham-m      = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      electrike       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      manectric       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      plusle          = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      minun           = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      volbeat         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      illumise        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      roselia-f       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      roselia-m       = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      gulpin-f        = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      gulpin-m        = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      swalot-f        = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      swalot-m        = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      carvanha        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sharpedo        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wailmer         = { ball = "net";     ot = true; style = "star"; egg = false; notes = ""; };
      wailord         = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      numel-f         = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      numel-m         = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      camerupt-f      = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      camerupt-m      = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      torkoal         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      spoink          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      grumpig         = { ball = "timer";   ot = true; style = "star"; egg = false; notes = ""; };
      spinda          = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      trapinch        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      vibrava         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      flygon          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cacnea          = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      cacturne-f      = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      cacturne-m      = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      swablu          = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      altaria         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      zangoose        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      seviper         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lunatone        = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      solrock         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      barboach        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      whiscash        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      corphish        = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      crawdaunt       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      baltoy          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      claydol         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lileep          = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      cradily         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      anorith         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      armaldo         = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      feebas          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      milotic-f       = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      milotic-m       = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      castform        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      kecleon         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      shuppet         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      banette         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      duskull         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      dusclops        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      tropius         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      chimecho        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      absol           = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      wynaut          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      snorunt         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      glalie          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      spheal          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sealeo          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      walrein         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      clamperl        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      huntail         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      gorebyss        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      relicanth-f     = { ball = "net";     ot = true; style = "star"; egg = false; notes = ""; };
      relicanth-m     = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      luvdisc         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      bagon           = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      shelgon         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      salamence       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      beldum          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      metang          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      metagross       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      registeel       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      # regirock        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # regice          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      latias          = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      latios          = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      kyogre          = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      groudon         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      rayquaza        = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      jirachi         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      deoxys          = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 4 - SINNOH
      turtwig         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      grotle          = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      torterra        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      chimchar        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      monferno        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      infernape       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      piplup          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      prinplup        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      empoleon        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      starly-f        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      starly-m        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      staravia-f      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      staravia-m      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      staraptor-f     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      staraptor-m     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      bidoof-f        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      bidoof-m        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      bibarel-f       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      bibarel-m       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      kricketot-f     = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      kricketot-m     = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      kricketune-f    = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      kricketune-m    = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      shinx-f         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      shinx-m         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      luxio-f         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      luxio-m         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      luxray-f        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      luxray-m        = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      budew           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      roserade-f      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      roserade-m      = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      cranidos        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      rampardos       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      shieldon        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      bastiodon       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      burmy-plant     = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      burmy-sandy     = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      burmy-trash     = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      wormadam-plant  = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      wormadam-sandy  = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      wormadam-trash  = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      mothim          = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      combee-f        = { ball = "net";     ot = true; style = "star"; egg = false; notes = ""; };
      combee-m        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      vespiquen       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pachirisu-f     = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      pachirisu-m     = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      buizel-f        = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      buizel-m        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      floatzel-f      = { ball = "quick";   ot = true; style = "star"; egg = false; notes = ""; };
      floatzel-m      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      cherubi         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cherrim         = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      shellos-east    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      shellos-west    = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      gastrodon-east  = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      gastrodon-west  = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      ambipom-f       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      ambipom-m       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      drifloon        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      drifblim        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      buneary         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lopunny         = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      mismagius       = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      honchkrow       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      glameow         = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      purugly         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      chingling       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      stunky          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      skuntank        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bronzor         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      bronzong        = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      bonsly          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      mime-jr         = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      happiny         = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      chatot          = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      spiritomb       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      gible-f         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      gible-m         = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      gabite-f        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      gabite-m        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      garchomp-f      = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      garchomp-m      = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      munchlax        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      riolu           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lucario         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      hippopotas-f    = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      hippopotas-m    = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      hippowdon-f     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      hippowdon-m     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      skorupi         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      drapion         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      croagunk-f      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      croagunk-m      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      toxicroak-f     = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      toxicroak-m     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      carnivine       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      finneon-f       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      finneon-m       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      lumineon-f      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lumineon-m      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      mantyke         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      snover-f        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      snover-m        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      abomasnow-f     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      abomasnow-m     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      weavile-f       = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      weavile-m       = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      magnezone       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lickilicky      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      rhyperior-f     = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      rhyperior-m     = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      tangrowth-f     = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      tangrowth-m     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      electivire      = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      magmortar       = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      togekiss        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      yanmega         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      leafeon         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      glaceon         = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      # gliscor         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      mamoswine-f     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      mamoswine-m     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      porygon-z       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      gallade         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      probopass       = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      dusknoir        = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      froslass        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      rotom           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rotom-fan       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rotom-frost     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rotom-heat      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rotom-mow       = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      rotom-wash      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      uxie            = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      mesprit         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      azelf           = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      # dialga          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # palkia          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # heatran         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      regigigas       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      giratina        = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      phione          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      darkrai         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      shaymin         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      # cresselia       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # arceus          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 5 - UNOVAno
      # victini         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      snivy           = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      servine         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      serperior       = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      tepig           = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      pignite         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      emboar          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      oshawott        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      dewott          = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      samurott        = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      patrat          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      watchog         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lillipup        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      herdier         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      stoutland       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      purrloin        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      liepard         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pansage         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      # simisage        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      pansear         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      simisear        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      panpour         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      # simipour        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      munna           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      musharna        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pidove          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tranquill       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      unfezant-f      = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      unfezant-m      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      blitzle         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      zebstrika       = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      roggenrola      = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      boldore         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      gigalith        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      woobat          = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      swoobat         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      drilbur         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      excadrill       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      audino          = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      timburr         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      gurdurr         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      conkeldurr      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      tympole         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      palpitoad       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      seismitoad      = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      throh           = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      sawk            = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      sewaddle        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      swadloon        = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      leavanny        = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      venipede        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      whirlipede      = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      scolipede       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      cottonee        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      whimsicott      = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      petilil         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      lilligant       = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      basculin-blue   = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      basculin-red    = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      sandile         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      krokorok        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      krookodile      = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      darumaka        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      darumaka-galar  = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      darmanitan      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      darmanitan-galar= { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      maractus        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      dwebble         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      crustle         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      scraggy         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      scrafty         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sigilyph        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      yamask          = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      yamask-galar    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cofagrigus      = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      tirtouga        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      carracosta      = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      archen          = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      archeops        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      trubbish        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      garbodor        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      garbodor-gmax   = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      zorua           = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      zoroark         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      minccino        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cinccino        = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      gothita         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      gothorita       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      gothitelle      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      solosis         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      duosion         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      reuniclus       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      ducklett        = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      swanna          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      vanillite       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      vanillish       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      vanilluxe       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      deerling-autumn = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      deerling-spring = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      deerling-summer = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      deerling-winter = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sawsbuck-autumn = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sawsbuck-spring = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sawsbuck-summer = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sawsbuck-winter = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      emolga          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      karrablast      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      escavalier      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      foongus         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      amoonguss       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      frillish-f      = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      frillish-m      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      jellicent-f     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      jellicent-m     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      alomomola       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      joltik          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      galvantula      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      ferroseed       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      ferrothorn      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      klink           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      klang           = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      klinklang       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tynamo          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      eelektrik       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      eelektross      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      elgyem          = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      beheeyem        = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      litwick         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lampent         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      chandelure      = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      axew            = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      fraxure         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      haxorus         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cubchoo         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      beartic         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cryogonal       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      shelmet         = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      accelgor        = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      stunfisk        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      stunfisk-galar  = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      mienfoo         = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      mienshao        = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      druddigon       = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      golett          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      golurk          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pawniard        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bisharp         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bouffalant      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rufflet         = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      braviary        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      vullaby         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      mandibuzz       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      heatmor         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      durant          = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      deino           = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      zweilous        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      hydreigon       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      larvesta        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      volcarona       = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      cobalion        = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      terrakion       = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      virizion        = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      tornadus        = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      # landorus        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      thundurus       = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      reshiram        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      # zekrom          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      kyurem          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      genesect        = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 6 - KALOS
      chespin         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      quilladin       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      chesnaught      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      fennekin        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      braixen         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      delphox         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      froakie         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      frogadier       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      greninja        = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      bunnelby        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      diggersby       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      fletchling      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      fletchinder     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      talonflame      = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      scatterbug      = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      spewpa          = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-archipelago = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-continental = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-elegant     = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-garden      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-high-plains = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-icy-snow    = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-jungle      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-marine      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-meadow      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-modern      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-monsoon     = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-ocean       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-polar       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-river       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-sandstorm   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-savanna     = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-sun         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # vivillon-tundra      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      litleo          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      pyroar-f        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pyroar-m        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      flabebe-blue    = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      flabebe-orange  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      flabebe-red     = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      flabebe-white   = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      flabebe-yellow  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      floette-blue    = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      floette-eternal = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      floette-orange  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      floette-red     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      floette-white   = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      floette-yellow  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      florges-blue    = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      florges-orange  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      florges-red     = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      florges-white   = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      florges-yellow  = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      skiddo          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      gogoat          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pancham         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      pangoro         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      furfrou         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      espurr          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      meowstic-f      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      meowstic-m      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      honedge         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      doublade        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      aegislash       = { ball = "quick";   ot = true; style = "star"; egg = false; notes = ""; };
      spritzee        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      aromatisse      = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      swirlix         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      slurpuff        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      inkay           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      malamar         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      binacle         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      barbaracle      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      skrelp          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dragalge        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      clauncher       = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      clawitzer       = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      helioptile      = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      heliolisk       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      tyrunt          = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      tyrantrum       = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      amaura          = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      aurorus         = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      sylveon         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      hawlucha        = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      dedenne         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      carbink         = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      goomy           = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      sliggoo         = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      goodra          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      klefki          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      phantump        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      trevenant       = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      pumpkaboo-small = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      pumpkaboo-average = { ball = "beast"; ot = true; style = "star"; egg = false; notes = ""; };
      pumpkaboo-large = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      pumpkaboo-super = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      gourgeist-small = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      gourgeist-average = { ball = "beast"; ot = true; style = "star"; egg = false; notes = ""; };
      gourgeist-large = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      gourgeist-super = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      bergmite        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      avalugg         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      noibat          = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      noivern         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      xerneas         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      yveltal         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      zygarde         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 7 - ALOLA
      rowlet          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      dartrix         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      decidueye       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      litten          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      torracat        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      incineroar      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      popplio         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      brionne         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      primarina       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      pikipek         = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      trumbeak        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      toucannon       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      yungoos         = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      gumshoos        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      grubbin         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      charjabug       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      vikavolt        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      crabrawler      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      crabominable    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      oricorio-baile  = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      oricorio-pompom = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      oricorio-pau    = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      oricorio-sensu  = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      cutiefly        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      ribombee        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      rockruff        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      lycanroc-dusk   = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      lycanroc-midday = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      lycanroc-midnight = { ball = "moon";  ot = true; style = "star"; egg = false; notes = ""; };
      wishiwashi      = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      mareanie        = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      toxapex         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      mudbray         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      mudsdale        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      dewpider        = { ball = "moon";    ot = true; style = "star"; egg = false; notes = ""; };
      araquanid       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      fomantis        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      lurantis        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      morelull        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      shiinotic       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      salandit        = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      salazzle        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      stufful         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bewear          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bounsweet       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      steenee         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tsareena        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      comfey          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      oranguru        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      passimian       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      wimpod          = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      golisopod       = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      sandygast       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      palossand       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      pyukumuku       = { ball = "net";     ot = true; style = "star"; egg = false; notes = ""; };
      type-null       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      silvally        = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      # minior          = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      komala          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      turtonator      = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      togedemaru      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      mimikyu         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bruxish         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      drampa          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      dhelmise        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      jangmo-o        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      hakamo-o        = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      kommo-o         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      tapu-koko       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      tapu-lele       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      tapu-bulu       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      tapu-fini       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      solgaleo        = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      lunala          = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      nihilego        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      # pheromosa       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # xurkitree       = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # celesteela      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # necrozma        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      buzzwole        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      kartana         = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      guzzlord        = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      poipole         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      naganadel       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      stakataka       = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      blacephalon     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      zeraora         = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      meltan          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      melmetal        = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 8 - GALAR
      grookey         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      thwackey        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      rillaboom       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      rillaboom-gmax  = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      scorbunny       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      raboot          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      cinderace       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      cinderace-gmax  = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      sobble          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      drizzile        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      inteleon        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      inteleon-gmax   = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      skwovet         = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      greedent        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rookidee        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      corvisquire     = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      corviknight     = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
#      corviknight-gmax= { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      blipbug         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dottler         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      orbeetle        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
 #     orbeetle-gmax   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      nickit          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      thievul         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      gossifleur      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      eldegoss        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      wooloo          = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      dubwool         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      chewtle         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      drednaw         = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      drednaw-gmax    = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      yamper          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      boltund         = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      rolycoly        = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      carkol          = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      coalossal       = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
#      coalossal-gmax  = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      applin          = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      flapple         = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
 #     flapple-gmax    = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      appletun        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
 #     appletun-gmax   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      silicobra       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sandaconda      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
  #    sandaconda-gmax = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      cramorant       = { ball = "timer";   ot = true; style = "star"; egg = false; notes = ""; };
      arrokuda        = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      barraskewda     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      toxel           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      toxtricity-amped   = { ball = "level"; ot = true; style = "star"; egg = false; notes = ""; };
      toxtricity-lowkey  = { ball = "safari"; ot = true; style = "star"; egg = false; notes = ""; };
   #   toxtricity-gmax    = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      sizzlipede      = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      centiskorch     = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      centiskorch-gmax= { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      clobbopus       = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      grapploct       = { ball = "fast";    ot = true; style = "star"; egg = false; notes = ""; };
      sinistea        = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      sinistea-antique= { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      polteageist     = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      polteageist-antique = { ball = "level"; ot = true; style = "star"; egg = false; notes = ""; };
      hatenna         = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      hattrem         = { ball = "premier"; ot = true; style = "star"; egg = false; notes = ""; };
      hatterene       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      hatterene-gmax  = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      impidimp        = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      morgrem         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      grimmsnarl      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      obstagoon       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      perrserker      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      cursola         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      sirfetchd       = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      mr-rime         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      runerigus       = { ball = "sport";   ot = true; style = "star"; egg = false; notes = ""; };
      milcery         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      #milcery-gmax    = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-strawberry = { ball = "master"; ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-berry     = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-love      = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-clover    = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-flower    = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-star      = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-ribbon    = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      alcremie-gmax      = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      falinks         = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      pincurchin      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      snom            = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      frosmoth        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      stonjourner     = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      eiscue          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      indeedee-f      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      indeedee-m      = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      morpeko         = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      cufant          = { ball = "repeat";  ot = true; style = "star"; egg = false; notes = ""; };
      copperajah      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
   #   copperajah-gmax = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      dracozolt       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      arctozolt       = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      dracovish       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      arctovish       = { ball = "dive";    ot = true; style = "star"; egg = false; notes = ""; };
      duraludon       = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      dreepy          = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      drakloak        = { ball = "master";  ot = true; style = "star"; egg = false; notes = ""; };
      dragapult       = { ball = "safari";  ot = true; style = "star"; egg = false; notes = ""; };
      zacian          = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      zamazenta       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      eternatus       = { ball = "cherish"; ot = true; style = "star"; egg = false; notes = ""; };
      regieleki       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      regidrago       = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };

      # PLA — HISUI
      # wyrdeer         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # kleavor         = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # ursaluna        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # sneasler        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # overqwil        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # enamorus        = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # growlithe-hisui = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # arcanine-hisui  = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # voltorb-hisui   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # electrode-hisui = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # qwilfish-hisui  = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # sneasel-hisui   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # lilligant-hisui = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # zoroark-hisui   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # braviary-hisui  = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # sliggoo-hisui   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # goodra-hisui    = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # dialga-origin   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      # palkia-origin   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      basculegion-f   = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      basculegion-m   = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      zorua-hisui     = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      samurott-hisui  = { ball = "great";   ot = true; style = "star"; egg = false; notes = ""; };
      typhlosion-hisui= { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      decidueye-hisui = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };

      # » GENERATION 9 - PALDEA
      sprigatito      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      floragato       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      meowscarada     = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      fuecoco         = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      crocalor        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      skeledirge      = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      quaxly          = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      quaxwell        = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      quaquaval       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      lechonk         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      oinkologne-f    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      oinkologne-m    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dudunsparce-two   = { ball = "luxury";   ot = true; style = "star"; egg = false; notes = ""; };
      dudunsparce-three = { ball = "luxury";   ot = true; style = "star"; egg = false; notes = ""; };
      tarountula      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      spidops         = { ball = "dream";   ot = true; style = "star"; egg = false; notes = ""; };
      nymble          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      lokix           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rellor          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      rabsca          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      greavard        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      houndstone      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      flittle         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      espathra        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      farigiraf       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wiglett         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wugtrio         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dondozo         = { ball = "love";    ot = true; style = "star"; egg = false; notes = ""; };
      veluza          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      finizen         = { ball = "lure";    ot = true; style = "star"; egg = false; notes = ""; };
      palafin         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      smoliv          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dolliv          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      arboliva        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      capsakid        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      scovillain      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tadbulb         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bellibolt       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      varoom          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      revavroom       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      orthworm        = { ball = "heavy";   ot = true; style = "star"; egg = false; notes = ""; };
      tandemaus       = { ball = "poke";    ot = true; style = "star"; egg = false; notes = ""; };
      maushold-three  = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      maushold-four   = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cetoddle        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      cetitan         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      frigibax        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      arctibax        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      baxcalibur      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tatsugiri-curly = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tatsugiri-droopy= { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tatsugiri-stretchy = { ball = "luxury";  ot = true; style = "star"; egg = false; notes = ""; };
      cyclizar        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pawmi           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pawmo           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      pawmot          = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      wattrel         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      kilowattrel     = { ball = "level";   ot = true; style = "star"; egg = false; notes = ""; };
      bombirdier      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      squawkabilly-green = { ball = "friend"; ot = true; style = "star"; egg = false; notes = ""; };
      squawkabilly-blue  = { ball = "lure";   ot = true; style = "star"; egg = false; notes = ""; };
      squawkabilly-white = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      squawkabilly-yellow= { ball = "luxury";    ot = true; style = "star"; egg = false; notes = ""; };
      flamigo         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      klawf           = { ball = "friend";  ot = true; style = "star"; egg = false; notes = ""; };
      nacli           = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      naclstack       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      garganacl       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      glimmet         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      glimmora        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      shroodle        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      grafaiai        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      fidough         = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      dachsbun        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      maschiff        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      mabosstiff      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      bramblin        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      brambleghast    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      great-tusk      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      brute-bonnet    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      sandy-shocks    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      scream-tail     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      flutter-mane    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      slither-wing    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      roaring-moon    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-treads     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-moth       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-hands      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-jugulis    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-thorns     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-bundle     = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      iron-valiant    = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tinkatink       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tinkatuff       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      tinkaton        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      charcadet       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      armarouge       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      ceruledge       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      toedscool       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      toedscruel      = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
#      wooper-paldea   = { ball = "luxury"; ot = true; style = "star"; egg = false; notes = ""; };
      clodsire        = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      kingambit       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
      annihilape      = { ball = "beast";   ot = true; style = "star"; egg = false; notes = ""; };
      dipplin         = { ball = "ultra";   ot = true; style = "star"; egg = false; notes = ""; };
      poltchageist    = { ball = "dusk";    ot = true; style = "star"; egg = false; notes = ""; };
      sinistcha       = { ball = "luxury";     ot = true; style = "star"; egg = false; notes = ""; };
    };


    # 🦆 ⮞ APRIBALLS BREEDABLES
    # APRIBALLS BREEDABLES
    breedables = {
      # » GENERATION 1 - KANTO REGION
      bulbasaur       = allHA // { friend = HAEM; heavy = HAEM; love = HAEM; moon = ball; };
      charmander      = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      squirtle        = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };
      caterpie        = allHA // { sport = none; friend = HAEM; heavy = HAEM; love = ball; };
      weedle          = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      pidgey          = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      rattata         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      rattata-alola   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      spearow         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      ekans           = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      pichu           = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      sandshrew       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      sandshrew-alola = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      nidoran-f       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      clefairy        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      vulpix          = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      vulpix-alola    = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      zubat           = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      oddish          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      paras           = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      venonat         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      jigglypuff      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      diglett         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      diglett-alola   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      meowth          = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      meowth-alola    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      meowth-galar    = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      psyduck         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      mankey          = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      growlithe       = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      poliwag         = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      abra            = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      machop          = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      bellsprout      = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      tentacool       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      geodude         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      geodude-alola   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      ponyta          = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      ponyta-galar    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      slowpoke        = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      slowpoke-galar  = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      magnemite       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      farfetchd       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      farfetchd-galar = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      doduo           = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      seel            = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      grimer          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      grimer-alola    = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      shellder        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      gastly          = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      onix            = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      drowzee         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      krabby          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      voltorb         = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      exeggcute       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      cubone          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      lickitung       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      koffing         = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      rhyhorn         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      chansey         = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      tangela         = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      kangaskhan      = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      horsea          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      goldeen         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      staryu          = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      mr-mime         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      mr-mime-galar   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      scyther         = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      smoochum        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      elekid          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      magby           = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      pinsir          = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      tauros          = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      tauros-paldea   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      tauros-paldea-blaze = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      tauros-paldea-aqua  = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      magikarp        = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      lapras          = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      eevee           = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      porygon         = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      omanyte         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      kabuto          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      aerodactyl      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      snorlax         = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      dratini         = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };


      # » GENERATION 2 - JOHTO REGION
      chikorita     = allHA // { sport = none; friend = HAEM; heavy = HAEM; love = ball; };
      cyndaquil     = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      totodile      = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      sentret       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      hoothoot      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      ledyba        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      spinarak      = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      chinchou      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      togepi        = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      natu          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      mareep        = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      marill        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      sudowoodo     = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      hoppip        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      aipom         = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      sunkern       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      yanma         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      wooper        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      wooper-paldea = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      murkrow       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      misdreavus    = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      wobbuffet     = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      girafarig     = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      pineco        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      dunsparce     = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      gligar        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      snubbull      = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      qwilfish      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      shuckle       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      heracross     = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      sneasel       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      teddiursa     = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      slugma        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      swinub        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      corsola       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      corsola-galar = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      remoraid      = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      delibird      = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      mantine       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      skarmory      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      houndour      = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      phanpy        = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      stantler      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      smeargle      = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      tyrogue       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      miltank       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      larvitar      = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };

      # » GENERATION 3 - HOENN REGION
      treecko         = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      torchic         = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      mudkip          = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      poochyena       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      zigzagoon       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      zigzagoon-galar = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      wurmple   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      lotad     = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      seedot    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      taillow   = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      wingull   = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      ralts     = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      surskit   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      shroomish = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      slakoth   = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      nincada   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      whismur   = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      makuhita  = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      nosepass  = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      skitty    = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      sableye   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      mawile    = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      aron      = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      meditite  = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      electrike = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      plusle    = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      minun     = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      volbeat   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      illumise  = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      roselia   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      gulpin    = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      carvanha  = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      wailmer   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      numel     = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      torkoal   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      spoink    = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      spinda    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      trapinch  = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      cacnea    = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      swablu    = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      zangoose  = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      seviper   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      lunatone  = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      solrock   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      barboach  = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      corphish  = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      baltoy    = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      lileep    = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      anorith   = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      feebas    = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      castform  = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      kecleon   = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      shuppet   = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      duskull   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      tropius   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      chingling = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      absol     = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      snorunt   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      spheal    = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      clamperl  = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      relicanth = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      luvdisc   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      bagon     = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      beldum    = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };



      # » GENERATION 4 - SINNOH REGION
      turtwig = allHA // { sport = none; friend = HAEM; heavy = HAEM; love = ball; };
      chimchar = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      piplup = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      starly = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      bidoof = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      kricketot   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      shinx       = allHA // { fast = none; heavy = HAEM; moon = HAEM; dream = ball; };
      cranidos    = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      shieldon    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      burmy-plant = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      burmy-sandy = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      burmy-trash = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      combee = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      pachirisu = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      buizel = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      cherubi = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      shellos-east = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      shellos-west = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      drifloon = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      buneary = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      glameow = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      stunky = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      bronzor = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      chatot = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      spiritomb = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      gible = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };
      riolu = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      hippopotas = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      skorupi = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      croagunk = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      carnivine = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      finneon = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      snover = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      rotom = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };

      # » GENERATION 5 - UNOVA REGION
      snivy          = allHA // { safari = none; fast = HAEM; level = HAEM; moon = ball; };
      tepig          = allHA // { love = none; lure = HAEM; dream = HAEM; beast = ball; };
      oshawott       = allHA // { friend = none; level = HAEM; love = HAEM; safari = ball; };
      patrat         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      lillipup       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      purrloin       = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      pansage        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      pansear        = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      panpour        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      munna          = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      pidove         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      blitzle        = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      roggenrola     = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      woobat         = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      drilbur        = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      audino         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      timburr        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      tympole        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      throh          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      sawk           = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      sewaddle       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      venipede       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      cottonee       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      petilil        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      basculin-red   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      basculin-blue  = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      sandile        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      darumaka       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      darumaka-galar = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      maractus       = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      dwebble        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      scraggy        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      sigilyph       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      yamask         = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      yamask-galar   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      tirtouga       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      archen         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      trubbish       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      zorua          = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      minccino       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      gothita        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      solosis        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      ducklett       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      vanillite      = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      deerling       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      emolga         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      karrablast     = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      foongus        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      frillish       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      alomomola      = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      joltik         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      ferroseed      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      klink          = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      tynamo         = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      elgyem         = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      litwick        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      axew           = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      cubchoo        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      cryogonal      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      shelmet        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      stunfisk       = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      stunfisk-galar = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      mienfoo        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      druddigon      = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      golett         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      pawniard       = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      bouffalant     = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      rufflet        = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      vullaby        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      heatmor        = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      durant         = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      deino          = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      larvesta       = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };



      # » GENERATION 6 - KALOS REGION
      chespin           = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      fennekin          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      froakie           = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      bunnelby          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      fletchling        = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      scatterbug        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      litleo            = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      flabebe-blue      = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      flabebe-orange    = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      flabebe-red       = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      flabebe-white     = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      flabebe-yellow    = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      skiddo            = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      pancham           = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      furfrou           = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      espurr            = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      honedge           = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      spritzee          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      swirlix           = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      inkay             = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      binacle           = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      skrelp            = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      clauncher         = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      helioptile        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      tyrunt            = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      amaura            = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      hawlucha          = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      dedenne           = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      carbink           = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      goomy             = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      klefki            = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      phantump          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      pumpkaboo-small   = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      pumpkaboo-average = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      pumpkaboo-large   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      pumpkaboo-super   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      bergmite          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      noibat            = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };



      # » GENERATION 7 - ALOLA REGION
      rowlet          = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      litten          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      popplio         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      pikipek         = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      yungoos         = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      grubbin         = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      crabrawler      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      oricorio-baile  = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      oricorio-pompom = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      oricorio-pau    = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      oricorio-sensu  = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      cutiefly        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      rockruff        = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      rockruff-dusk   = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      wishiwashi      = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      mareanie        = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      mudbray         = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      dewpider        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      fomantis        = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      morelull        = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      salandit        = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      stufful         = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      bounsweet       = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      comfey          = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      oranguru        = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      passimian       = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      wimpod          = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      sandygast       = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      pyukumuku       = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      minior-blue     = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      minior-green    = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      minior-indigo   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      minior-orange   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      minior-red      = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      minior-violet   = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      minior-yellow   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      komala          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      turtonator      = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      togedemaru      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      mimikyu         = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };
      bruxish         = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      drampa          = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      dhelmise        = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      jangmo-o        = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };



      # » GENERATION 8 - GALAR REGION
      grookey     = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      scorbunny   = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      sobble      = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };
      skwovet     = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      rookidee    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      blipbug     = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      nickit      = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      gossifleur  = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      wooloo      = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      chewtle     = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      yamper      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      rolycoly    = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      applin      = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
      silicobra   = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      cramorant   = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      arrokuda    = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      toxel       = allHA // { level = HAEM; lure = HAEM; dream = HAEM; friend = ball; };
      sizzlipede  = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      clobbopus   = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      sinistea    = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      hatenna     = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      impidimp    = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      milcery     = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      falinks     = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      pincurchin  = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      snom        = allHA // { fast = none; level = none; heavy = HAEM; lure = HAEM; moon = HAEM; };
      stonjourner = allHA // { sport = none; love = none; friend = HAEM; heavy = HAEM; moon = HAEM; };
      eiscue      = allHA // { safari = none; fast = none; level = HAEM; lure = HAEM; beast = HAEM; };
      indeedee    = allHA // { sport = none; fast = none; friend = HAEM; level = HAEM; dream = HAEM; };
      morpeko     = allHA // { safari = none; sport = none; heavy = HAEM; love = HAEM; lure = HAEM; };
      cufant      = allHA // { love = none; moon = none; fast = HAEM; level = HAEM; beast = HAEM; };
      duraludon   = allHA // { dream = none; beast = none; safari = HAEM; sport = HAEM; friend = HAEM; };
      dreepy      = allHA // { safari = HAEM; sport = HAEM; fast = HAEM; beast = ball; };
    };

  };}
