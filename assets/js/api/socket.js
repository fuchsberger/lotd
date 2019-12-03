import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

// modal hook

let Hooks = {}

Hooks.modal = {
  updated(){
    $('#modal').modal('show')
  }

}


const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})
liveSocket.connect()

let socket = new Socket("/socket", { params: { token: window.userToken }})

// socket.connect()

export default socket
