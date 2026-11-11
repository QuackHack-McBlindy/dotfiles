# dotfiles/modules/posts/hardware.nix ⮞ https://github.com/quackhack-mcblindy/dotfiles
#  » ★ QuackHack-McBLindy.com ★ «
{ # 🦆 ⮞ nuthin' to see here... (just some html generation)
  lib,
  config,
  ...
} : {

  blog = {
    enable   = true;

    posts.hardware = {
      filename    = "hardware.html";
      date        = "2026-10-06";
      tags        = [ "hardware" "nixos" ];
      title       = "Meet My Hardware";
      description = "A gallery of the machines I actually run - past and present.";

      header1 = "Meet My";
      header2 = "Hardware";
      tagline = "A gallery of the machines I actually run - past and present. Click any thumbnail to view.";

      sections = [
        { html = ''
          <section class="content-section" id="hardware">
            <div class="wrap reveal">
              <div id="hardware-gallery" class="hardware-gallery" role="region" aria-label="Hardware gallery"></div>
            </div>
          </section>
          <script>
          (function () {
            'use strict';

            function escapeHTML(str) {
              return String(str == null ? "" : str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;');
            }

            function escapeAttr(str) {
              return escapeHTML(str).replace(/"/g, '&quot;');
            }

            var gallery = document.getElementById('hardware-gallery');
            if (!gallery) return;

            var lightbox = document.createElement('div');
            lightbox.className = 'lightbox';
            lightbox.setAttribute('role', 'dialog');
            lightbox.setAttribute('aria-modal', 'true');
            lightbox.setAttribute('aria-label', 'Media viewer');
            lightbox.innerHTML =
              '<button class="lightbox-close" type="button" aria-label="Close viewer">×</button>' +
              '<div class="lightbox-content">' +
                '<div class="lightbox-media"></div>' +
                '<div class="lightbox-caption"></div>' +
              '</div>';
            document.body.appendChild(lightbox);

            var mediaContainer = lightbox.querySelector('.lightbox-media');
            var captionEl = lightbox.querySelector('.lightbox-caption');
            var closeBtn = lightbox.querySelector('.lightbox-close');

            var currentIndex = 0;
            var mediaList = [];
            var lastFocused = null;

            function renderMedia(index) {
              var item = mediaList[index];
              if (!item) return;
              currentIndex = index;
              mediaContainer.innerHTML = "";

              var src = '/static/pics/hardware/' + item.src;

              if (item.type === 'image') {
                var img = document.createElement('img');
                img.src = src;
                img.alt = item.caption || "";
                mediaContainer.appendChild(img);
              } else {
                var video = document.createElement('video');
                video.src = src;
                video.controls = true;
                video.autoplay = true;
                video.muted = false;
                mediaContainer.appendChild(video);
              }

              captionEl.textContent = item.caption || "";
            }

            function openLightbox(index) {
              lastFocused = document.activeElement;
              lightbox.classList.add('active');
              document.body.style.overflow = 'hidden';
              renderMedia(index);
              closeBtn.focus();
            }

            function closeLightbox() {
              lightbox.classList.remove('active');
              document.body.style.overflow = "";
              mediaContainer.innerHTML = "";
              if (lastFocused && typeof lastFocused.focus === 'function') {
                lastFocused.focus();
              }
              lastFocused = null;
            }

            closeBtn.addEventListener('click', closeLightbox);

            lightbox.addEventListener('click', function (e) {
              if (e.target === lightbox) closeLightbox();
            });

            document.addEventListener('keydown', function (e) {
              if (!lightbox.classList.contains('active')) return;

              if (e.key === 'Escape') {
                closeLightbox();
              } else if (e.key === 'ArrowLeft') {
                e.preventDefault();
                renderMedia((currentIndex - 1 + mediaList.length) % mediaList.length);
              } else if (e.key === 'ArrowRight') {
                e.preventDefault();
                renderMedia((currentIndex + 1) % mediaList.length);
              } else if (e.key === 'Tab') {
                var focusable = lightbox.querySelectorAll('button, [href], video, [tabindex]:not([tabindex="-1"])');
                if (!focusable.length) return;
                var first = focusable[0];
                var last = focusable[focusable.length - 1];
                if (e.shiftKey && document.activeElement === first) {
                  e.preventDefault();
                  last.focus();
                } else if (!e.shiftKey && document.activeElement === last) {
                  e.preventDefault();
                  first.focus();
                }
              }
            });

            function loadHardwareGallery() {
              fetch('/static/pics/hardware/media.json', { cache: 'no-cache' })
                .then(function (res) {
                  if (!res.ok) throw new Error('HTTP ' + res.status);
                  return res.json();
                })
                .then(function (media) {
                  mediaList = Array.isArray(media) ? media : [];

                  if (mediaList.length === 0) {
                    gallery.innerHTML = '<div class="gallery-empty">No hardware media yet.</div>';
                    return;
                  }

                  gallery.innerHTML = mediaList.map(function (item, i) {
                    var thumbSrc = '/static/pics/hardware/' + (item.thumb || item.src);
                    var fullSrc  = '/static/pics/hardware/' + item.src;
                    var altText  = escapeAttr(item.caption || "");

                    var mediaEl = item.type === 'image'
                      ? '<img src="' + escapeAttr(thumbSrc) + '" alt="' + altText + '" loading="lazy">'
                      : '<video src="' + escapeAttr(fullSrc) + '" muted preload="metadata" aria-label="' + altText + '"></video>';

                    var capEl = item.caption
                      ? '<div class="hw-caption">' + escapeHTML(item.caption) + '</div>'
                      : "";

                    return '<button class="hw-item" type="button" data-index="' + i + '" aria-label="View ' + (altText || 'media') + '">' +
                      mediaEl +
                      capEl +
                    '</button>';
                  }).join("");

                  Array.prototype.forEach.call(
                    gallery.querySelectorAll('.hw-item'),
                    function (el) {
                      el.addEventListener('click', function () {
                        var index = parseInt(el.dataset.index, 10);
                        if (!isNaN(index)) openLightbox(index);
                      });
                    }
                  );
                })
                .catch(function (err) {
                  console.error('Hardware gallery error:', err);
                  gallery.innerHTML = '<div class="gallery-empty">Could not load hardware media.</div>';
                });
            }

            loadHardwareGallery();
          })();
          </script>
        ''; }
      ];

      extraCss = ''
        .hero-title {
          font-size: clamp(1.8rem, 5vw, 2.8rem);
          margin: 0 0 8px;
        }
        .hero-sub {
          font-size: 1rem;
          max-width: 620px;
          margin: 0 auto 36px;
          line-height: 1.65;
        }

        .hardware-gallery {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 16px;
          margin-top: 20px;
        }
        .hw-item {
          position: relative;
          border-radius: 12px;
          overflow: hidden;
          background: rgba(255, 255, 255, .03);
          border: 1px solid rgba(255, 255, 255, .08);
          cursor: pointer;
          transition: transform .2s ease, border-color .2s ease;
          appearance: none;
          padding: 0;
          font: inherit;
          color: inherit;
          text-align: inherit;
          width: 100%;
        }
        .hw-item:hover,
        .hw-item:focus-visible {
          transform: translateY(-3px);
          border-color: rgba(17, 230, 210, .4);
          outline: none;
        }
        .hw-item:focus-visible {
          box-shadow: 0 0 0 2px rgba(17, 230, 210, .4);
        }
        .hw-item img,
        .hw-item video {
          width: 100%;
          height: 180px;
          object-fit: cover;
          display: block;
        }
        .hw-item .hw-caption {
          padding: 8px 12px;
          font-size: .9rem;
          color: var(--muted);
          text-align: center;
        }
        .gallery-empty {
          grid-column: 1 / -1;
          text-align: center;
          color: var(--muted);
          padding: 40px 20px;
          font-size: .95rem;
        }

        /* Lightbox */
        .lightbox {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, .92);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 20000;
          padding: 20px;
          opacity: 0;
          pointer-events: none;
          transition: opacity .3s ease;
        }
        .lightbox.active {
          opacity: 1;
          pointer-events: auto;
        }
        .lightbox-content {
          max-width: 90vw;
          max-height: 90vh;
          display: flex;
          flex-direction: column;
          align-items: center;
        }
        .lightbox-media img,
        .lightbox-media video {
          max-width: 100%;
          max-height: 80vh;
          border-radius: 8px;
          box-shadow: 0 0 30px rgba(0, 0, 0, .5);
          display: block;
        }
        .lightbox-caption {
          margin-top: 12px;
          color: #ddd;
          font-size: 1rem;
          text-align: center;
          max-width: 80vw;
        }
        .lightbox-close {
          position: absolute;
          top: 20px;
          right: 30px;
          font-size: 2rem;
          color: #fff;
          cursor: pointer;
          background: none;
          border: none;
          padding: 8px 14px;
          border-radius: 8px;
          transition: background .2s ease;
        }
        .lightbox-close:hover { background: rgba(255, 255, 255, .08); }
      '';

      relatedPosts = true;
    };

  };}
