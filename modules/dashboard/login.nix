# dotfiles/modules/dashboard/login.nix.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
{ # 🦆 says ⮞ auto generate smart home dashboard
  lib,
  pkgs,
  ...
}: let 
  # 🦆 says ⮞ LOGIN/AUTHENTICATION PAGE  
  loginHtml = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
    body {
      margin: 0;
      height: 100vh;
      overflow: hidden;
      display: flex;
      justify-content: center;
      align-items: center;
      font-family: monospace;
      background: black;
      position: relative;
    }
    
    .emoji {
      position: absolute;
      top: -50px;
      font-size: 2rem;
      animation: fall linear infinite;
    }
    
    .duck { font-size: 3rem; }
    
    .heart {
      font-size: 2rem;
      transition: transform 0.3s ease;
    }
    
    .heart:hover {
      transform: scale(2);
      opacity: 0;
    }
    
    @keyframes fall {
      to { transform: translateY(100vh); }
    }
    
    #beginButton {
      font-size: 2rem;
      padding: 12px 40px;
      background: linear-gradient(45deg, #00ff00, #00ccff, #ff00ff);
      background-size: 300% 300%;
      color: black;
      border: 2px solid #00FF00;
      border-radius: 12px;
      cursor: pointer;
      z-index: 300;
      animation: gradientAnimation 3s ease infinite, fadeIn 2s forwards;
      box-shadow: 0 0 20px #00ff00, 0 0 40px #00ff00, 0 0 60px #00ff00;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    #beginButton:hover {
      transform: scale(1.2) rotate(-5deg);
      box-shadow: 0 0 40px #00ff00, 0 0 80px #00ff00, 0 0 120px #00ff00;
    }
    
    @keyframes gradientAnimation {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }
    
    
    @keyframes fadeIn {
      to { opacity: 1; }
    }
    
    @keyframes flyAway {
      to {
        transform: translate(var(--x), var(--y)) scale(1.5) rotate(720deg);
        opacity: 0;
      }
    }
    
    #matrixScreen {
      display: none;
      position: fixed;
      inset: 0;
      background: black;
      color: #00ff00;
      font-size: 2rem;
      padding: 2rem;
      overflow: hidden;
      opacity: 0;
      transition: opacity 2s ease;
    }
    
    #matrixScreen.show {
      display: block;
      opacity: 1;
    }
    
    .cursor {
      animation: blink 1s infinite;
    }
    
    @keyframes blink {
      50% { opacity: 0; }
    }
    
    #loginPage {
      display: none;
      position: fixed;
      inset: 0;
      background: black;
      color: #00FF00;
      font-family: "Courier New", monospace;
      justify-content: center;
      align-items: center;
      opacity: 0;
      transition: opacity 2s ease;
    }
    
    #loginPage.show {
      display: flex;
      opacity: 1;
    }
    
    .login-container {
      border: 2px solid #00FF00;
      padding: 20px;
      width: 300px;
      text-align: center;
    }
    
    .login-container h1 {
      font-size: 24px;
      margin-bottom: 20px;
    }
    
    .login-container input {
      background-color: black;
      border: 2px solid #00FF00;
      color: #00FF00;
      padding: 10px;
      width: 80%;
      margin: 10px;
      font-size: 16px;
      text-align: center;
    }
    
    .login-container input[type="submit"] {
      cursor: pointer;
      background-color: #00FF00;
      color: black;
      border: none;
      transition: all 0.3s ease;
    }
    
    .login-container input[type="submit"]:hover {
      background-color: #00CC00;
    }
    
    .message {
      font-size: 14px;
      margin-top: 20px;
      color: #FF4500;
    }
    
    .message a {
      color: #00FF00;
      text-decoration: none;
    }
    </style>
    </head>
    
    <body>
    
    <button id="beginButton">Login!</button>
    
    <div id="matrixScreen">
      <div id="matrixText"></div>
    </div>
    
    <div id="loginPage">
      <div class="login-container">
        <h1>Enter the System</h1>
        <form action="/submit" method="POST">
          <input type="password" name="password" placeholder="Password" required>
          <input type="submit" value="Log In">
        </form>
        <div class="message">
          <p>Warning: Unauthorized access will be logged and <strong>punished</strong> accordingly!</p>
        </div>
      </div>
    </div>
    
    <script>
    const emojis = ['🦆','🦆','🦆','🦆','❤️'];
        
    for (let i = 0; i < 200; i++) {
      const e = document.createElement('div');
      e.classList.add('emoji');    
      const type = emojis[Math.floor(Math.random() * emojis.length)];
      e.innerText = type;
    
      if (type === '🦆') e.classList.add('duck');
      else e.classList.add('heart');
    
      e.style.left = Math.random() * 100 + 'vw';
      e.style.animationDuration = Math.random() * 3 + 5 + 's';
      e.style.animationDelay = Math.random() * 5 + 's';    
      document.body.appendChild(e);
    }
    
    document.getElementById('beginButton').addEventListener('click', function () {
      const emojis = document.querySelectorAll('.emoji');    
      emojis.forEach(e => {
        const x = (Math.random() - 0.5) * 2000;
        const y = (Math.random() - 0.5) * 2000;
        e.style.setProperty('--x', `''${x}px`);
        e.style.setProperty('--y', `''${y}px`);
        e.style.animation = 'flyAway 1.5s forwards';
      });
    
      this.style.display = 'none';
    
      setTimeout(() => {
        const matrix = document.getElementById('matrixScreen');
        matrix.classList.add('show');
        startMatrix();
      }, 1500);
    });
    
    function startMatrix() {
      const matrixText = document.getElementById('matrixText');    
      const lines = [
        '> enter authentication...',
      ];
    
      let i = 0;
      let j = 0;
    
      function type() {
        if (i >= lines.length) {
          setTimeout(fadeToLogin, 1500);
          return;
        }
    
        matrixText.innerHTML += lines[i][j] + '<span class="cursor">█</span>';
        j++;
        if (j === lines[i].length) {
          matrixText.innerHTML += '<br>';
          i++;
          j = 0;
        }
        setTimeout(type, 30);
      }    
      type();
    }
    
    function fadeToLogin() {
      const matrix = document.getElementById('matrixScreen');
      const login = document.getElementById('loginPage');
      matrix.style.opacity = 0;
      setTimeout(() => {
        matrix.style.display = 'none';
        login.style.display = 'flex';
    
        setTimeout(() => {
          login.classList.add('show');
        }, 50);
    
      }, 2000);
    }
    </script>    
    </body>
    </html>      
  '';


  # 🦆 says ⮞ letz convert the website into an iOS application (Open Safari & Save bookmark to homescreen) 
  iOSmanifest = pkgs.writeText "manifest.json" ''
    {
      "name": "🦆'Dash",
      "short_name": "🦆",
      "start_url": "/index.html",
      "display": "standalone",
      "background_color": "#ffffff",
      "theme_color": "#ffffff",
      "icons": [
        {
          "src": "/android-chrome-192x192.png",
          "sizes": "192x192",
          "type": "image/png"
        },
        {
          "src": "/android-chrome-512x512.png",
          "sizes": "512x512",
          "type": "image/png"
        }
      ]
    }
  '';
  

in {
  loginHtml = loginHtml;
  iOSmanifest = iOSmanifest;
}
