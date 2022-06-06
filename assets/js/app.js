import { Socket } from "phoenix"
import "phoenix_html"
import { LiveSocket } from "phoenix_live_view"
import { connect } from './nexus'

import topbar from "topbar"

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// enable login
document.getElementById("login-button").addEventListener("click", connect)

// Configure Live Sockets
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

liveSocket.socket.onError(() => $('#loader-wrapper').show()) // TODO: delete?

// Connect if there are any LiveViews on the page
liveSocket.connect()
