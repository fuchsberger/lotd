// import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

// modal hook

let Hooks = {}

// Hooks.mod_list = {
//   mounted(){
//     window.table = $('#mod-table').DataTable({
//       ...TABLE_DEFAULTS,
//       order: [[1, 'asc']]
//     })
//   },
//   updated() {
//     const newRows = []
//     $("#table-source tr").each(function () { newRows.push(this) })

//     window.table.rows.add(newRows).draw().responsive.recalc()
//   }
// }

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})
liveSocket.connect()
