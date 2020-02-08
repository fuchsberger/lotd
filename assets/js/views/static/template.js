import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"
import MainView from '../main'

export default class View extends MainView {

  mount() {
    super.mount()

    // if we do have a crsf token (all pages except error pages)
    // then connect live socket and enable various functionalities
    const csrf_elm = document.querySelector("meta[name='csrf-token']")
    if(csrf_elm){
      const _csrf_token = csrf_elm.getAttribute("content")
      let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token } })
      liveSocket.socket.onError(() => $('#loader-wrapper').show())
      liveSocket.connect()
    }
  }

  unmount() {
    super.unmount()
  }
}
