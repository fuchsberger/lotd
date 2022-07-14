import "phoenix_html"
import "./gui"
import "./timeago"
import connect from './nexus'
import "./character_table"
import "./display_table"
import "./item_table"
import "./location_table"
import "./mod_table"
import "./region_table"
import "./room_table"

// enable login
if(document.getElementById("login-button")){
  document.getElementById("login-button").addEventListener("click", () => connect())
}
if(document.getElementById("login-button-mobile")){
  document.getElementById("login-button-mobile").addEventListener("click", () => connect())
}

