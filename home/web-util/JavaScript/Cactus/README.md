# **Cactus**

This is the compiled JavaScript bundle for **[Cactus Comments](https://cactus.chat/)**, an open‑source, privacy‑focused comment system built on top of the Matrix protocol.

Instead of relying on a centralised proprietary server, it uses Matrix (a decentralised, encrypted chat protocol) to store and sync comments. You own your data, users can comment using their existing Matrix accounts (or as guests), and everything can be end‑to‑end encrypted.


## **How to use it**

Embed it into any static HTML page. There are **two ways** to initialise it:

### Method 1 – Auto‑initialisation via HTML attributes (easiest)

Place the script on your page with `data-` attributes. The script automatically mounts itself where the `<script>` tag sits.

```html
<!-- optional container (if you want to control placement) -->
<div id="cactus-comments"></div>

<!-- load the script with configuration -->
<script
  src="/path/to/cactus.js"
  data-default-homeserver-url="https://matrix.cactus.chat"
  data-comment-section-id="my-awesome-blog-post"
  data-site-name="My Blog"
  data-login-enabled="true"
  data-guest-posting-enabled="true"
  data-page-size="20"
  data-update-interval="30">
</script>
```

Note: If you omit data-node, it renders exactly where the <script> tag is. To render into a specific <div>, use the manual method below.

Method 2 – Manual initialisation via window.initComments
The script exposes a global function window.initComments(config).

```html
<div id="my-comment-section"></div>

<script src="/path/to/cactus.js"></script>
<script>
  window.initComments({
    // Required: DOM element or CSS selector string
    node: document.getElementById('my-comment-section'),

    // Required: unique ID for this page/article – no spaces or underscores
    commentSectionId: 'my-awesome-blog-post',

    // Optional: Matrix homeserver URL
    defaultHomeserverUrl: 'https://matrix.cactus.chat',

    // Optional: display name for your site
    siteName: 'My Blog',

    // Optional: server name part of the user ID (auto‑detected if omitted)
    serverName: 'example.com',

    // Optional: allow guest (anonymous) posting
    guestPostingEnabled: true,

    // Optional: show the login button
    loginEnabled: true,

    // Optional: comments per page
    pageSize: 20,

    // Optional: polling interval in seconds
    updateInterval: 30
  });
</script>
```

Configuration flags
Flag	Type	Description
node	Element or string	Required. DOM element or CSS selector (e.g. "#comments").
commentSectionId	string	Required. Unique ID for this page – no spaces or underscores.
defaultHomeserverUrl	string	Matrix homeserver URL (e.g. https://matrix.cactus.chat).
siteName	string	Your site’s display name.
serverName	string	Server name part of Matrix IDs (usually auto‑detected).
guestPostingEnabled	boolean	If true, users can post without logging in.
loginEnabled	boolean	If true, shows a “Log in” button for Matrix users.
pageSize	number	Number of comments per batch.
updateInterval	number	Polling interval in seconds.
storedSession	object	Handled automatically – the script saves the user session to localStorage under cactus-session.
How it works under the hood
State management – built with the Elm framework (compiled to JavaScript).

Persistence – reads localStorage for cactus-session to restore logged‑in users across reloads.

Live updates – polls the Matrix server (using the Client‑Server API) for new events in the comment room.

Communication – sends comments as m.room.message events to a Matrix room dedicated to your commentSectionId.
