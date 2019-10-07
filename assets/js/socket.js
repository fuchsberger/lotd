import $ from 'jquery'
import 'datatables.net'
import 'timeago'

import { Socket } from "phoenix"

let socket = new Socket("/socket", {
  params: { token: window.userToken },
  // logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }
})

const icon = name => (`<span class="icon"><i class="icon-${name}"></i></span>`)

const search_field = d => (`<a class='search-field' href='#'>${d}</a>`)

// Finally, connect to the socket:
socket.connect()

// if (window.userToken != "") {
//   let channel = socket.channel("user", {})

//   channel.on("disconnect", () => {
//     console.log("disconnect")
//     channel.leave()
//   })

//   channel.join()
//     .receive("ok", resp => {

//     })
//     .receive("error", resp => { console.log("Unable to join", resp) })

//   window.userChannel = channel
// }

export default socket
