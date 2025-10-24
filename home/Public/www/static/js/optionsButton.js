const optionsButton = document.getElementById('optionsButton');
const optionsList = document.getElementById('optionsList');
const optionsItems = document.querySelectorAll('#optionsList .options-item');
let isOptionsVisible = false; // Track if the options list is visible

// Add event listener for options button
optionsButton.addEventListener('click', () => {
    if (isOptionsVisible) {
        hideAllLists(); // Hide if visible
    } else {
        hideAllLists(() => {
            showOptionsList(); // Show options list
        });
    }
});

function showOptionsList() {
    optionsList.classList.remove('hidden');
    optionsList.classList.add('visible');

    // Reveal each item progressively
    optionsItems.forEach((item, index) => {
        setTimeout(() => {
            item.classList.add('visible');
        }, index * 500); // Delay each item by 500ms
    });

    isOptionsVisible = true;
}

function hideAllLists(callback) {
    // Hide all lists and execute callback after hiding
    optionsList.classList.remove('visible');
    optionsList.classList.add('hidden');

    optionsItems.forEach(item => {
        item.classList.remove('visible'); // Reset item visibility
    });

    isOptionsVisible = false;

    if (callback) {
        setTimeout(callback, 500); // Delay for animation effect
    }
}

// Function to open the modal
function openModal(modalId) {
    document.getElementById(modalId).classList.add('visible-modal');
}

// Function to close the modal
function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('visible-modal');
}

// Submit the TV form to the FastAPI endpoint
// Submit the TV form to the FastAPI endpoint
function submitTvForm() {
    const ip = document.getElementById('tv-ip').value;
    const name = document.getElementById('tv-name').value;
    const isDefault = document.getElementById('tv-default').value.toLowerCase() === 'true';

    fetch('/new_tv', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            ip: ip,
            name: name,
            is_default: isDefault // Adjusted to match the FastAPI endpoint's parameter
        })
    }).then(response => response.json())
      .then(data => {
          if (data.message) {
              alert(data.message);
              closeModal('tvModal'); // Close the modal after successful submission
          } else {
              alert('Failed to add TV. Please check the input.');
          }
      })
      .catch(err => {
          console.error('Error adding TV:', err);
          alert('An error occurred while adding the TV.');
      });
}

// Submit the channel form to the FastAPI endpoint
function submitChannelForm() {
    const id = document.getElementById('channel-id').value;
    const name = document.getElementById('channel-name').value;
    const url = document.getElementById('channel-url').value;
    const iconUrl = document.getElementById('channel-icon').value;

    fetch('/create_channel', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            id: id,
            name: name,
            url: url,
            icon_url: iconUrl
        })
    }).then(response => response.json())
      .then(data => {
          alert('Channel added successfully!');
          closeModal('channelModal');
      }).catch(err => console.error(err));
}

// Function to populate and display channel list for reordering
function openOrganizeChannelModal() {
    fetch('/api/channels')
    .then(response => response.json())
    .then(data => {
        const channelList = document.getElementById('channelList');
        channelList.innerHTML = ''; // Clear current list
        data.forEach(channel => {
            const item = document.createElement('div');
            item.textContent = channel.name;
            item.draggable = true; // Enable drag-and-drop
            item.addEventListener('dragstart', handleDragStart);
            item.addEventListener('dragover', handleDragOver);
            item.addEventListener('drop', handleDrop);
            channelList.appendChild(item);
        });
        openModal('organizeChannelModal');
    });
}

// Function to handle drag-and-drop
let dragged;

function handleDragStart(e) {
    dragged = e.target;
    e.target.style.opacity = 0.5;
}

function handleDragOver(e) {
    e.preventDefault();
}

function handleDrop(e) {
    e.preventDefault();
    if (e.target !== dragged) {
        e.target.before(dragged);
    }
    dragged.style.opacity = '';
}

// Function to send the POST request to delete played news
function deletePlayedNews() {
    fetch('/api/news/delete/played', {
        method: 'POST'
    }).then(response => {
        if (response.ok) {
            alert('Played news deleted successfully!');
        }
    }).catch(err => console.error(err));
}



//
// Add event listener to open the podcast modal when button is clicked
document.getElementById('addPodcastButton').addEventListener('click', () => {
    openModal('newscastModal'); // Open the modal for adding a podcast
});

// Function to open the modal
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.style.display = 'block'; // Display modal
    modal.classList.add('visible-modal');
}

// Function to close the modal
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.style.display = 'none'; // Hide modal
    modal.classList.remove('visible-modal');
}

// Add event listener to close the modal when 'close' button is clicked
document.querySelectorAll('.close').forEach(closeButton => {
    closeButton.addEventListener('click', (event) => {
        const modal = event.target.closest('.modal');
        modal.style.display = 'none';
    });
});


// Add event listener to open the podcast modal when button is clicked
document.getElementById('addPodcastButton').addEventListener('click', () => {
    openModal('newscastModal'); // Open the modal for adding a podcast
});

// Function to open the modal
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.style.display = 'block'; // Display modal
    modal.classList.add('visible-modal');
}

// Function to close the modal
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.style.display = 'none'; // Hide modal
    modal.classList.remove('visible-modal');
}

// Add event listener to close the modal when 'close' button is clicked
document.querySelectorAll('.close').forEach(closeButton => {
    closeButton.addEventListener('click', (event) => {
        const modal = event.target.closest('.modal');
        modal.style.display = 'none';
    });
});
