// Play/Pause functionality with spacebar, excluding when typing in search
document.addEventListener("keydown", (event) => {
    const searchInput = document.getElementById("search-input");

    if (event.code === "Space" && document.activeElement !== searchInput) {
        event.preventDefault(); // Prevent default behavior (like scrolling)
        playPauseButton.click(); // Trigger the play/pause toggle
    }
});

// Search functionality with Enter key
document.getElementById("search-input").addEventListener("keypress", function(event) {
    if (event.key === "Enter") {
        event.preventDefault();
        const query = event.target.value;

        // Send the input to the server
        fetch("/api/search", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ query: query })
        })
        .then(response => response.json())
        .then(data => {
            console.log("Command executed:", data);
        })
        .catch(error => console.error("Error:", error));
    }
});
