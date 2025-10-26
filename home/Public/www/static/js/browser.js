
    
    async addCurrentFolder() {
        await this.addFolder(this.currentPath);
    }
    
    async playFile(filePath) {
        // First add to playlist, then play
        await this.addFile(filePath);
        // You might want to implement immediate playback here
        this.showNotification(`Playing: ${filePath.split('/').pop()}`);
    }
    
    isMediaFile(filename) {
        const mediaExtensions = ['.mp3', '.mp4', '.m4a', '.flac', '.wav', '.ogg', '.webm', '.mkv', '.avi'];
        return mediaExtensions.some(ext => filename.toLowerCase().endsWith(ext));
    }
    
    getFileIcon(filename) {
        if (this.isMediaFile(filename)) {
            return filename.toLowerCase().includes('.mp4') || filename.toLowerCase().includes('.mkv') ? 'movie' : 'music_note';
        }
        return 'insert_drive_file';
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    showLoading() {
        this.loadingElement.style.display = 'block';
        this.itemsContainer.style.display = 'none';
    }
    
    hideLoading() {
        this.loadingElement.style.display = 'none';
        this.itemsContainer.style.display = 'block';
    }
    
    showNotification(message) {
        // Create a temporary notification
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #ff7bac;
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            z-index: 10001;
            animation: slideInRight 0.3s ease;
        `;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
    
    showError(message) {
        this.showNotification(`❌ ${message}`);
    }
}

// Initialize the media browser
const mediaBrowser = new MediaBrowser();
