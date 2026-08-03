globalThis.silexWebViewReady = true;
window.silex.on("ping", payload => window.silex.send("pong", payload));
