import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

export default _csrf_token => {
  let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token }})
  liveSocket.connect()
}
