document.getElementById("search-input").addEventListener("keypress", function(event) {
    if (event.key === "Enter") {
        event.preventDefault();
        const query = event.target.value;

        // Send the input to the server
        fetch("/search", {
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

