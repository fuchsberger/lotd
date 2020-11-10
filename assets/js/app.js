import CSS from '../css/app.scss'
import 'phoenix_html'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"
import connect from './nexus'

// Enable Nexus login.
let elm = document.getElementById("login-button")
if(elm) elm.addEventListener("click", connect)

// If we do have a crsf token (all pages except error pages), then connect live socket.
const csrf_elm = document.querySelector("meta[name='csrf-token']")
if(csrf_elm){
  const _csrf_token = csrf_elm.getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token } })
  liveSocket.connect()
  window.liveSocket = liveSocket
}


