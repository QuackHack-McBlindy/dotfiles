const musicButton = document.getElementById('musicButton');
const musicList = document.getElementById('musicList');
let isMusicVisible = false;

// Add event listener for the music button
musicButton.addEventListener('click', () => {
    if (isMusicVisible) {
        hideAllLists();
    } else {
        hideAllLists(() => {
            fetchDirectories(); // Fetch the directories when the button is clicked
        });
    }
});

// Function to fetch directories from the backend
function fetchDirectories() {
    fetch(`/list-music-directories`)
        .then(response => response.json())
        .then(data => {
            console.log("Data fetched from API:", data);
            displayDirectories(data.directories);
        })
        .catch(error => console.error('Error fetching directories:', error));
}

// Function to display directories
function displayDirectories(directories) {
    musicList.innerHTML = ''; // Clear the current list

    directories.forEach(directory => {
        const listItem = document.createElement('li');
        listItem.textContent = directory; // Display the directory name
        
        // Force visibility styles
        listItem.style.color = 'white';
        listItem.style.backgroundColor = 'black'; // Set background for contrast
        listItem.style.fontSize = '18px';
        listItem.style.padding = '10px';
        listItem.style.borderBottom = '1px solid white'; // Separate items
        
        musicList.appendChild(listItem);
    });

    musicList.classList.remove('hidden');
    musicList.classList.add('visible');
    isMusicVisible = true;
}

// Function to hide all lists
function hideAllLists(callback) {
    if (isMusicVisible) {
        musicList.innerHTML = ''; // Clear the music list
        musicList.classList.add('hidden');
        isMusicVisible = false;
    }

    if (callback) {
        callback();
    }
}
