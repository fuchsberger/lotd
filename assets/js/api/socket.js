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
  rowId: 'phx-component',
  stateSave: true
}

// modal hook

let Hooks = {}

Hooks.mod_list = {
  mounted(){
    window.table = $('#mod-table').DataTable({
      ...TABLE_DEFAULTS,
      order: [[1, 'asc']]
    })
  },
  updated() {
    const newRows = []
    $("#table-source tr").each(function () { newRows.push(this) })

    window.table.rows.add(newRows).draw().responsive.recalc()
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
