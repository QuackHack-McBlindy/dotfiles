function fetchNowPlaying() {
    fetch('http://192.168.1.28:6999/api/adb/now-playing', {
        method: 'GET',
        headers: {
            'Accept': 'text/plain'
        }
    })
    .then(response => response.text())  // Process response as plain text
    .then(data => {
        const prefix = "https://qwackify.duckdns.org/";
        if (data.startsWith(prefix)) data = data.slice(prefix.length);

        // Only update if `adbTrackInfo` is visible
        const adbTrackInfo = document.getElementById('adbTrackInfo');
        if (adbTrackInfo.style.display !== 'none') {
            adbTrackInfo.textContent = data || "No data";
        }
})

// Call fetchNowPlaying every 15 seconds
setInterval(fetchNowPlaying, 15000);
// Initial call to load data immediately
fetchNowPlaying();
