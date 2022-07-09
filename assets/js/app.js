
import Alpine from 'alpinejs'
import "phoenix_html"
import { Socket } from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import connect from './nexus'
import topbar from "topbar"

window.Alpine = Alpine
Alpine.start()

// enable login
if(document.getElementById("login-button")){
  document.getElementById("login-button").addEventListener("click", () => connect())
}
if(document.getElementById("login-button-mobile")){
  document.getElementById("login-button-mobile").addEventListener("click", () => connect())
}

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Configure Live Sockets
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  }
})

// Connect if there are any LiveViews on the page
liveSocket.connect()
