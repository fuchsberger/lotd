import $ from 'jquery'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

Hooks.ItemTable = {
  mounted() {
    $(window).scroll(function () {
      if ($(document).height() <= $(window).scrollTop() + $(window).height()) $('#more').click()
    })
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})
liveSocket.connect()
