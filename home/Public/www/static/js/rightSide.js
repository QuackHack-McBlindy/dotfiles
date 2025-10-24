// Shared Variables
const musicButton = document.getElementById('musicButton');
const tvButton = document.getElementById('tvButton');
const movieButton = document.getElementById('movieButton');

const musicList = document.getElementById('musicList');
const tvList = document.getElementById('tvList');
const movieList = document.getElementById('movieList');

let isMusicVisible = false;
let isTVVisible = false;
let isMovieVisible = false;
let longPressTimeout; // For detecting hold down event

// ---- Music Button Logic ----
musicButton.addEventListener('click', () => {
    if (isMusicVisible) {
        closeMusicList();
    } else {
        hideAllLists(() => {
            fetchMusicDirectories();
        });
    }
});

// ---- TV Shows Button Logic ----
tvButton.addEventListener('click', () => {
    if (isTVVisible) {
        closeTVList();
    } else {
        hideAllLists(() => {
            fetchTVDirectories(); 
        });
    }
});

// ---- Movie Button Logic ----
movieButton.addEventListener('click', () => {
    if (isMovieVisible) {
        closeMovieList();
    } else {
        hideAllLists(() => {
            fetchMovieDirectories(); 
        });
    }
});

// Function to fetch music directories and files
function fetchMusicDirectories() {
    fetch(`/list-music-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, musicList);
            isMusicVisible = true;
        })
        .catch(error => console.error('Error fetching music directories:', error));
}

// Function to fetch TV directories and files
function fetchTVDirectories() {
    fetch(`/list-shows-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, tvList);
            isTVVisible = true;
        })
        .catch(error => console.error('Error fetching TV directories:', error));
}

// Function to fetch contents of a movie directory (used in double click event)
function fetchMovieDirectoryContents(directory) {
    // Fetch the directory content from the backend
    fetch(`/list-directory/movies/${encodeURIComponent(directory)}`)
        .then(response => response.json())
        .then(data => {
            // Replace the content of the movie list with new directory content
            displayItems(data, movieList); // Reuse the same list container
        })
        .catch(error => console.error('Error navigating to directory:', error));
}



// Function to fetch movie directories and files
function fetchMovieDirectories() {
    fetch(`/list-movie-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, movieList);
            isMovieVisible = true;
        })
        .catch(error => console.error('Error fetching movie directories:', error));
}

// Function to display items (directories and files) with icons based on type
function displayItems(data, listElement) {
    listElement.innerHTML = ''; 

    // Display directories with 📁 icon
    data.directories.forEach(directory => {
        const listItem = document.createElement('li');
        listItem.textContent = `📁 ${directory}`;
        listItem.classList.add('directory');
        listItem.dataset.path = directory; // Store directory path in dataset for easy access
        addItemEventListeners(listItem);
        listElement.appendChild(listItem);
    });

    // Display files with appropriate icons based on file extension
    data.files.forEach(file => {
        const listItem = document.createElement('li');
        const icon = getIconForFile(file); // Get the correct icon based on file type
        listItem.textContent = `${icon} ${file}`;
        listItem.classList.add('file');
        listItem.dataset.path = file; // Store file path in dataset
        addItemEventListeners(listItem);
        listElement.appendChild(listItem);
    });

    listElement.classList.remove('hidden');
    listElement.classList.add('visible');
}

// Function to return appropriate icon based on file type
function getIconForFile(fileName) {
    const extension = fileName.split('.').pop().toLowerCase(); // Get file extension

    // Determine icon based on file extension
    switch (extension) {
        case 'mp3':
        case 'wav':
        case 'flac':
            return '🎧'; // Music files
        case 'mp4':
        case 'mkv':
        case 'avi':
            return '📽️'; // Movie files
        default:
            return '📄'; // Generic file icon for other types
    }
}

// Function to add event listeners to a list item (click, double click, and hold down)
function addItemEventListeners(listItem) {
    // Click event to mark the item as selected
    listItem.addEventListener('click', () => {
        document.querySelectorAll('li').forEach(item => item.classList.remove('selected')); // Unmark other items
        listItem.classList.add('selected'); // Mark this item
    });

    // Double click event for directories to navigate into them
    if (listItem.classList.contains('directory')) {
        listItem.addEventListener('dblclick', () => {
            fetchDirectoryContents(listItem.dataset.path); // Fetch new directory contents
        });
    }

    // Hold down event for both directories and files to send them to the playlist
    listItem.addEventListener('mousedown', () => {
        longPressTimeout = setTimeout(() => {
            let mediaType = '';  // Determine media type based on the visible list

            if (isMusicVisible) {
                mediaType = 'music';
            } else if (isTVVisible) {
                mediaType = 'tv';
            } else if (isMovieVisible) {
                mediaType = 'movies';
            }

            if (listItem.classList.contains('directory')) {
                appendToPlaylist(`/api/playback/append?media_type=${mediaType}`, { directory: listItem.dataset.path, playlist: 'playlist.m3u' });
            } else {
                appendToPlaylist(`/api/playback/append_file?media_type=${mediaType}`, { filepath: listItem.dataset.path, playlist: 'playlist.m3u' });
            }
        }, 1000); // Trigger the hold event after 1 second
    });

    listItem.addEventListener('mouseup', () => {
        clearTimeout(longPressTimeout); // Clear the timeout if mouse is released early
    });
}

// Function to fetch contents of a directory (used in double click event)
// Function to fetch contents of a directory (used in double click event)
function fetchDirectoryContents(directory) {
    let mediaType = '';

    // Determine the current media type based on the visible list
    if (isMusicVisible) {
        mediaType = 'music';
    } else if (isTVVisible) {
        mediaType = 'tv';
    } else if (isMovieVisible) {
        mediaType = 'movies';
    }

    // Fetch the directory content from the backend
    fetch(`/list-directory/${mediaType}/${encodeURIComponent(directory)}`)
        .then(response => response.json())
        .then(data => {
            // Replace the content of the active list with new directory content
            if (isMusicVisible) {
                displayItems(data, musicList); // Reuse the same list container
            } else if (isTVVisible) {
                displayItems(data, tvList); // Reuse the same list container
            } else if (isMovieVisible) {
                displayItems(data, movieList); // Reuse the same list container
            }

            // Ensure the list stays visible in the same position as the previous one
            ensureListPosition();
        })
        .catch(error => console.error('Error navigating to directory:', error));
}

// Function to ensure the list remains visible in the same position
function ensureListPosition() {
    if (isMusicVisible) {
        musicList.classList.remove('hidden');
        musicList.classList.add('visible');
    } else if (isTVVisible) {
        tvList.classList.remove('hidden');
        tvList.classList.add('visible');
    } else if (isMovieVisible) {
        movieList.classList.remove('hidden');
        movieList.classList.add('visible');
    }
}



// Function to append directory or file to the playlist
function appendToPlaylist(url, params) {
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(params),
    })
    .then(response => response.json())
    .then(data => {
        console.log('Success:', data);
Season    })
    .catch(error => console.error('Error appending to playlist:', error));
}

// Close functions for all lists
function closeMusicList() {
    musicList.classList.remove('visible');
    musicList.classList.add('hidden');
    setTimeout(() => {
        isMusicVisible = false;
        musicList.innerHTML = ''; 
    }, 500);
}

function closeTVList() {
    tvList.classList.remove('visible');
    tvList.classList.add('hidden');
    setTimeout(() => {
        isTVVisible = false;
        tvList.innerHTML = ''; 
    }, 500);
}

function closeMovieList() {
    movieList.classList.remove('visible');
    movieList.classList.add('hidden');
    setTimeout(() => {
        isMovieVisible = false;
        movieList.innerHTML = ''; 
    }, 500);
}

// General function to close all lists before opening a new one
function hideAllLists(callback) {
    if (isMusicVisible) {
        closeMusicList();
    }
    if (isTVVisible) {
        closeTVList();
    }
    if (isMovieVisible) {
        closeMovieList();
    }

    setTimeout(() => {
        if (callback) {
            callback();
        }
    }, 500);
}

// Function to fetch contents of a movie directory (used in double click event)
function fetchMovieDirectoryContents(directory) {
    // Fetch the directory content from the backend
    fetch(`/list-directory/movies/${encodeURIComponent(directory)}`)
        .then(response => response.json())
        .then(data => {
            // Replace the content of the movie list with new directory content
            displayItems(data, movieList); // Reuse the same list container
        })
        .catch(error => console.error('Error navigating to directory:', error));
}

// Function to fetch contents of a TV directory (used in double click event)
function fetchTVDirectoryContents(directory) {
    // Fetch the directory content from the backend
    fetch(`/list-directory/tv/${encodeURIComponent(directory)}`)
        .then(response => response.json())
        .then(data => {
            // Replace the content of the TV list with new directory content
            displayItems(data, tvList); // Reuse the same list container
        })
        .catch(error => console.error('Error navigating to directory:', error));
}
