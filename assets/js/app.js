import $ from 'jquery'
import 'popper.js'
import 'bootstrap'
import { Socket } from "phoenix"
import "phoenix_html"
import { LiveSocket } from "phoenix_live_view"
import connect from './nexus'

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// enable login
$('#login-button').click(() => connect())

// enable initial tooltips
$('[data-toggle="tooltip"]').tooltip()

let Hooks = {}

// enable tooltips in live views
Hooks.tooltip = {
  mounted() {
    $(this.el).tooltip({ html: true })
  },
  beforeUpdate() {
    $(this.el).tooltip('dispose')
  },
  updated() {
    $(this.el).tooltip({ html: true })
  },
  destroyed() {
    $(this.el).tooltip('dispose')
  }
}

// Configure Live Sockets
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

liveSocket.socket.onError(() => $('#loader-wrapper').show()) // TODO: delete?

// Connect if there are any LiveViews on the page
liveSocket.connect()
