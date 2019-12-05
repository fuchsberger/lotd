import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

// Table settings
const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: [[0, 'asc']],
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 'data-phx-component',
  stateSave: true
}

// modal hook

let Hooks = {}

// Hooks.ItemList = {
//   mounted(){
//     console.log("VIEW")
//     if(!window.table) window.table = $('table').DataTable({
//       ...TABLE_DEFAULTS,
//       order: [[1, 'asc']]
//     })
//   }
// }
// Hooks.Item = {
//   mounted(){
//     console.log("ITEM")
//   },
//   updated(){
//     const newData = window.table.row(this.el).data()
//     console.log(newData, window.table)
//   }
// }

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})
liveSocket.connect()

let socket = new Socket("/socket", { params: { token: window.userToken }})

// socket.connect()

export default socket
