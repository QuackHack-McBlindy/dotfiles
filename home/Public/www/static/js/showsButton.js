const tvButton = document.getElementById('tvButton'); // Corrected to target tvButton
const showsList = document.getElementById('showsList');
const showsItems = document.querySelectorAll('#showsList .shows-item');
let isShowsVisible = false; // Track if the shows list is visible

// Add event listener for shows button
tvButton.addEventListener('click', () => {
    if (isShowsVisible) {
        // Reverse the process - hide items progressively in reverse order
        showsItems.forEach((item, index) => {
            setTimeout(() => {
                item.classList.remove('visible');
            }, (showsItems.length - index - 1) * 500); // Reverse the order of hiding
        });

        // Wait for items to finish hiding before collapsing the list
        setTimeout(() => {
            showsList.classList.remove('visible');
            showsList.classList.add('hidden');
            isShowsVisible = false; // Update the state after hiding
        }, showsItems.length * 500); // Delay hiding the list based on the number of items

    } else {
        // Close any other open list before showing the shows list
        hideAllLists(() => {
            // Slide out the shows list
            showsList.classList.remove('hidden');
            showsList.classList.add('visible');

            // Reveal each item progressively
            showsItems.forEach((item, index) => {
                setTimeout(() => {
                    item.classList.add('visible');
                }, index * 500); // Delay each item by 500ms
            });

            isShowsVisible = true; // Update the state after showing
        });
    }
});

