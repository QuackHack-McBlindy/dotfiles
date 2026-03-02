# dotfiles/bin/productivity/sns.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ encrypted message history
  self,
  config,
  pkgs,
  cmdHelpers,
  ...
} : let

in {

  yo.scripts = { # 🦆 says ⮞ quack quack quack quack quack.... qwack 
    sms = { # 🦆 says ⮞ wat? BASH?! quack - just bcause duck can! crazy huh?! 
      description = "Stores message history in a clean SMS chat interface and encrypts it";
      category = "⚡ Productivity";
      logLevel = "DEBUG";
      autoStart = false;
      parameters = [
        { name = "text"; type = "string"; description = "Message text recieved/sent"; optional = false; }
        { name = "from"; type = "string"; description = "The senders phone number"; optional = false; }
        { name = "to"; type = "string"; description = "Recievers phone number"; optional = false; }
        { name = "time"; type = "string"; description = "ISO timestamp"; }
        { name = "encrypt"; type = "bool"; description = "Encrypt the conversation after adding the new message"; default = false; }

      ]; 
      code = ''
        ${cmdHelpers}
        TIMESTAMP="$timo"
        FROM="$from"
        TO="$to"
        MESSAGE="$text"
        ENCRYPT=$encrypt

        if [[ -z "$TIMESTAMP" ]]; then
            TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        fi
        
        SMS_ROOT="$HOME/.sms_history"
        MASTER_KEY_FILE="$SMS_ROOT/.master_key"
        INDEX_FILE="$SMS_ROOT/conversations.json"
        
        mkdir -p "$SMS_ROOT"
        
        if [[ "$FROM" < "$TO" ]]; then
            CONVERSATION_ID="''${FROM}_''${TO}"
        else
            CONVERSATION_ID="''${TO}_''${FROM}"
        fi
        
        CONV_DIR="$SMS_ROOT/$CONVERSATION_ID"
        CONV_FILE="$CONV_DIR/conversation.json"
        CONV_HTML="$CONV_DIR/chat.html"

        mkdir -p "$CONV_DIR"
        
        if [[ ! -f "$MASTER_KEY_FILE" ]]; then
            openssl rand -base64 32 > "$MASTER_KEY_FILE"
            chmod 600 "$MASTER_KEY_FILE"
        fi
        
        generate_conversation_key() {
            local conv_id="$1"
            local master_key=$(cat "$MASTER_KEY_FILE")
            echo -n "''${master_key}''${conv_id}" | sha256sum | cut -d' ' -f1
        }
        
 
        update_conversation_index() {
            local participants="$1"
            local last_message="$2"
            
            if [[ ! -f "$INDEX_FILE" ]]; then
                echo '{"conversations": {}}' > "$INDEX_FILE"
            fi
            

            jq --arg id "$CONVERSATION_ID" \
               --arg from "$FROM" \
               --arg to "$TO" \
               --arg time "$TIMESTAMP" \
               --arg preview "$(echo "$MESSAGE" | cut -c1-50)" \
               '
               .conversations[$id] = {
                 "participants": [$from, $to],
                 "last_message": $preview,
                 "last_updated": $time,
                 "message_count": ((.conversations[$id].message_count // 0) + 1),
               }
               ' "$INDEX_FILE" > "''${INDEX_FILE}.tmp" && mv "''${INDEX_FILE}.tmp" "$INDEX_FILE"
        }
        
        add_message() {
            local direction="received"
            
            if [[ "$FROM" =~ ^(4673|4670|\+4673|\+4670) ]]; then
                direction="sent"
            fi
            
            local message_entry=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "from": "$FROM",
  "to": "$TO",
  "message": "$MESSAGE",
  "direction": "$direction"
}
EOF
            )
            
            if [[ -f "$ENCRYPTED_FILE" ]]; then

                if [[ $? -eq 0 ]]; then
                    if [[ -s "$CONV_FILE.tmp" ]]; then
                        jq --argjson new "$message_entry" '.messages += [$new]' "$CONV_FILE.tmp" > "$CONV_FILE"
                    else
                        echo '{"messages": []}' | jq --argjson new "$message_entry" '.messages += [$new]' > "$CONV_FILE"
                    fi
                    rm -f "$CONV_FILE.tmp"
                    
   
                else
                    echo "Warning: Failed to decrypt existing conversation, creating new"
                    create_new_conversation
                fi
            elif [[ -f "$CONV_FILE" ]]; then
                # Plaintext exists, append to it
                jq --argjson new "$message_entry" '.messages += [$new]' "$CONV_FILE" > "''${CONV_FILE}.tmp"
                mv "''${CONV_FILE}.tmp" "$CONV_FILE"
                
                # Encrypt if requested
                if [[ "$ENCRYPT" == "true" ]]; then
                    encrypt_file "$CONV_FILE" "$ENCRYPTED_FILE"
                fi
            else
                # New conversation
                create_new_conversation
            fi
        }
        
        create_new_conversation() {
            cat > "$CONV_FILE" <<EOF
{
  "metadata": {
  "participants": ["$FROM", "$TO"],
  "created": "$TIMESTAMP",            "encrypted": $ENCRYPT
},
  "messages": [
    {
      "timestamp": "$TIMESTAMP",
      "from": "$FROM",
      "to": "$TO",
      "message": "$MESSAGE",
      "direction": "$(if [[ "$FROM" =~ ^(4673|4670|\+4673|\+4670) ]]; then echo "sent"; else echo "received"; fi)"
    }
  ]
}
EOF
            

        }
        
        generate_html() {
          cat > "$CONV_HTML" << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🦆 SMS Chat</title>
    <style>
        :root {
            --duck-yellow: #ffd700;
            --duck-orange: #ffa500;
            --sent-color: #0084ff;
            --received-color: #e4e6eb;
            --text-dark: #2c3e50;
            --text-light: #ffffff;
            --shadow: rgba(0,0,0,0.1);
        }
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px var(--shadow);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: white;
            text-align: center;
        }
        
        .header h1 {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-size: 24px;
        }
        
        .messages {
            height: 70vh;
            overflow-y: auto;
            padding: 20px;
            background: #f0f2f5;
        }
        
        .message {
            margin-bottom: 15px;
            display: flex;
            animation: slideIn 0.3s ease-out;
        }
        
        .message.sent {
            justify-content: flex-end;
        }
        
        .message.received {
            justify-content: flex-start;
        }
        
        .bubble {
            max-width: 70%;
            padding: 12px 16px;
            border-radius: 18px;
            position: relative;
            word-wrap: break-word;
            box-shadow: 0 2px 8px var(--shadow);
        }
        
        .sent .bubble {
            background: var(--sent-color);
            color: var(--text-light);
            border-bottom-right-radius: 4px;
        }
        
        .received .bubble {
            background: var(--received-color);
            color: var(--text-dark);
            border-bottom-left-radius: 4px;
        }
        
        .message-info {
            display: flex;
            justify-content: space-between;
            margin-top: 5px;
            font-size: 11px;
            opacity: 0.8;
        }
        
        .date-separator {
            text-align: center;
            margin: 20px 0;
            position: relative;
        }
        
        .date-separator span {
            background: white;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 12px;
            color: #666;
            border: 1px solid #eee;
        }
        
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🦆 SMS Chat</h1>
            <p id="conversationInfo">Loading conversation...</p>
        </div>
        <div class="messages" id="messages">
            <div style="text-align: center; padding: 40px; color: #666;">
                Loading messages...
            </div>
        </div>
    </div>
    
    <script>
        function formatPhone(phone) {
            if (phone.startsWith('467')) {
                return '+46 ' + phone.slice(3,5) + ' ' + phone.slice(5,8) + ' ' + phone.slice(8);
            }
            return phone;
        }
        
        function formatDate(timestamp) {
            const date = new Date(timestamp);
            const now = new Date();
            const diffDays = Math.floor((now - date) / (1000 * 60 * 60 * 24));
            
            if (diffDays === 0) return 'Today';
            if (diffDays === 1) return 'Yesterday';
            if (diffDays < 7) return date.toLocaleDateString('en-US', { weekday: 'long' });
            
            return date.toLocaleDateString('en-US', { 
                month: 'short', 
                day: 'numeric',
                year: diffDays > 365 ? 'numeric' : undefined
            });
        }
        
        async function loadConversation() {
            try {
                const response = await fetch('conversation.json');
                const data = await response.json();
                
                // Update header
                document.getElementById('conversationInfo').textContent = 
                    `''${formatPhone(data.metadata.participants[0])} ↔ ''${formatPhone(data.metadata.participants[1])}`;
                
                // Group messages by date
                const messagesByDate = {};
                data.messages.forEach(msg => {
                    const date = formatDate(msg.timestamp);
                    if (!messagesByDate[date]) messagesByDate[date] = [];
                    messagesByDate[date].push(msg);
                });
                

                const container = document.getElementById('messages');
                container.innerHTML = "";
                
                Object.entries(messagesByDate).forEach(([date, msgs]) => {

                    const dateDiv = document.createElement('div');
                    dateDiv.className = 'date-separator';
                    dateDiv.innerHTML = `<span>''${date}</span>`;
                    container.appendChild(dateDiv);
                    
                    // Add messages for this date
                    msgs.forEach(msg => {
                        const msgDiv = document.createElement('div');
                        msgDiv.className = `message ''${msg.direction}`;
                        
                        const bubble = document.createElement('div');
                        bubble.className = 'bubble';
                        
                        const text = document.createElement('div');
                        text.textContent = msg.message;
                        
                        const info = document.createElement('div');
                        info.className = 'message-info';
                        info.innerHTML = `
                            <span>''${formatPhone(msg.direction === 'sent' ? msg.to : msg.from)}</span>
                            <span>''${new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</span>
                        `;
                        
                        bubble.appendChild(text);
                        bubble.appendChild(info);
                        msgDiv.appendChild(bubble);
                        container.appendChild(msgDiv);
                    });
                });
                
                // Scroll to bottom
                container.scrollTop = container.scrollHeight;
                
            } catch (error) {
                document.getElementById('messages').innerHTML = `
                    <div style="text-align: center; padding: 40px; color: #e74c3c;">
                        Error loading conversation: ''${error.message}<br>
                        Make sure conversation.json exists in this directory.
                    </div>
                `;
            }
        }
        
        document.addEventListener('DOMContentLoaded', loadConversation);
    </script>
</body>
</html>
HTML
        }
        
        echo "📱 Storing message from $FROM to $TO"
        add_message
        update_conversation_index "$CONVERSATION_ID" "$MESSAGE"
        generate_html
        
        echo "✅ Message stored successfully!"
        echo "📂 Conversation directory: $CONV_DIR"
        echo "🌐 Open in browser: file://$CONV_HTML"
        
      '';
    };
  
  };}
