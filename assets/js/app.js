import CSS from '../css/app.scss'

import "phoenix_html"
import { Nexus } from "./api"

function focus_search(){

}

// Executed when page is loaded
document.addEventListener('DOMContentLoaded', () => {

  // enable login
  const btn = document.getElementById("login-button")

  if (btn) btn.addEventListener("click", () => Nexus.login())

  // focus search
  focus_search()

  // When page gains visibility. Cases:
  // 1. when going from another tab to this tab
  // 2. when another window fully covered this tab (only chrome >=73 for now)
  // see: https://www.chromestatus.com/feature/6699045456183296

  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) focus_search()
  })

}, false)
