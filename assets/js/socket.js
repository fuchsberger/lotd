import {Socket} from "phoenix"

let socket = new Socket("/socket", {
  params: { token: window.userToken },
  // logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }
})

// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let publicChannel = socket.channel("public", {})

publicChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

if (window.userToken != "") {
  let userChannel = socket.channel("user", {})

  userChannel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default socket
