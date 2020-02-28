import CSS from '../css/app.scss'

import $ from 'jquery'
import 'popper.js'
import 'bootstrap'
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"
import connect from './nexus'

// enable login
$('#login-button').click(() => connect())

// enable initial tooltips
$('[data-toggle="tooltip"]').tooltip()

let Hooks = {}

// enable tooltips in live views
Hooks.tooltip = {
  mounted() {
    $(this.el).tooltip({ html: true })
  },
  beforeUpdate() {
    $(this.el).tooltip('dispose')
  },
  updated() {
    $(this.el).tooltip({ html: true })
  },
  destroyed() {
    $(this.el).tooltip('dispose')
  }
}

Hooks.modal = {
  mounted() {
    $(this.el).modal('show')
  },
  beforeDestroy() {
    $(this.el).modal('hide')
  }
}

// if we do have a crsf token (all pages except error pages)
// then connect live socket and enable various functionalities
const csrf_elm = document.querySelector("meta[name='csrf-token']")
if(csrf_elm){
  const _csrf_token = csrf_elm.getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token } })
  liveSocket.socket.onError(() => $('#loader-wrapper').show())
  liveSocket.connect()
}

