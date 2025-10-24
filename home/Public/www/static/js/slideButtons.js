// Buttons
const podcastButton = document.getElementById('podcastButton');
const musicButton = document.getElementById('musicButton');
const tvButton = document.getElementById('tvButton');
const movieButton = document.getElementById('movieButton');
const castButton = document.getElementById('castButton');

// Lists
const podcastList = document.getElementById('podcastList');
const musicList = document.getElementById('musicList');
const tvList = document.getElementById('tvList');
const movieList = document.getElementById('movieList');
const deviceList = document.getElementById('deviceList');  // For cast devices

// Items
const podcastItems = document.querySelectorAll('#podcastList .podcast-item');
let isPodcastVisible = false;
let isMusicVisible = false;
let isTVVisible = false;
let isMovieVisible = false;
let isDeviceListVisible = false;
let longPressTimeout; // For detecting hold down event
const maxAnimationDuration = 12000; // Max total animation duration (12s)

// Unified hideAllLists function to close any visible list
function hideAllLists(callback) {
    let hideDuration = 0;

    if (isPodcastVisible) {
        const podcastItems = document.querySelectorAll('#podcastList .podcast-item');
        podcastItems.forEach((item, index) => {
            const delay = Math.min((podcastItems.length - index - 1) * 500, maxAnimationDuration);
            setTimeout(() => {
                item.classList.remove('visible');
            }, delay);
        });
        setTimeout(() => {
            podcastList.classList.remove('visible');
            podcastList.classList.add('hidden');
        }, Math.min(podcastItems.length * 500, maxAnimationDuration));
        hideDuration = Math.min(podcastItems.length * 500, maxAnimationDuration);
        isPodcastVisible = false;
    }

    if (isMusicVisible) {
        closeMusicList();
        hideDuration = 500;
    }

    if (isTVVisible) {
        closeTVList();
        hideDuration = 500;
    }

    if (isMovieVisible) {
        closeMovieList();
        hideDuration = 500;
    }

    if (isDeviceListVisible) {
        closeDeviceList();
        hideDuration = 500;
    }

    setTimeout(() => {
        if (callback) callback();
    }, hideDuration);
}

// ---- Podcast Button Logic ----
//podcastButton.addEventListener('click', () => {
//    if (isPodcastVisible) {
//        hideAllLists(); // No callback needed here, as we are just hiding
//    } else {
//        hideAllLists(() => {
 //           podcastList.classList.remove('hidden');
//            podcastList.classList.add('visible');
//            const podcastItems = document.querySelectorAll('#podcastList .podcast-item');
 //           podcastItems.forEach((item, index) => {
//                const delay = Math.min(index * 500, maxAnimationDuration);
//                setTimeout(() => {
//                    item.classList.add('visible');
//                }, delay);
//            });
//            isPodcastVisible = true;
//        });
//    }
//});

// ---- Podcast Button Logic ----
podcastButton.addEventListener('click', () => {
    console.log('Podcast button clicked. Current visibility state:', isPodcastVisible);
    
    if (isPodcastVisible) {
        console.log('Closing podcast list...');
        closePodcastList();
    } else {
        console.log('Hiding all lists before fetching podcast directories...');
        hideAllLists(() => {
            console.log('Fetching podcast directories...');
            fetchPodcastDirectories();
        });
    }
});





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

// ---- Cast Button Logic ----
castButton.addEventListener('mousedown', () => {
    longPressTimeout = setTimeout(() => {
        if (!isDeviceListVisible) {
            hideAllLists(() => {
                fetchDeviceList();
            });
        }
    }, 1000); // 1-second hold for the long press
});

castButton.addEventListener('mouseup', () => {
    clearTimeout(longPressTimeout);
});

// Function to fetch directories and files for music, TV, movies, and devices
function fetchMusicDirectories() {
    fetch(`/api/navigate/list-music-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, musicList, '.music-item');
            isMusicVisible = true;
        })
        .catch(error => console.error('Error fetching music directories:', error));
}

function fetchTVDirectories() {
    fetch(`/api/navigate/list-shows-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, tvList, '.tv-item');
            isTVVisible = true;
        })
        .catch(error => console.error('Error fetching TV directories:', error));
}

function fetchMovieDirectories() {
    fetch(`/api/navigate/list-movie-directories`)
        .then(response => response.json())
        .then(data => {
            displayItems(data, movieList, '.movie-item');
            isMovieVisible = true;
        })
        .catch(error => console.error('Error fetching movie directories:', error));
}


function fetchPodcastDirectories() {
    console.log('Initiating fetch for podcast directories...');
    fetch(`/api/navigate/list-podcast-directories`)
        .then(response => {
            console.log('Received response from podcast directories API:', response);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Podcast directories fetched successfully:', data);
            displayItems(data, podcastList, '.podcast-item');
            isPodcastVisible = true;
            console.log('Podcast list is now visible.');
        })
        .catch(error => {
            console.error('Error fetching podcast directories:', error);
        });
}


function fetchDeviceList() {
    fetch('/api/db/devices')
        .then(response => response.json())
        .then(data => {
            displayDeviceItems(data, deviceList, '.device-item');

            isDeviceListVisible = true;
        })
        .catch(error => console.error('Error fetching devices:', error));
}

// Display items in the list with correct item class selector
function displayItems(data, listElement, itemClass) {
    listElement.innerHTML = '';

    data.directories.forEach(directory => {
        const listItem = document.createElement('li');
        listItem.textContent = `📁 ${directory}`;
        listItem.classList.add('directory');
        listItem.classList.add(itemClass.slice(1));
        listItem.dataset.path = directory;
        addItemEventListeners(listItem);
        listElement.appendChild(listItem);
    });

    data.files.forEach(file => {
        const listItem = document.createElement('li');
        const icon = getIconForFile(file);
        listItem.textContent = `${icon} ${file}`;
        listItem.classList.add('file');
        listItem.classList.add(itemClass.slice(1));
        listItem.dataset.path = file;
        addItemEventListeners(listItem);
        listElement.appendChild(listItem);
    });

    const items = listElement.querySelectorAll(itemClass);
    items.forEach((item, index) => {
        const delay = Math.min(index * 500, maxAnimationDuration);
        setTimeout(() => {
            item.classList.add('visible');
        }, delay);
    });

    listElement.classList.remove('hidden');
    listElement.classList.add('visible');
}

// Display devices in the list
// Display devices in the list
function displayDeviceItems(devices, listElement, itemClass) {
    listElement.innerHTML = '';

    devices.forEach(device => {
        const listItem = document.createElement('li');
        listItem.textContent = device.name + (device.default ? ' ✅' : '');
        listItem.classList.add('device');
        listItem.classList.add(itemClass.slice(1));
        listItem.dataset.deviceIp = device.ip;  // Use IP address as the unique identifier

        listItem.addEventListener('click', () => {
            fetch(`/api/db/set_default_device/${device.ip}`, { method: 'POST' })  // Use device IP in the request
                .then(() => {
                    alert(`${device.name} is now the default device.`);
                    closeDeviceList();  // Close the device list after the default is set
                })
                .catch(error => console.error('Error setting default device:', error));
        });

        listElement.appendChild(listItem);
    });

    const items = listElement.querySelectorAll(itemClass);
    items.forEach((item, index) => {
        const delay = Math.min(index * 500, maxAnimationDuration);
        setTimeout(() => {
            item.classList.add('visible');
        }, delay);
    });

    listElement.classList.remove('hidden');
    listElement.classList.add('visible');
}

// Function to close the device list
function closeDeviceList() {
    closeListWithItems(deviceList, '.device-item', () => {
        isDeviceListVisible = false;
    });
}

// Close functions for lists with progressive animation
function closeMusicList() {
    closeListWithItems(musicList, '.music-item', () => {
        isMusicVisible = false;
    });
}

// Close functions for lists with progressive animation
function closePodcastList() {
    closeListWithItems(podcastList, '.podcast-item', () => {
        isPodcastVisible = false;
    });
}

function closeTVList() {
    closeListWithItems(tvList, '.tv-item', () => {
        isTVVisible = false;
    });
}

function closeMovieList() {
    closeListWithItems(movieList, '.movie-item', () => {
        isMovieVisible = false;
    });
}

function closeDeviceList() {
    closeListWithItems(deviceList, '.device-item', () => {
        isDeviceListVisible = false;
    });
}

function closeListWithItems(listElement, itemClass, callback) {
    const items = listElement.querySelectorAll(itemClass);
    items.forEach((item, index) => {
        const delay = Math.min((items.length - index - 1) * 500, maxAnimationDuration);
        setTimeout(() => {
            item.classList.remove('visible');
        }, delay);
    });
    setTimeout(() => {
        listElement.classList.remove('visible');
        listElement.classList.add('hidden');
        listElement.innerHTML = '';
        if (callback) callback();
    }, Math.min(items.length * 500, maxAnimationDuration));
}

// Icon based on file type
function getIconForFile(fileName) {
    const extension = fileName.split('.').pop().toLowerCase();
    switch (extension) {
        case 'mp3':
        case 'wav':
        case 'flac':
            return '🎧';
        case 'mp4':
        case 'mkv':
        case 'avi':
            return '📽️';
        default:
            return '❓';
    }
}

// Add event listeners to list items
function addItemEventListeners(listItem) {
    listItem.addEventListener('click', () => {
        document.querySelectorAll('li').forEach(item => item.classList.remove('selected'));
        listItem.classList.add('selected');
    });

    if (listItem.classList.contains('directory')) {
        listItem.addEventListener('dblclick', () => {
            fetchDirectoryContents(listItem.dataset.path);
        });
    }

    listItem.addEventListener('mousedown', () => {
        longPressTimeout = setTimeout(() => {
            let mediaType = '';

            if (isMusicVisible) mediaType = 'music';
            else if (isTVVisible) mediaType = 'tv';
            else if (isMovieVisible) mediaType = 'movies';
            else if (isPodcastVisible) mediaType = 'podcast';

            const apiUrl = listItem.classList.contains('directory')
                ? `/api/playlist/append/${mediaType}/${encodeURIComponent(listItem.dataset.path)}`
                : `/api/playlist/append-file/${mediaType}/${encodeURIComponent(listItem.dataset.path)}`;
            appendToPlaylist(apiUrl, { path: listItem.dataset.path, playlist: 'playlist.m3u' });
        }, 1000);
    });

    listItem.addEventListener('mouseup', () => {
        clearTimeout(longPressTimeout);
    });
}

function appendToPlaylist(url, params) {
    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params),
    })
    .then(response => response.json())
    .then(data => console.log('Success:', data))
    .catch(error => console.error('Error appending to playlist:', error));
}

// Fetch directory contents function
function fetchDirectoryContents(directory) {
    let mediaType = '';

    if (isMusicVisible) mediaType = 'music';
    else if (isTVVisible) mediaType = 'tv';
    else if (isMovieVisible) mediaType = 'movies';
    else if (isPodcastVisible) mediaType = 'podcast';

    fetch(`/api/navigate/list-directory/${mediaType}/${encodeURIComponent(directory)}`)
        .then(response => response.json())
        .then(data => {
            if (isMusicVisible) displayItems(data, musicList, '.music-item');
            else if (isTVVisible) displayItems(data, tvList, '.tv-item');
            else if (isMovieVisible) displayItems(data, movieList, '.movie-item');
            else if (isPodcastVisible) displayItems(data, podcastList, '.podcast-item');
        })
        .catch(error => console.error('Error navigating to directory:', error));
}

