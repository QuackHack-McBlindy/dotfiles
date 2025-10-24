
// Function to load and display channels
function loadChannels() {
    fetch('/api/channels')
    .then(response => response.json())
    .then(data => {
        const itemList = document.getElementById('itemList');
        itemList.innerHTML = '';  // Clear the current list

        // Sort channels by id before displaying
        data.sort((a, b) => a.id - b.id);

        data.forEach(channel => {
            const listItem = document.createElement('li');
            listItem.classList.add('list-item');

            // Create img element for icon
            const img = document.createElement('img');
            if (channel.icon_url) {
                img.src = channel.icon_url;
                img.alt = channel.name;
            } else {
                img.alt = channel.name;
                img.style.display = 'none'; // Hide img if no icon
            }

            // Create span element for the name (fallback if no icon)
            const nameSpan = document.createElement('span');
            nameSpan.textContent = channel.name;

            // Add a hidden element to store the URL for later use
            const urlSpan = document.createElement('span');
            urlSpan.textContent = channel.url;
            urlSpan.classList.add('hidden'); // Hide the URL

            // Append elements to list item
            listItem.appendChild(img);
            listItem.appendChild(nameSpan);
            listItem.appendChild(urlSpan); // Store the URL

            // Add the list item to the item list
            itemList.appendChild(listItem);
        });
    })
    .catch(error => console.error('Error loading channels:', error));
}

// Call the function to load channels when the page loads
window.onload = loadChannels;
