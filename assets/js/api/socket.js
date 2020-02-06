import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

Hooks.ItemTable = {
  mounted(){
    $('#item-table').DataTable({
      columns: [
        { orderable: false },
        null
      ],
      dom:
        "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'d-flex justify-content-center'i>",
      deferRender: true,
      order: [[1, 'asc']],
      scrollY: 'calc(100vh - 185px)',
      scrollCollapse: true,
      scroller: true,
      stateSave: true
    })
    $('#loader-wrapper').hide()
  }
}

export default _csrf_token => {
  let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token } })
  liveSocket.socket.onError(() => $('#loader-wrapper').show())
  liveSocket.connect()
}
