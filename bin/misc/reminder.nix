# dotfiles/bin/misc/reminder.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ 
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : {  
  environment.systemPackages = [ pkgs.at ];
  
  yo.bitch = {
    intents.reminder = {
      data = [{
        sentences = [
          "påminn [mig] om [att] {reminder}"
          "påminn [mig] om [att] {reminder} den {date}"
        ];
        lists = {
          about.wildcard = true;
          date.values = [
            { "in" = "imorgon"; out = "tomorrow"; }
            { "in" = "idag"; out = "today"; }
            { "in" = "övermorgon"; out = "day after tomorrow"; }
            { "in" = "om en timme"; out = "in 1 hour"; }
            { "in" = "om 30 minuter"; out = "in 30 minutes"; }
            { "in" = "klockan 15"; out = "15:00"; }
          ];
        };
      }];
    };
  };

  yo.scripts.reminder = {
    description = "Reminder Assistant";
    category = "🧩 Miscellaneous";
    aliases = [ "remind" ];
    autoStart = false;
    logLevel = "DEBUG";
    parameters = [
      { name = "about"; description = "What to be reminded about"; optional = true; }
      { name = "list"; description = "Flag for listing all reminders"; optional = true; }            
#      { name = "date"; description = "When to remind"; optional = true; }
    ];
    code = ''
      ${cmdHelpers}
      ${cmdHelpers}
  
      REMINDER_DIR="/home/pungkula/.reminders"
      mkdir -p "$REMINDER_DIR"

      estimate_speech_duration() {
        local text="$1"
        local words_per_minute=150  # average TTS rate
        local words
        words=$(echo "$text" | wc -w)
        local seconds
        seconds=$(awk -v wpm="$words_per_minute" -v w="$words" 'BEGIN { print int((w / wpm) * 60 + 1) }')
        echo "$seconds"
      }

  
      list_reminders() {
        if [ "$(ls -A "$REMINDER_DIR")" ]; then
          for file in "$REMINDER_DIR"/*; do
            if [ -f "$file" ]; then
              content=$(<"$file")
              dt_debug "Reminder: $content"
              yo say --text "Påminnelse: $content" --blocking "true"
            fi
          done
        else
          echo "No reminder files found in $REMINDER_DIR."
        fi
      }
  
      add_reminder() {
        local id
        id=$(date +%s)
        echo "$about" > "$REMINDER_DIR/$id"
        echo "Reminder added: $about"
        dt_debug "Saved reminder to $REMINDER_DIR/$id"
      }
  
      if [[ -n "$about" ]]; then
        add_reminder
      else
        list_reminders
      fi
    '';
  };}
