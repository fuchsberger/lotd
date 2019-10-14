import $ from 'jquery'
import socket from './socket'
import { Menu, Table } from '../utils'

const configure_user_channel = id => {
  let channel = socket.channel(`user:${id}`)

  channel.join()
    .receive("ok", ({ character_id, characters, mods }) => {

      window.character_id = character_id
      window.characters = characters
      window.character_items = window.characters.find(c => c.id == character_id).items
      window.character_mods = window.characters.find(c => c.id == character_id).mods
      window.mods = mods




      Table.item(window.items)
      Table.location(window.locations)
      Table.quest(window.quests)
      Table.display(window.displays)
      Table.character(characters)
      Table.mod(mods)

      // // add options to the add / update modal
      // add_options('#location_id', locations)
      // add_options('#quest_id', quests)
      // add_options('#display_id', displays)
      // add_options('#mod_id', mods)

      Menu.search('')
      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default configure_user_channel
