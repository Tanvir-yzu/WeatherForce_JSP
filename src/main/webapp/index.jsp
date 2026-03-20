<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>WeatherForce | Tailwind Forecast</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&family=Manrope:wght@400;500;700;800&display=swap" rel="stylesheet">

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        display: ["Space Grotesk", "sans-serif"],
                        body: ["Manrope", "sans-serif"]
                    },
                    boxShadow: {
                        glow: "0 20px 60px rgba(0,0,0,0.35)"
                    }
                }
            }
        };
    </script>
</head>
<body class="font-body text-sky-50 min-h-screen bg-[radial-gradient(1200px_700px_at_0%_0%,rgba(34,211,238,0.25),transparent_55%),radial-gradient(800px_500px_at_100%_20%,rgba(251,146,60,0.24),transparent_50%),linear-gradient(140deg,#071827_0%,#0c2940_45%,#16466b_100%)]">

<div class="relative max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-10">
    <div class="pointer-events-none absolute -top-10 -right-10 h-64 w-64 rounded-full bg-[radial-gradient(circle,rgba(253,224,71,0.7),rgba(253,224,71,0))]"></div>
    <div class="pointer-events-none absolute -bottom-8 -left-10 h-52 w-52 rounded-full bg-[radial-gradient(circle,rgba(56,189,248,0.5),rgba(56,189,248,0))]"></div>

    <section class="grid grid-cols-1 lg:grid-cols-2 gap-5 mb-5">
        <article class="rounded-3xl border border-sky-100/20 bg-slate-900/45 backdrop-blur-xl shadow-glow p-6 sm:p-8 animate-[fade_0.7s_ease-out]">
            <h1 class="font-display text-4xl sm:text-5xl lg:text-6xl tracking-tight bg-gradient-to-r from-white via-sky-100 to-cyan-200 text-transparent bg-clip-text">
                WEATHERFORCE
            </h1>
            <p class="mt-4 text-sky-100/80 text-base sm:text-lg leading-relaxed">
                Modern live weather forecast with city search, your current location, hourly trend, and 5-day outlook.
            </p>

            <div class="mt-6 grid grid-cols-1 sm:grid-cols-[1fr_auto_auto] gap-2">
                <input id="cityInput" type="text" placeholder="Search city (London, Tokyo, Jakarta)"
                       class="h-12 rounded-xl border border-white/20 bg-white/10 px-4 text-sky-50 placeholder:text-sky-100/60 outline-none focus:ring-2 focus:ring-cyan-300" />
                <button id="searchBtn" type="button"
                        class="h-12 px-5 rounded-xl font-display font-bold bg-cyan-300 text-sky-950 hover:bg-cyan-200 transition">
                    Search
                </button>
                <button id="locBtn" type="button"
                        class="h-12 px-5 rounded-xl font-display font-bold border border-white/20 bg-white/10 hover:bg-white/20 transition">
                    Use Location
                </button>
            </div>

            <p class="mt-3 text-sm text-sky-100/70">Data source: Open-Meteo API (no API key).</p>
            <p id="status" class="mt-2 min-h-6 text-sm text-cyan-100/90">Loading default forecast...</p>
        </article>

        <article class="rounded-3xl border border-sky-100/20 bg-slate-900/45 backdrop-blur-xl shadow-glow p-6 sm:p-7">
            <div class="grid grid-cols-[1fr_auto] gap-3">
                <div>
                    <div id="location" class="font-display text-2xl sm:text-3xl font-bold">--</div>
                    <div id="meta" class="text-sky-100/75 text-sm mt-1">--</div>
                    <div id="temp" class="font-display text-6xl sm:text-7xl leading-none font-bold mt-3">--°C</div>
                    <div id="condition" class="text-sky-100/90 text-lg mt-2">--</div>
                </div>
                <div id="icon" class="text-5xl sm:text-6xl self-start">☁</div>
            </div>

            <div class="mt-5 grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                <div class="rounded-xl border border-white/15 bg-white/10 p-3">
                    <div class="text-xs tracking-widest uppercase text-sky-100/60">Humidity</div>
                    <div id="humidity" class="font-display text-xl font-bold">--%</div>
                </div>
                <div class="rounded-xl border border-white/15 bg-white/10 p-3">
                    <div class="text-xs tracking-widest uppercase text-sky-100/60">Wind</div>
                    <div id="wind" class="font-display text-xl font-bold">-- km/h</div>
                </div>
                <div class="rounded-xl border border-white/15 bg-white/10 p-3">
                    <div class="text-xs tracking-widest uppercase text-sky-100/60">Feels Like</div>
                    <div id="feelsLike" class="font-display text-xl font-bold">--°C</div>
                </div>
            </div>
        </article>
    </section>

    <section class="grid grid-cols-1 gap-4">
        <article class="rounded-3xl border border-sky-100/20 bg-slate-900/45 backdrop-blur-xl shadow-glow p-5 sm:p-6">
            <h2 class="font-display font-bold text-lg mb-3">Next 6 Hours</h2>
            <div id="hourlyList" class="grid grid-cols-3 sm:grid-cols-6 gap-2"></div>
        </article>

        <article class="rounded-3xl border border-sky-100/20 bg-slate-900/45 backdrop-blur-xl shadow-glow p-5 sm:p-6">
            <h2 class="font-display font-bold text-lg mb-3">5-Day Forecast</h2>
            <div id="dailyList" class="grid gap-2"></div>
        </article>
    </section>
</div>

<script>
    const cityInput = document.getElementById("cityInput");
    const searchBtn = document.getElementById("searchBtn");
    const locBtn = document.getElementById("locBtn");
    const statusEl = document.getElementById("status");

    const locationEl = document.getElementById("location");
    const metaEl = document.getElementById("meta");
    const tempEl = document.getElementById("temp");
    const conditionEl = document.getElementById("condition");
    const iconEl = document.getElementById("icon");
    const humidityEl = document.getElementById("humidity");
    const windEl = document.getElementById("wind");
    const feelsLikeEl = document.getElementById("feelsLike");
    const hourlyListEl = document.getElementById("hourlyList");
    const dailyListEl = document.getElementById("dailyList");

    const weatherMap = {
        0: { text: "Clear Sky", icon: "☀" },
        1: { text: "Mainly Clear", icon: "🌤" },
        2: { text: "Partly Cloudy", icon: "⛅" },
        3: { text: "Overcast", icon: "☁" },
        45: { text: "Fog", icon: "🌫" },
        48: { text: "Rime Fog", icon: "🌫" },
        51: { text: "Light Drizzle", icon: "🌦" },
        53: { text: "Drizzle", icon: "🌦" },
        55: { text: "Dense Drizzle", icon: "🌧" },
        61: { text: "Light Rain", icon: "🌦" },
        63: { text: "Rain", icon: "🌧" },
        65: { text: "Heavy Rain", icon: "🌧" },
        71: { text: "Light Snow", icon: "🌨" },
        73: { text: "Snow", icon: "❄" },
        75: { text: "Heavy Snow", icon: "❄" },
        80: { text: "Rain Showers", icon: "🌦" },
        81: { text: "Showers", icon: "🌧" },
        82: { text: "Violent Showers", icon: "⛈" },
        95: { text: "Thunderstorm", icon: "⛈" },
        96: { text: "Storm + Hail", icon: "⛈" },
        99: { text: "Severe Storm", icon: "⛈" }
    };

    function weatherLabel(code) {
        return weatherMap[code] || { text: "Unknown", icon: "☁" };
    }

    function asDayName(isoDate) {
        const date = new Date(isoDate + "T12:00:00");
        return date.toLocaleDateString(undefined, { weekday: "short" });
    }

    function asHour(isoDateTime) {
        const d = new Date(isoDateTime);
        return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    }

    function setStatus(message, isLoading) {
        statusEl.textContent = message;
        statusEl.classList.toggle("opacity-70", Boolean(isLoading));
    }

    async function geocodeCity(city) {
        const url = "https://geocoding-api.open-meteo.com/v1/search?count=1&name=" + encodeURIComponent(city);
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error("Could not resolve city.");
        }
        const data = await response.json();
        if (!data.results || data.results.length === 0) {
            throw new Error("City not found.");
        }
        const first = data.results[0];
        return {
            lat: first.latitude,
            lon: first.longitude,
            name: first.name + (first.country ? ", " + first.country : "")
        };
    }

    async function getForecast(lat, lon) {
        const url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat
            + "&longitude=" + lon
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m"
            + "&hourly=temperature_2m,weather_code"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
            + "&timezone=auto";

        const response = await fetch(url);
        if (!response.ok) {
            throw new Error("Failed to load weather data.");
        }
        return response.json();
    }

    function renderCurrent(placeName, data) {
        const current = data.current;
        const weather = weatherLabel(current.weather_code);
        const stamp = new Date(current.time).toLocaleString();

        locationEl.textContent = placeName;
        metaEl.textContent = "Updated " + stamp;
        tempEl.textContent = Math.round(current.temperature_2m) + "°C";
        conditionEl.textContent = weather.text;
        iconEl.textContent = weather.icon;

        humidityEl.textContent = Math.round(current.relative_humidity_2m) + "%";
        windEl.textContent = Math.round(current.wind_speed_10m) + " km/h";
        feelsLikeEl.textContent = Math.round(current.apparent_temperature) + "°C";
    }

    function renderHourly(data) {
        const now = Date.now();
        const times = data.hourly.time;
        const temps = data.hourly.temperature_2m;
        const codes = data.hourly.weather_code;

        const rows = [];
        for (let i = 0; i < times.length; i++) {
            const ts = new Date(times[i]).getTime();
            if (ts >= now) {
                rows.push({ t: times[i], temp: temps[i], code: codes[i] });
            }
            if (rows.length === 6) {
                break;
            }
        }

        hourlyListEl.innerHTML = rows.map((row) => {
            const weather = weatherLabel(row.code);
            return "<div class=\"rounded-xl border border-white/15 bg-white/10 p-2.5 text-center\">"
                + "<div class=\"text-xs text-sky-100/70\">" + asHour(row.t) + "</div>"
                + "<div class=\"text-xl\">" + weather.icon + "</div>"
                + "<div class=\"font-display font-bold text-base\">" + Math.round(row.temp) + "°</div>"
                + "</div>";
        }).join("");
    }

    function renderDaily(data) {
        const days = data.daily.time;
        const max = data.daily.temperature_2m_max;
        const min = data.daily.temperature_2m_min;
        const code = data.daily.weather_code;

        dailyListEl.innerHTML = days.slice(0, 5).map((d, i) => {
            const weather = weatherLabel(code[i]);
            return "<div class=\"grid grid-cols-[1fr_auto_auto] items-center gap-2 rounded-xl border border-white/15 bg-white/10 px-3 py-2.5\">"
                + "<div><div class=\"font-bold\">" + asDayName(d) + "</div><div class=\"text-xs text-sky-100/70\">" + weather.text + "</div></div>"
                + "<div class=\"text-lg\">" + weather.icon + "</div>"
                + "<div class=\"font-display font-bold\">" + Math.round(max[i]) + "° / " + Math.round(min[i]) + "°</div>"
                + "</div>";
        }).join("");
    }

    async function loadWeatherByCoords(lat, lon, label) {
        try {
            setStatus("Fetching live forecast...", true);
            const data = await getForecast(lat, lon);
            renderCurrent(label, data);
            renderHourly(data);
            renderDaily(data);
            setStatus("Forecast loaded.", false);
        } catch (error) {
            setStatus(error.message || "Could not load weather data.", false);
        }
    }

    async function onSearch() {
        const city = cityInput.value.trim();
        if (!city) {
            setStatus("Please enter a city name.", false);
            return;
        }
        try {
            setStatus("Searching city...", true);
            const place = await geocodeCity(city);
            await loadWeatherByCoords(place.lat, place.lon, place.name);
        } catch (error) {
            setStatus(error.message || "Could not find city.", false);
        }
    }

    function onLocation() {
        if (!navigator.geolocation) {
            setStatus("Geolocation is not supported by your browser.", false);
            return;
        }
        setStatus("Getting your location...", true);
        navigator.geolocation.getCurrentPosition(
            (pos) => {
                loadWeatherByCoords(pos.coords.latitude, pos.coords.longitude, "Your Location");
            },
            () => {
                setStatus("Location access was denied.", false);
            },
            { timeout: 10000 }
        );
    }

    searchBtn.addEventListener("click", onSearch);
    cityInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            onSearch();
        }
    });
    locBtn.addEventListener("click", onLocation);

    loadWeatherByCoords(-6.17539, 106.82715, "Jakarta, Indonesia");
</script>

</body>
</html>
