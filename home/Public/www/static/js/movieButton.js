const movieButton = document.getElementById('movieButton');
const movieList = document.getElementById('movieList');
const movieItems = document.querySelectorAll('#movieList .movie-item');
let isMovieVisible = false; // Track if the movie list is visible

// Add event listener for movie button
movieButton.addEventListener('click', () => {
    if (isMovieVisible) {
        // If the movie list is already visible, hide it
        hideAllLists(); // No callback is needed here, just hiding
    } else {
        // Close any other open list before showing the movie list
        hideAllLists(() => {
            // Slide out the movie list
            movieList.classList.remove('hidden');
            movieList.classList.add('visible');

            // Reveal each item progressively
            movieItems.forEach((item, index) => {
                setTimeout(() => {
                    item.classList.add('visible');
                }, index * 500); // Delay each item by 500ms
            });

            isMovieVisible = true;
        });
    }
});

// Function to hide all lists (TV, options, podcast, music, and movie)
function hideAllLists(callback) {
    let hideDuration = 0;

    // Hide TV (Shows) list
    if (isShowsVisible) {
        showsItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (showsItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            showsList.classList.remove('visible');
            showsList.classList.add('hidden');
        }, showsItems.length * 500);
        hideDuration = Math.max(hideDuration, showsItems.length * 500);
        isShowsVisible = false;
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

    // Hide Music list
    if (isMusicVisible) {
        musicItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (musicItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            musicList.classList.remove('visible');
            musicList.classList.add('hidden');
        }, musicItems.length * 500);
        hideDuration = Math.max(hideDuration, musicItems.length * 500);
        isMusicVisible = false;
    }

    // Hide Movie list
    if (isMovieVisible) {
        movieItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (movieItems.length - index - 1) * 500);
        });
        setTimeout(() => {
            movieList.classList.remove('visible');
            movieList.classList.add('hidden');
        }, movieItems.length * 500);
        hideDuration = Math.max(hideDuration, movieItems.length * 500);
        isMovieVisible = false;
    }

    // Ensure the callback (to show a new list) runs after all lists are hidden
    setTimeout(() => {
        if (callback) callback();
    }, hideDuration);
}

