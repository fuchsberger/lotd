import 'phoenix_html'
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import {login, logout} from './nexus'
import topbar from "topbar"

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Enable Nexus login / logout
window.addEventListener("login", login)
window.addEventListener("logout", logout)

// Light / Darkmode Support
window.addEventListener("toggle:theme", event => {
  if (localStorage.theme === 'dark') {
    localStorage.theme = 'light'
    document.documentElement.classList.remove('dark')
  } else {
    localStorage.theme = 'dark'
    document.documentElement.classList.add('dark')
  }
})

// On page load or when changing themes, best to add inline in `head` to avoid FOUC
if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
  document.documentElement.classList.add('dark')
  localStorage.theme = 'dark'
} else {
  document.documentElement.classList.remove('dark')
  localStorage.theme = 'light'
}

// If we do have a crsf token (all pages except error pages), then connect live socket.
const csrf_elm = document.querySelector("meta[name='csrf-token']")
if(csrf_elm){
  const _csrf_token = csrf_elm.getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token } })
  liveSocket.connect()
  window.liveSocket = liveSocket
}
