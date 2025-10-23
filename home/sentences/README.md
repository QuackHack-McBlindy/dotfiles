🦆🏠  HOME via  via 🐍 v3.12.10 
23:41:47 ❯ yo do -h

   🚀🦆 yo do                                                                     
                                                                                  
  Usage:  yo do [OPTIONS]                                                         
  Natural language to Shell script translator with dynamic regex matching and     
  automatic parameter resolutiion                                                 
                                                                                  
  ## Parameters                                                                   
                                                                                  
   --input                                                                        
  Text to parse into a yo command                                                 
                                                                                  
   --fuzzyThreshold                                                               
  Minimum procentage for considering fuzzy matching sucessful. (1-100)            
  (optional) (default: 15)                                                        
                                                                                  
   🦆 Voice Commands Reference                                                    
                                                                                  
   ⚡ Productivity                                                                
                                                                                  
  calculator:                                                                     
  - "(beräkna|beräknar|räkna|räknar) [ut] ANYTHING"                               
  - "(beräkna|beräknar|räkna|räknar) ut ANYTHING"                                 
  - "lös ekvationen ANYTHING"                                                     
                                                                                  
  calendar:                                                                       
  - "vad har jag planerat [idag|imorgon]"                                         
  - "visa min kalender för ANYTHING"                                              
  - "har jag något inbokat [idag|imorgon]"                                        
  - "vad händer [på] [dag] [idag]"                                                
  - "vad har jag [i] kalendern [idag]"                                            
  - "visa [min] kalender [för] [idag]"                                            
  - "kalender [händelser] [idag]"                                                 
                                                                                  
  clip2phone:                                                                     
  - "kopiera till telefonen"                                                      
  - "skicka clipboard till telefonen"                                             
                                                                                  
  google:                                                                         
  - "sök [efter|på|om] ANYTHING på google"                                        
  - "(google|googl) [efter|på|om] ANYTHING"                                       
                                                                                  
  hitta:                                                                          
  - "vad har ANYTHING för adress"                                                 
  - "ta reda på ANYTHING adress"                                                  
  - "(säg|berätta|hämta) ANYTHING adress"                                         
  - "sök efter ANYTHING på hitta"                                                 
                                                                                  
   🌍 Localization                                                                
                                                                                  
  stores:                                                                         
  - "vilken tid (öppnar|stänger) ANYTHING"                                        
  - "vad har ANYTHING för öppettider"                                             
  - "var är närmaste ANYTHING"                                                    
  - "finns det någon ANYTHING i närheten"                                         
  - "när stänger ANYTHING"                                                        
  - "när öppnar ANYTHING"                                                         
                                                                                  
  travel:                                                                         
  - "mår går tåget till ANYTHING"                                                 
  - "vilken tid går tåget till ANYTHING"                                          
  - "mår går bussen till ANYTHING"                                                
  - "vilken tid går bussen till ANYTHING"                                         
  - "mår går tåget från ANYTHING"                                                 
  - "vilken tid går tåget från ANYTHING"                                          
  - "mår går bussen från ANYTHING"                                                
  - "vilken tid går bussen från ANYTHING"                                         
  - "när går (bus|buss|bussen|...) från ANYTHING till ANYTHING"                   
  - "vilken tid går (bus|buss|bussen|...) från ANYTHING till ANYTHING"            
  - "när går (bus|buss|bussen|...) till ANYTHING från ANYTHING"                   
  - "vilken tid går (bus|buss|bussen|...) till ANYTHING från ANYTHING"            
                                                                                  
  weather:                                                                        
  - "hur är vädret"                                                               
  - "vädret"                                                                      
  - "hur (blir|är) vädret [på] (ida|idag|imorgon|...)"                            
  - "hur (varmt|kallt) (blir|är) det [på] (ida|idag|imorgon|...)"                 
  - "vad blir det för väder [på] (ida|idag|imorgon|...)"                          
  - "hur (sol|soligt|klart|...) (är|blir) det på (ida|idag|imorgon|...)"          
  - "blir det (sol|soligt|klart|...) [på] (ida|idag|imorgon|...)"                 
  - "hur (sol|soligt|klart|...) är det"                                           
  - "kommer det att (sol|soligt|klart|...) [på] (ida|idag|imorgon|...)"           
                                                                                  
   🌐 Networking                                                                  
                                                                                  
  ip-updater:                                                                     
  - "uppdatera duckdns"                                                           
  - "uppdatera [mitt] [duck]dns ip"                                               
                                                                                  
  shareWiFi:                                                                      
  - "dela [gäst] (wifi|internet)"                                                 
  - "(internet|wifi) delning"                                                     
  - "dela [mitt] (internet|wifi) för gäster"                                      
  - "dela [mitt] (internet|wifi)"                                                 
                                                                                  
  speed:                                                                          
  - "nätverks test"                                                               
  - "hur fort går internet"                                                       
  - "testa internet hastigheten"                                                  
                                                                                  
   🎧 Media Management                                                            
                                                                                  
  news:                                                                           
  - "(senast|senaste) (myt|nyt|nytt)"                                             
                                                                                  
  tv:                                                                             
  - "[jag] (spel|spela|kör|start|starta) [upp|igång] (serie|serien|tvserien|...)  
  ANYTHING i (sovrum|sovrummet|bedroom|...)"                                      
  - "jag vill se (serie|serien|tvserien|...) ANYTHING i                           
  (sovrum|sovrummet|bedroom|...)"                                                 
  - "jag vill lyssna på (serie|serien|tvserien|...) i                             
  (sovrum|sovrummet|bedroom|...)"                                                 
  - "jag vill höra (serie|serien|tvserien|...) ANYTHING i                         
  (sovrum|sovrummet|bedroom|...)"                                                 
  - "(serie|serien|tvserien|...) (volym|volymen|avsnitt|avsnittet|låt|låten|      
  skiten)                                                                         
  i (sovrum|sovrummet|bedroom|...)"                                               
  - "tv (serie|serien|tvserien|...) i (sovrum|sovrummet|bedroom|...)"             
  - "[jag] (spel|spela|kör|start|starta) [upp|igång] (serie|serien|tvserien|...)  
  ANYTHING"                                                                       
  - "jag vill se (serie|serien|tvserien|...) ANYTHING"                            
  - "jag vill lyssna på [mina] (serie|serien|tvserien|...)"                       
  - "jag vill höra [mina] (serie|serien|tvserien|...)"                            
  - "(serie|serien|tvserien|...)                                                  
  (volym|volymen|avsnitt|avsnittet|låt|låten|skiten)"                             
  - "tv (serie|serien|tvserien|...)"                                              
  - "spara i (serie|serien|tvserien|...)"                                         
  - "lägg till den här [låten] i (serie|serien|tvserien|...)"                     
  - "ring (serie|serien|tvserien|...)"                                            
  - "hitta (serie|serien|tvserien|...)"                                           
                                                                                  
  tv-guide:                                                                       
  - "vilken kanal (spela|spelas|sänds|går|är) ANYTHING på"                        
  - "vad (sänds|visas|spelas|går) på [kanal] (SVT1|1|[Kanal 10|10]|...) [just nu]"
                                                                                  
   🖥️ System Management                                                           
                                                                                  
  reboot:                                                                         
  - "starta om (desktop|vatten|homie|...) [dator|datorn]"                         
  - "starta om (desktop|vatten|homie|...) [server|servern]"                       
                                                                                  
  switch:                                                                         
  - "bygg om systemet"                                                            
                                                                                  
   🛖 Home Automation                                                             
                                                                                  
  alarm:                                                                          
  - "(ställ|sätt|starta) [en] (väckarklocka|väckarklockan|larm|alarm) [på]        
  [klocka|klockan] (1|2|3|...) [och] (0|1|2|...)"                                 
  - "väck mig [klocka|klockan] (1|2|3|...) [och] (0|1|2|...)"                     
  - "när ska jag (stiga|vakna|ringer) [upp]"                                      
  - "när (stiga|vakna|ringer) min väckarklocka"                                   
                                                                                  
  battery:                                                                        
  - "hur mycket batteri har (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5        
  dimmeren]|...) [kvar]"                                                          
  - "batteri nivå [på] (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5             
  dimmeren]|...)"                                                                 
  - "vad är (batteri|batteronivån) [nivån] [på] (vägg|väggen|[ikea 5              
  dimmer|ikea5dimmer|ikea 5 dimmeren]|...)"                                       
  - "(berätta|säg) hur mycket batteri (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea
  5 dimmeren]|...) [har] [kvar]"                                                  
                                                                                  
  blinds:                                                                         
  - "(persienner|persiennerna) (upp|uppe|ned|...)"                                
  - "(blind|blinds) (upp|uppe|ned|...)"                                           
                                                                                  
  findPhone:                                                                      
  - "hitta [min] telefon"                                                         
  - "var är min telefon"                                                          
  - "ring min telefon"                                                            
                                                                                  
  house:                                                                          
  - "(vardagsrum|vardagsrummet|kök|...) (tänd|tända|tänk|...) och färg            
  (röd|rött|röda|...)"                                                            
  - "(vardagsrum|vardagsrummet|kök|...) (tänd|tända|tänk|...) och ljusstyrka      
  (1|2|3|...) procent"                                                            
  - "(gör|ändra) (vardagsrum|vardagsrummet|kök|...) [till] (röd|rött|röda|...)    
  [färg] [och] (1|2|3|...) procent [ljusstyrka]"                                  
  - "(tänd|tänk|släck|starta|stäng) (vardagsrum|vardagsrummet|kök|...)"           
  - "ANYTHING alla lampor i (vardagsrum|vardagsrummet|kök|...)"                   
  - "(tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...) lampor"             
  - "(tänd|tända|tänk|...) lamporna i (vardagsrum|vardagsrummet|kök|...)"         
  - "(tänd|tända|tänk|...) alla lampor"                                           
  - "stäng (tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...)"              
  - "starta (tänd|tända|tänk|...) (vardagsrum|vardagsrummet|kök|...)"             
  - "(ändra|gör) färgen [på|i] (vardagsrum|vardagsrummet|kök|...) till            
  (röd|rött|röda|...)"                                                            
  - "(ändra|gör) (vardagsrum|vardagsrummet|kök|...) (röd|rött|röda|...)"          
  - "justera (vardagsrum|vardagsrummet|kök|...) till (1|2|3|...) procent"         
                                                                                  
  kitchenFan:                                                                     
  - "(fläkt|fläck|fkäckt|fläckten|fläkten) (på|av)"                               
                                                                                  
  state:                                                                          
  - "är (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...) på[slagen]  
  [slagen]"                                                                       
  - "är (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...) på eller av"
  - "är (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...) öppen"      
  - "är (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...) stängd"     
  - "är (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...)             
  [öppen|stängd]"                                                                 
  - "vad är status på (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5              
  dimmeren]|...)"                                                                 
  - "status (vägg|väggen|[ikea 5 dimmer|ikea5dimmer|ikea 5 dimmeren]|...)"        
                                                                                  
  temperatures:                                                                   
  - "hur varmt är det (inne|inomhus)"                                             
  - "vad är det för (temp|temperatur) (inne|inomhus)"                             
  - "hur varmmt är det inne"                                                      
                                                                                  
  tibber:                                                                         
  - "vad kostar strömmen"                                                         
  - "hur mycket kostar strömmen"                                                  
  - "vad är elpriset just nu"                                                     
                                                                                  
  timer:                                                                          
  - "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] (1|ett|2|...)        
  (timme|timmar) (1|ett|2|...) (minut|minuter) (1|ett|2|...) (sekund|sekunder)"   
  - "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] (1|ett|2|...)        
  (minut|minuter) [och] (1|ett|2|...) (sekund|sekunder)"                          
  - "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] (1|ett|2|...)        
  (minut|minuter)"                                                                
  - "(skapa|ställ|sätt|starta) [en] (time|timer|timern) [på] (1|ett|2|...)        
  sekunder"                                                                       
  - "hur (länge|kvar) är det kvar på (time|timer|timern)"                         
  - "tid (länge|kvar) på (time|timer|timern)"                                     
  - "när (länge|kvar) (time|timer|timern)"                                        
                                                                                  
   🧩 Miscellaneous                                                               
                                                                                  
  chat:                                                                           
  - "hej ANYTHING"                                                                
  - "hejsan ANYTHING"                                                             
                                                                                  
  duckPUCK:                                                                       
  - "hockey tabellen"                                                             
  - "visa hockeytabellen"                                                         
  - "hur ser tabellen ut"                                                         
  - "visa allsvenska tabellen"                                                    
  - "hur ligger lagen till"                                                       
  - "vad är ställningen i tabellen"                                               
  - "vad ligger (björklöven|björklövens|löven|...) i tabellen"                    
  - "visa (björklöven|björklövens|löven|...) statistik"                           
  - "var ligger (björklöven|björklövens|löven|...) i tabellen"                    
  - "vilken plats har (björklöven|björklövens|löven|...)"                         
  - "hur går det för (björklöven|björklövens|löven|...)"                          
  - "hur ligger (björklöven|björklövens|löven|...) till"                          
  - "är (björklöven|björklövens|löven|...) på slutspelsplats"                     
  - "är (björklöven|björklövens|löven|...) på kvalplats"                          
  - "hur många poäng har (björklöven|björklövens|löven|...)"                      
  - "visa {team}s statistik"                                                      
  - "visa statistik för (björklöven|björklövens|löven|...)"                       
  - "hur ser {team}s statistik ut"                                                
  - "vad har (björklöven|björklövens|löven|...) för statistik"                    
  - "ge mig {team}s siffror"                                                      
  - "hur går det för (björklöven|björklövens|löven|...) den                       
  (förra|senaste|igår|...) tiden"                                                 
  - "analysera (björklöven|björklövens|löven|...)"                                
  - "ge en analys av (björklöven|björklövens|löven|...)"                          
  - "analysera [laget] (björklöven|björklövens|löven|...)"                        
  - "analysera {team}s (förra|senaste|igår|...) matcher"                          
  - "hur presterade (björklöven|björklövens|löven|...) i (förra|senaste|igår|...) 
  matchen"                                                                        
  - "vilka trender har (björklöven|björklövens|löven|...)"                        
  - "vad har (björklöven|björklövens|löven|...) (för|i)                           
  ([power|powerplay|pp|överläge|numerärt överläge]|[box|boxplay|bp|box            
  play|undertal|numerärt underläge]) (statistik|stats)"                           
  - "analysera (björklöven|björklövens|löven|...)                                 
  ([power|powerplay|pp|överläge|numerärt överläge]|[box|boxplay|bp|box            
  play|undertal|numerärt underläge])"                                             
  - "hur (bra|dåliga|effektiva) är (björklöven|björklövens|löven|...) [i]         
  ([power|powerplay|pp|överläge|numerärt överläge]|[box|boxplay|bp|box            
  play|undertal|numerärt underläge])"                                             
  - "hur presterar (björklöven|björklövens|löven|...) [i]                         
  ([power|powerplay|pp|överläge|numerärt överläge]|[box|boxplay|bp|box            
  play|undertal|numerärt underläge])"                                             
  - "hur ser {team}s ([power|powerplay|pp|överläge|numerärt                       
  överläge]|[box|boxplay|bp|box play|undertal|numerärt underläge]) ut"            
  - "visa {team}s ([power|powerplay|pp|överläge|numerärt                          
  överläge]|[box|boxplay|bp|box play|undertal|numerärt underläge])"               
  - "analysera {team}s ([power|powerplay|pp|överläge|numerärt                     
  överläge]|[box|boxplay|bp|box play|undertal|numerärt underläge])"               
  - "ge en analys av {team}s ([power|powerplay|pp|överläge|numerärt               
  överläge]|[box|boxplay|bp|box play|undertal|numerärt underläge])"               
  - "visa (förra|senaste|igår|...) matcher"                                       
  - "vilka matcher spelas (förra|senaste|igår|...)"                               
  - "visa matcher [för] (förra|senaste|igår|...)"                                 
  - "när spelar (björklöven|björklövens|löven|...) (förra|senaste|igår|...) gång" 
  - "vilka möter (björklöven|björklövens|löven|...) (förra|senaste|igår|...)"     
  - "vilka matcher har (björklöven|björklövens|löven|...) (förra|senaste|igår|... 
  )"                                                                              
  - "när är {team}s (förra|senaste|igår|...) match"                               
                                                                                  
  hockeyGames:                                                                    
  - "(vad|hur) (hände|gick) (det|matchen) (för|med)                               
  (björklöven|björklövens|löven|...) (senast|igår)"                               
  - "(berätta|visa) (om|) (björklöven|björklövens|löven|...) (senaste|sista)      
  match"                                                                          
  - "(vilka|vad) (hände|resultat) (i|) hockyn (igår|senast)"                      
  - "senaste hockymatcherna"                                                      
  - "allsvenskan matcher"                                                         
  - "när (är|spelar) (björklöven|björklövens|löven|...) [sin]                     
  (kommande|nästa|senaste|...) match"                                             
  - "hur har (björklöven|björklövens|löven|...) spelat [den]                      
  (kommande|nästa|senaste|...) [tiden]"                                           
  - "hur (var|spelade) (björklöven|björklövens|löven|...)                         
  (kommande|nästa|senaste|...) matchen"                                           
                                                                                  
  joke:                                                                           
  - "få höra [ett] [roligt] skämt"                                                
  - "berätta [ett] [roligt] skämt"                                                
  - "säg [ett] [roligt] skämt"                                                    
  - "få mig [att] skratta"                                                        
  - "gör mig glad"                                                                
                                                                                  
  post:                                                                           
  - "när kommer [nästa] (post|posten) [leverans|leveransen]"                      
  - "vilken dag kommer posten"                                                    
                                                                                  
  reminder:                                                                       
  - "påminn [mig] om [att] ANYTHING"                                              
  - "(visa) påminnelser"                                                          
  - "(rensa) påminnelser"                                                         
                                                                                  
  shop-list:                                                                      
  - "(lägg|ta|bort|...) till ANYTHING i (inköpslistan|shoppinglistan)"            
  - "(lägg|ta|bort|...) ANYTHING till (inköpslistan|shoppinglistan)"              
  - "(lägg|ta|bort|...) till ANYTHING på listan"                                  
  - "(lägg|ta|bort|...) till ANYTHING"                                            
  - "(lägg|ta|bort|...) ANYTHING på (inköpslistan|shoppinglistan)"                
  - "(lägg|ta|bort|...) [bort] ANYTHING (från|i) (inköpslistan|shoppinglistan)"   
  - "(lägg|ta|bort|...) [bort] ANYTHING (från|i) listan"                          
  - "(lägg|ta|bort|...) bort ANYTHING"                                            
  - "(lägg|ta|bort|...) ANYTHING från listan"                                     
  - "visa inköpslistan"                                                           
  - "vad finns på inköpslistan"                                                   
  - "visa listan"                                                                 
  - "vad är på listan"                                                            
                                                                                  
  time:                                                                           
  - "(va|vad|vart) är klockan"                                                    
  - "hur mycket är klockan"                                                       
  - "(va|vad|vart) är det för dag"                                                
  - "vilket datum är det"                                                         
  - "vad är det för datum"                                                        
                                                                                  
   🧹 Maintenance                                                                 
                                                                                  
  health:                                                                         
  - "kolla hälsan på (local|main|nas|...)"                                        
  - "hur mår (local|main|nas|...)"                                                
  - "visa status för (local|main|nas|...)"                                        
                                                                                  
   ----────----──⋆⋅☆☆☆⋅⋆─────----─                                                
                                                                                  
   Stats                                                                          
                                                                                  
  • Scripts with voice: 41 / 74                                                   
  • Generated patterns: 1785                                                      
  • Understandable phrases: 271859967                                             


