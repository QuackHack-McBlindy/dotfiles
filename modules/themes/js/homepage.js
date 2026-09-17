const clock = document.getElementById("clock");
const dateElement = document.getElementById("date");

function updateClock() {
    const now = new Date();
    const hours =
        String(now.getHours()).padStart(2, "0");

    const minutes =
        String(now.getMinutes()).padStart(2, "0");

    const seconds =
        String(now.getSeconds()).padStart(2, "0");

    clock.innerHTML =
        `${hours}` +
        `<span class="colon">:</span>` +
        `${minutes}` +
        `<span class="colon">:</span>` +
        `${seconds}`;


    const date =
        now.toLocaleDateString(
            undefined,
            {
                weekday: "long",
                day: "numeric",
                month: "long",
                year: "numeric"
            }
        );


    dateElement.textContent = date;
}

updateClock();

setInterval(updateClock, 1000);

const ipAddress =
    document.getElementById("ip-address");

fetch("https://icanhazip.com")
    .then(response => {

        if (!response.ok) {
            throw new Error("Request failed");
        }

        return response.text();

    })
    .then(ip => {

        ipAddress.textContent =
            ip.trim();

    })
    .catch(() => {

        ipAddress.textContent =
            "unavailable";

    });

const categories =
    document.querySelectorAll(".category");

categories.forEach(category => {

    const button =
        category.querySelector(".category-header");


    button.addEventListener("click", () => {

        const isOpen =
            category.classList.contains("open");

        categories.forEach(other => {

            if (other !== category) {

                other.classList.remove("open");

                other
                    .querySelector(".category-header")
                    .setAttribute(
                        "aria-expanded",
                        "false"
                    );
            }

        });


        category.classList.toggle(
            "open",
            !isOpen
        );

        button.setAttribute(
            "aria-expanded",
            String(!isOpen)
        );

    });

});


const search =
    document.getElementById("search");

document.addEventListener(
    "keydown",
    event => {

        if (
            event.key === "/" &&
            document.activeElement !== search
        ) {

            event.preventDefault();

            search.focus();

        }


        if (
            event.key === "Escape" &&
            document.activeElement === search
        ) {

            search.value = "";

            search.blur();

        }

    }
);




search.addEventListener(
    "keydown",
    event => {

        if (event.key !== "Enter") {
            return;
        }


        const query =
            search.value.trim();


        if (!query) {
            return;
        }


        window.location.href =
            "https://duckduckgo.com/?q=" +
            encodeURIComponent(query);
    }
);
