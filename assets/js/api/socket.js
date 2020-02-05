import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

Hooks.ItemTable = {
  mounted(){
    console.log("Mounted")
    $('#item-table').DataTable()
  }
}

export default _csrf_token => {
  let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token }})
  liveSocket.connect()
}
