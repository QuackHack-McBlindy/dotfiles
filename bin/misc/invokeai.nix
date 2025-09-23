# dotfiles/bin/network/invokeai.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {  
  yo.scripts.invokeai = {
    description = "AI generated images powered by InvokeAI";
    category = "🧩 Miscellaneous";
    aliases = [ "genimg" ];
#    helpFooter = ''
#    '';
    parameters = [
      { name = "prompt"; description = "Prompt for image generation"; optional = false; }    
      { name = "host"; description = "API host"; default = "localhost"; }    
      { name = "port"; description = "API port"; default = "9090"; }    
      { name = "outputDir"; description = "Output directory"; default = "/home/" + config.this.user.me.name + "/invokeai-data/images"; }    
      { name = "width"; description = "Image width"; default = "512"; }    
      { name = "height"; description = "Image height"; default = "512"; }    
      { name = "steps"; description = "Number of steps"; default = "20"; }    
      { name = "cfgScale"; description = "CFG scale"; default = "7.5"; }         
      { name = "seed"; description = "Random seed"; default = "-1"; }  
      { name = "model"; description = "Model to use"; default = "sd-1.5"; }
    ];
    code = ''
      ${cmdHelpers}
      HOST=$host
      PORT=$port
      PROMPT="$proompt"
      OUTPUT_DIR=$outputDir
      WIDTH=$width
      HEIGHT=$height
      STEPS=$steps
      CFG_SCALE=$cfgScale
      SAMPLER="euler_a"
      SEED=$seed
      MODEL=$model
      BATCH_SIZE=1
      mkdir -p "$OUTPUT_DIR"
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      API_URL="http://$HOST:$PORT"

      check_api() {
          if curl -s --head "$API_URL/docs" | head -n 1 | grep "200" > /dev/null; then
              return 0
          else
              return 1
          fi
      }


      json_payload=$(cat << EOF
{
    "prompt": "$prompt",
    "width": $WIDTH,
    "height": $HEIGHT,
    "steps": $STEPS,
    "cfg_scale": $CFG_SCALE,
    "sampler_name": "$SAMPLER",
    "seed": $SEED,
    "model": "$MODEL",
    "batch_size": $BATCH_SIZE
}
EOF
      )      

      filename="$OUTPUT_DIR/invokeai_$TIMESTAMP.png"
      dt_info "Generating image $filename with prompt: $prompt"

      response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" "$API_URL/api/v1/generate")
      
      http_code=''${response: -3}
      response_body=''${response:0: -3}
      dt_info "HTTP Status Code: $http_code"
    '';
    voice = {
      enabled = false;
      priority = 5;
      sentences = [
        "skapa en bild av {prompt} i {style}"
        "generera en {style} bild av {prompt}"
        "gör en {style} bild på {prompt}"
        "fixa en {style} bild av {prompt}"
        "rita en {style} illustration av {prompt}"
      ];        
      lists = {
        style.values = [
          { "in" = "realistisk"; out = "realistic"; }
          { "in" = "realism"; out = "realistic"; }
          { "in" = "målning"; out = "painting"; }
          { "in" = "olja"; out = "oil painting"; }
          { "in" = "akvarell"; out = "watercolor"; }
          { "in" = "tecknad"; out = "cartoon"; }
          { "in" = "serie"; out = "comic"; }
          { "in" = "anime"; out = "anime"; }
          { "in" = "manga"; out = "manga"; }
          { "in" = "digital"; out = "digital art"; }
          { "in" = "fantasy"; out = "fantasy"; }
          { "in" = "sci-fi"; out = "sci-fi"; }
          { "in" = "surrealistisk"; out = "surrealism"; }
          { "in" = "minimalistisk"; out = "minimalism"; }
          { "in" = "fotorealistisk"; out = "photorealistic"; }
          { "in" = "3d"; out = "3d render"; }
        ];
        prompt.wildcard = true;
      };
    };    
    
  };}
