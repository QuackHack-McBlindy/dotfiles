const podcastButtonn = document.getElementById('podcastButtonn');
const podcastList = document.getElementById('podcastList');
const podcastItems = document.querySelectorAll('#podcastList .podcast-item');
let isPodcastVisible = false; // Track if the podcast list is visible

// Function to hide all lists (TV, options, and podcast)
function hideAllLists(callback) {
    let hideDuration = 0;

    // Hide TV list
    if (isListVisible) {
        listItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (listItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            itemList.classList.remove('visible');
            itemList.classList.add('hidden');
        }, listItems.length * 500);
        hideDuration = listItems.length * 500;
        isListVisible = false;
    }

    // Hide Options list
    if (isOptionsVisible) {
        optionsItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (optionsItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            optionsList.classList.remove('visible');
            optionsList.classList.add('hidden');
        }, optionsItems.length * 500);
        hideDuration = Math.max(hideDuration, optionsItems.length * 500);
        isOptionsVisible = false;
    }

    // Hide Podcast list
    if (isPodcastVisible) {
        podcastItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (podcastItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            podcastList.classList.remove('visible');
            podcastList.classList.add('hidden');
        }, podcastItems.length * 500);
        hideDuration = Math.max(hideDuration, podcastItems.length * 500);
        isPodcastVisible = false;
    }

    // Ensure the callback (to show a new list) runs after all lists are hidden
    setTimeout(() => {
        if (callback) callback();
    }, hideDuration);
}

// Add event listener for podcast button
podcastButtonn.addEventListener('click', () => {
    if (isPodcastVisible) {
        // If the podcast list is already visible, hide it
        hideAllLists(); // No callback is needed here, as we are just hiding
    } else {
        // Close any other open list before showing the podcast list
        hideAllLists(() => {
            // Slide out the podcast list
            podcastList.classList.remove('hidden');
            podcastList.classList.add('visible');

            // Reveal each podcast item progressively
            podcastItems.forEach((item, index) => {
                setTimeout(() => {
                    item.classList.add('visible');
                }, index * 500);
            });

            isPodcastVisible = true;
        });
    }
});

function fetchDirectoryContents(directory) {
    let mediaType = isPodcastVisible ? 'podcast' : 
                    isMusicVisible ? 'music' : 
                    isTVVisible ? 'tv' : 
                    isMovieVisible ? 'movies' : '';

    fetch(/list-directory/${mediaType}/${encodeURIComponent(directory)})
        .then(response => response.json())
        .then(data => {
            if (isPodcastVisible) displayItems(data, podcastList, '.podcast-item');
            else if (isMusicVisible) displayItems(data, musicList, '.music-item');
            else if (isTVVisible) displayItems(data, tvList, '.tv-item');
            else if (isMovieVisible) displayItems(data, movieList, '.movie-item');
        })
        .catch(error => console.error('Error navigating to directory:', error));
}
