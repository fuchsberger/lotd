import { connect, Nexus } from "../api"

export default class MainView {
  mount() {

    // enable login
    const btn = document.getElementById("login-button")
    if (btn) btn.addEventListener("click", () => Nexus.login())

    // if we do have a crsf token (all pages except error pages)
    // then connect live socket and enable various functionalities
    const csrf_elm = document.querySelector("meta[name='csrf-token']")
    if(csrf_elm){
      connect(csrf_elm.getAttribute("content"))

      // When page gains visibility. Cases:
      // 1. when going from another tab to this tab
      // 2. when another window fully covered this tab (only chrome >=73 for now)
      // see: https://www.chromestatus.com/feature/6699045456183296

      document.addEventListener('visibilitychange', () => {
        if (!document.hidden) focus_search()
      })
    }
  }

  unmount() {

  }
}
