document.querySelector("#action").addEventListener("click", () => {
    window.silex.send("action", "clicked");
});

window.silex.on("status", payload => {
    document.querySelector("#status").textContent = payload;
});
