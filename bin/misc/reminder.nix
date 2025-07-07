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
      { name = "about"; description = "What to be reminded about"; optional = false; }
      { name = "date"; description = "When to remind"; optional = true; }
    ];
    code = ''
      ${cmdHelpers}
      target_time=$(date -d "1 minute" +"%F %T")
    
      if [[ -n "$date" ]]; then
        if [[ "$date" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
          target_time=$(date -d "$date" +"%F %T")
        else
          target_time=$(date -d "$date" +"%F %T" 2>/dev/null || {
            dt_error "Invalid date format: $date"
            exit 1
          })
        fi
      fi

      reminder_cmd=""
      reminder_cmd+="PATH=/run/current-system/sw/bin:/bin:/usr/bin"    
      reminder_cmd+="notify-send 'Påminnelse' '$about' --icon=dialog-information; "
      reminder_cmd+="yo-say 'Kom ihåg: $about'"

      if systemctl --user list-timers > /dev/null 2>&1; then
        systemd-run --user \
          --on-calendar="$target_time" \
          /bin/sh -c "$reminder_cmd"
        dt_info "Reminder set via systemd: $(date -d "$target_time" +'%F %H:%M')"

      elif command -v at >/dev/null; then
        echo "$reminder_cmd" | 
          at "$(date -d "$target_time" +'%H:%M %F')" 2>/dev/null
        dt_debug "Using fallback (at command) for: $(date -d "$target_time" +'%F %H:%M')"
    
      else
        dt_error "Requires systemd or at"
        exit 1
      fi
    '';
  };}
