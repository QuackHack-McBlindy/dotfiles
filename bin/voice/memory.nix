# dotfiles/bin/config/memory.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ stats for fail ratio and memory for context awareness
  self,
  lib,
  config,
  pkgs,
  sysHosts,
  cmdHelpers,
  ...
} : let
  # 🦆 says ⮞ Statistical logging for failed commands
  statsDir = "/home/${config.this.user.me.name}/.local/share/yo/stats";
  failedCommandsLog = "${statsDir}/failed_commands.log";
  commandStatsDB = "${statsDir}/command_stats.json";
  
in {
  yo.scripts = {
    memory = {
      description = "Memory is stats and metrics that acts as contexual awareness for the natural langugage processor. ";
      category = "🗣️ Voice"; # 🦆 says ⮞ duckgorize iz zmart wen u hab many scriptz i'd say!     
      aliases = [ "stats" ];
      autoStart = false;
      logLevel = "INFO";
      helpFooter = ''
        echo "[🦆📶] yo memory"

        echo "[🦆📶]"    
        echo "Commands:"
        echo "  failed      - Show most frequently failed commands"
        echo "  successful  - Show most used successful commands"
        echo "  fuzzy       - Show fuzzy match statistics"
        echo "  summary     - Show overall statistics"
        echo "  reset       - Reset all statistics"
        echo "  tail        - Live tail of failed commands"
      '';
      parameters = [ # 🦆 says ⮞ set your mosquitto user & password
        { 
          name = "show";
          type = "string";
          description = "What stat to analyze";
          default = "summary";
          values = [ "failed" "successful" "summary" "fuzzy" ];
        }  
        { name = "good"; type = "bool"; description = "Tell the brain it did a good job. Confirming the last command was a proper match"; default = false; }   
        { name = "tail"; type = "bool"; description = "Live tail of failed commands"; default = false; }
        { name = "reset"; type = "bool"; description = "Warning! Will reset all stats!"; default = false; }
      ];

      code = ''
        set +u  
        ${cmdHelpers} # 🦆 says ⮞load required bash helper functions 
        GOOD_JOB="$good"

        # 🦆 says ⮞ memory paths
        MEMORY_DIR="${statsDir}"
        COMMAND_HISTORY_FILE="$MEMORY_DIR/command_history.json"
        CONTEXT_FILE="$MEMORY_DIR/current_context.json"
        CHAIN_FILE="$MEMORY_DIR/active_chains.json"
        mkdir -p "$MEMORY_DIR"
        init_memory_files() {
          if [ ! -f "$COMMAND_HISTORY_FILE" ]; then
            echo '{"recent_commands": [], "confirmed_matches": {}}' > "$COMMAND_HISTORY_FILE"
          fi
          if [ ! -f "$CONTEXT_FILE" ]; then
            echo '{"last_action": "", "active_servers": [], "environment": "default", "user_preferences": {}}' > "$CONTEXT_FILE"
          fi
          if [ ! -f "$CHAIN_FILE" ]; then
            echo '{"active_chains": {}, "completed_chains": {}}' > "$CHAIN_FILE"
          fi
        }
        
        init_memory_files
        
        # 🦆 says ⮞ load memory
        load_command_history() {
          if [ -f "$COMMAND_HISTORY_FILE" ]; then
            cat "$COMMAND_HISTORY_FILE"
          else
            echo '{"recent_commands": [], "confirmed_matches": {}}'
          fi
        }
        
        load_context() {
          if [ -f "$CONTEXT_FILE" ]; then
            cat "$CONTEXT_FILE"
          else
            echo '{"last_action": "", "active_servers": [], "environment": "default"}'
          fi
        }
        
        load_chains() {
          if [ -f "$CHAIN_FILE" ]; then
            cat "$CHAIN_FILE"
          else
            echo '{"active_chains": {}, "completed_chains": {}}'
          fi
        }
        
        save_command_history() {
          local history="$1"
          echo "$history" > "$COMMAND_HISTORY_FILE"
        }
        
        save_context() {
          local context="$1"
          echo "$context" > "$CONTEXT_FILE"
        }
        
        save_chains() {
          local chains="$1"
          echo "$chains" > "$CHAIN_FILE"
        }
        
        # 🦆 says ⮞ record a command execution
        record_command() {
          local script_name="$1"
          local args="$2"
          local matched_sentence="$3"
          local match_type="$4"  # exact|fuzzy
          local timestamp=$(date -Iseconds)
          
          local history=$(load_command_history)
          local recent_commands=$(echo "$history" | jq -r '.recent_commands')
          
          # 🦆 says ⮞ Add new command to history (keep last 10)
          local new_command=$(jq -n \
            --arg script "$script_name" \
            --arg args "$args" \
            --arg sentence "$matched_sentence" \
            --arg match_type "$match_type" \
            --arg timestamp "$timestamp" \
            '{
              script: $script,
              args: $args,
              matched_sentence: $sentence, 
              match_type: $match_type,
              timestamp: $timestamp,
              confirmed: false
            }')
          
          history=$(echo "$history" | jq \
            --argjson new_command "$new_command" \
            '.recent_commands = [$new_command] + .recent_commands | .recent_commands = .recent_commands[0:10]')
          
          save_command_history "$history"
          
          # 🦆 says ⮞ update context
          update_context "$script_name" "$args" "$matched_sentence"
        }
        
        # 🦆 says ⮞ update contextual awareness
        update_context() {
          local script_name="$1"
          local args="$2" 
          local sentence="$3"
          
          local context=$(load_context)
          
          # 🦆 says ⮞ upd last action
          context=$(echo "$context" | jq --arg action "$script_name" '.last_action = $action')
          
          # 🦆 says ⮞ detect and update active servers
          if echo "$args" | grep -q "dads"; then
            context=$(echo "$context" | jq '.active_servers = ["dads_media_server"]')
          fi
          if echo "$args" | grep -q "moms"; then
            context=$(echo "$context" | jq '.active_servers = ["moms_media_server"]') 
          fi
          
          # 🦆 says ⮞ detect environment changes
          if [[ "$script_name" == "deploy" ]]; then
            context=$(echo "$context" | jq '.environment = "deployment"')
          fi
          
          save_context "$context"
        }
        
        # 🦆 says ⮞ confirm a match was good (manual training)
        confirm_good_match() {
          local history=$(load_command_history)
          local last_command=$(echo "$history" | jq -r '.recent_commands[0] // empty')
          
          if [ -z "$last_command" ]; then
            echo "🦆 No recent command to confirm!"
            return 1
          fi
          
          local script_name=$(echo "$last_command" | jq -r '.script')
          local sentence=$(echo "$last_command" | jq -r '.matched_sentence')
          local match_type=$(echo "$last_command" | jq -r '.match_type')
          
          # 🦆 says ⮞ Mark as confirmed in history
          history=$(echo "$history" | jq '.recent_commands[0].confirmed = true')
          
          # 🦆 says ⮞ upd confirmed matches stats
          local confirmed_key="$script_name:$sentence"
          local current_count=$(echo "$history" | jq -r ".confirmed_matches.\"$confirmed_key\" // 0")
          history=$(echo "$history" | jq ".confirmed_matches.\"$confirmed_key\" = $((current_count + 1))")
          
          save_command_history "$history"
          
          dt_info "🦆 Confirmed good match: $sentence → $script_name"
          dt_info "   Match type: $match_type"
          dt_info "   Total confirmations for this pattern: $((current_count + 1))"
        }
        
        # 🦆 says ⮞ show recent commands with context
        show_recent() {
          local history=$(load_command_history)
          local context=$(load_context)
          
          echo "🦆 Recent Commands (with context):"
          echo ""
          
          echo "$history" | jq -r '.recent_commands[]? | "\(.timestamp) | \(.script) | \(.match_type) | \(if .confirmed then "✅" else "❓" end) | \(.matched_sentence)"' | \
          while IFS="|" read timestamp script match_type confirmed sentence; do
            echo "  $timestamp"
            echo "  Script: $script ($match_type) $confirmed"
            echo "  Pattern: $sentence"
            echo ""
          done
          
          echo "🦆 Current Context:"
          echo "$context" | jq -r '
            "  Last Action: \(.last_action)",
            "  Active Servers: \(.active_servers | join(", "))", 
            "  Environment: \(.environment)"
          '
        }
        
        # 🦆 says ⮞ show command chains (multi-part commands)
        show_chains() {
          local chains=$(load_chains)
          local context=$(load_context)
          
          echo "🦆 Command Chains & Context:"
          echo ""
          
          echo "Active Chains:"
          echo "$chains" | jq -r '.active_chains | to_entries[] | "  \(.key): \(.value | length) steps"'
          
          echo ""
          echo "Current Context:"
          echo "  Last Action: $(echo "$context" | jq -r '.last_action')"
          echo "  Active Servers: $(echo "$context" | jq -r '.active_servers | join(", ")')"
          echo "  Environment: $(echo "$context" | jq -r '.environment')"
          
          echo ""
          echo "Recent Pattern Success Rate:"
          local history=$(load_command_history)
          local total_commands=$(echo "$history" | jq -r '.recent_commands | length')
          local confirmed_commands=$(echo "$history" | jq -r '[.recent_commands[] | select(.confirmed)] | length')
          
          if [ "$total_commands" -gt 0 ]; then
            local success_rate=$((confirmed_commands * 100 / total_commands))
            echo "  $confirmed_commands/$total_commands confirmed ($success_rate% success rate)"
          else
            echo "  No recent commands"
          fi
        }
        
        # 🦆 says ⮞ statistics with context
        show_enhanced_summary() {
          local stats=$(load_stats)
          local history=$(load_command_history)
          local context=$(load_context)
          
          local total_failed=$(echo "$stats" | jq '.failed_commands | length')
          local total_success=$(echo "$stats" | jq '.successful_commands | length')
          local total_fuzzy=$(echo "$stats" | jq '.fuzzy_matches | length')
          
          local failed_count=$(echo "$stats" | jq '[.failed_commands[]] | add // 0')
          local success_count=$(echo "$stats" | jq '[.successful_commands[]] | add // 0')
          local fuzzy_count=$(echo "$stats" | jq '[.fuzzy_matches[]] | add // 0')
          
          local recent_commands=$(echo "$history" | jq -r '.recent_commands | length')
          local confirmed_patterns=$(echo "$history" | jq -r '.confirmed_matches | length')
          
          cat << EOF
    [🦆📶] Command Statistics:
      Total Failed Commands: $failed_count ($total_failed unique)
      Total Successful: $success_count ($total_success unique)  
      Total Fuzzy Matches: $fuzzy_count ($total_fuzzy unique)
      Success Rate: $(if [ $((success_count + failed_count)) -gt 0 ]; then echo "scale=2; $success_count * 100 / ($success_count + $failed_count)" | bc; else echo "0"; fi)%
    
    [🦆📶] Context & Learning:
      Recent Commands: $recent_commands
      Confirmed Patterns: $confirmed_patterns
      Last Action: $(echo "$context" | jq -r '.last_action')
      Active Environment: $(echo "$context" | jq -r '.environment')
    
    [🦆📶] Most Confirmed Patterns:
    $(echo "$history" | jq -r '.confirmed_matches | to_entries | sort_by(-.value) | .[0:5] | .[] | "  \(.key): \(.value) confirmations"')
    EOF
        }
        
        # 🦆 says ⮞ stats functions
        load_stats() {
          if [ -f "${commandStatsDB}" ]; then
            cat "${commandStatsDB}"
          else
            echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}'
          fi
        }
        
        save_stats() {
          local stats="$1"
          echo "$stats" > "${commandStatsDB}"
        }
        
        show_failed() {
          local stats=$(load_stats)
          echo "🦆 Most Frequently Failed Commands:"
          echo "$stats" | jq -r '.failed_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) failures"' | head -20
        }
        
        show_successful() {
          local stats=$(load_stats)
          echo "🦆 Most Used Successful Commands:"
          echo "$stats" | jq -r '.successful_commands | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) successes"' | head -20
        }
        
        reset_memory() {
          echo '{"failed_commands": {}, "successful_commands": {}, "fuzzy_matches": {}}' > "${commandStatsDB}"
          echo '{"recent_commands": [], "confirmed_matches": {}}' > "$COMMAND_HISTORY_FILE"
          echo '{"last_action": "", "active_servers": [], "environment": "default"}' > "$CONTEXT_FILE"
          echo "[🦆📶] All memory and statistics reset!"
        }
        
        forget_recent() {
          echo '{"recent_commands": [], "confirmed_matches": {}}' > "$COMMAND_HISTORY_FILE"
          echo "[🦆📶] Recent command history cleared!"
        }
        
        # 🦆 says ⮞ Main logic
        if [[ "$reset" == "true" ]]; then
          reset_memory
          exit 0
        fi
        
        if [[ "$forget" == "true" ]]; then
          forget_recent
          exit 0
        fi
        
        if [[ "$good" == "true" ]]; then
          confirm_good_match
          exit 0
        fi
        
        case "$show" in
          failed) show_failed ;;
          successful) show_successful ;;
          summary) show_enhanced_summary ;;
          fuzzy) show_fuzzy ;;
          recent) show_recent ;;
          context|chain) show_chains ;;
          *) show_enhanced_summary ;;
        esac
      '';

    };
    
  };}    
