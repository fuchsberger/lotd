import CSS from '../css/app.scss'

import "phoenix_html"
import { Nexus } from "./api"

// Executed when page is loaded
document.addEventListener('DOMContentLoaded', () => {

  // enable login
  const btn = document.getElementById("login-button")
  if (btn) btn.addEventListener("click", () => Nexus.login())

}, false)
