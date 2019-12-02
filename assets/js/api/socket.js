import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live", Socket)
liveSocket.connect()

let socket = new Socket("/socket", { params: { token: window.userToken }})

// socket.connect()

export default socket
