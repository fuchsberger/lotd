import socket from './socket'
import { Table } from '../utils'

const configure_user_channel = id => {
  let channel = socket.channel(`user:${id}`)

  channel.join()
    .receive("ok", ({ characters, mods }) => {
      window.characters = characters
      window.mods = mods

      Table.character(characters)
      Table.mod(mods)

      // // add options to the add / update modal
      // add_options('#location_id', locations)
      // add_options('#quest_id', quests)
      // add_options('#display_id', displays)
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default configure_user_channel
