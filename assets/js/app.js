import CSS from '../css/app.scss'

import 'bootstrap'
import 'datatables.net'
import 'datatables.net-dt'
import "phoenix_html"

import { connect, Nexus } from "./api"

function focus_search(){

}

// Executed when page is loaded
document.addEventListener('DOMContentLoaded', () => {

  // if we do have a crsf token (all pages except error pages)
  // then connect live socket and enable various functionalities
  const csrf_elm = document.querySelector("meta[name='csrf-token']")
  if(csrf_elm){
    connect(csrf_elm.getAttribute("content"))

    // focus search
    focus_search()

    // When page gains visibility. Cases:
    // 1. when going from another tab to this tab
    // 2. when another window fully covered this tab (only chrome >=73 for now)
    // see: https://www.chromestatus.com/feature/6699045456183296

    document.addEventListener('visibilitychange', () => {
      if (!document.hidden) focus_search()
    })
  }

  // enable login
  const btn = document.getElementById("login-button")
  if (btn) btn.addEventListener("click", () => Nexus.login())

}, false)
