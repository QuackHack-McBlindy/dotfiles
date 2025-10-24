// Variables to track visibility
let isChannelListVisible = false;

// Function to load and display channels with now-playing info
function loadChannels() {
    fetch('/api/db/channels')
        .then(response => response.json())
        .then(channels => {
            fetch('/api/epg/now-playing')
                .then(response => response.json())
                .then(epgData => {
                    const nowPlayingMap = new Map();

                    // Use the 'channel' ID from now-playing data to map current shows
                    epgData.now_playing.forEach(show => {
                        nowPlayingMap.set(parseInt(show.channel), show); // Ensure channel is treated as an integer
                    });

                    const itemList = document.getElementById('itemList');
                    itemList.innerHTML = ''; // Clear the current list

                    // Sort channels by id before displaying
                    channels.sort((a, b) => parseInt(a.id) - parseInt(b.id)); // Convert to integers for sorting

                    // Populate list items with icons, names, and now playing info
                    channels.forEach(channel => {
                        const listItem = document.createElement('li');
                        listItem.classList.add('list-item');

                        // Get the now-playing info for the current channel
                        const show = nowPlayingMap.get(parseInt(channel.id)); // Convert channel.id to integer
                        let showText = "Unavailable"; // Default if no data

                        // Progress bar calculation
                        let progressBar = null;
                        if (show) {
                            const startTime = new Date(`1970-01-01T${show.start_time}:00`);
                            const endTime = new Date(`1970-01-01T${show.end_time}:00`);
                            const now = new Date();
                            const elapsed = now - startTime;
                            const duration = endTime - startTime;
                            const progress = Math.min((elapsed / duration) * 100, 100);

                            showText = `${show.start_time} - ${show.end_time} - ${show.title}`;

                            // Create progress bar
                            progressBar = document.createElement('div');
                            progressBar.classList.add('progress-bar');
                            progressBar.style.width = `${progress}%`;
                            progressBar.setAttribute('data-progress', progress); 
                        }

                        // Icon
                        const img = document.createElement('img');
                        if (channel.icon_url) {
                            img.src = channel.icon_url;
                            img.alt = channel.name;
                        } else {
                            img.alt = channel.name;
                            img.style.display = 'none'; // Hide img if no icon
                        }

                        // Channel name (only show if there's no icon)
                        const nameSpan = document.createElement('span');
                        if (!channel.icon_url) {
                            nameSpan.textContent = channel.name;
                        } else {
                            nameSpan.style.display = 'none'; // Hide the name if an icon exists
                        }

                        // Show information (e.g., "START - END - TITLE")
                        const showSpan = document.createElement('span');
                        showSpan.textContent = showText;
                        showSpan.classList.add('show-info'); // For styling

                        // URL (hidden)
                        const urlSpan = document.createElement('span');
                        urlSpan.textContent = channel.url;
                        urlSpan.classList.add('hidden'); // Hide the URL

                        // Append elements to list item
                        listItem.appendChild(img);
                        listItem.appendChild(nameSpan);
                        listItem.appendChild(showSpan);
                        if (progressBar) listItem.appendChild(progressBar); // Append progress bar if available
                        listItem.appendChild(urlSpan); // Store the URL

                        // Add list item to the item list
                        itemList.appendChild(listItem);

                        // Animation for items
                        const delay = Math.min(channels.indexOf(channel) * 500, 12000); // Max animation duration (12s)
                        setTimeout(() => {
                            listItem.classList.add('visible');
                        }, delay);

                        // Event listener for list item click
                        listItem.addEventListener('click', () => {
                            document.querySelectorAll('.list-item').forEach(item => item.classList.remove('selected'));
                            listItem.classList.add('selected');
                            playChannel(channel.url); // Call a function to play the channel
                        });
                    });

                    itemList.classList.remove('hidden');
                    itemList.classList.add('visible');
                    isChannelListVisible = true;
                })
                .catch(error => console.error('Error loading now playing info:', error));
        })
        .catch(error => console.error('Error loading channels:', error));
}

// Toggle channel list visibility
function toggleChannelList() {
    const itemList = document.getElementById('itemList');
    if (isChannelListVisible) {
        closeListWithAnimation(itemList, '.list-item', () => {
            isChannelListVisible = false;
        });
    } else {
        loadChannels();
    }
}

// Function to close the list with animations
function closeListWithAnimation(listElement, itemClass, callback) {
    const items = listElement.querySelectorAll(itemClass);
    items.forEach((item, index) => {
        const delay = Math.min((items.length - index - 1) * 500, 12000);
        setTimeout(() => {
            item.classList.remove('visible');
        }, delay);
    });
    setTimeout(() => {
        listElement.classList.remove('visible');
        listElement.classList.add('hidden');
        listElement.innerHTML = ''; // Clear list when hidden
        if (callback) callback();
    }, Math.min(items.length * 500, 12000));
}

// Function to play a channel based on its URL
function playChannel(url) {
    console.log(`Playing channel from URL: ${url}`);

    fetch('/api/adb/watch', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ url: url })
    })
    .then(response => {
        if (response.ok) {
            console.log('Channel URL sent successfully');
        } else {
            console.error('Failed to send channel URL');
        }
    })
    .catch(error => console.error('Error:', error));
}


// Call toggle function on button click
document.getElementById('remoteButton').addEventListener('click', toggleChannelList);
