import $ from 'jquery'
import { socket, join_admin_channel, join_moderator_channel, join_user_channel } from '.'
import { Data, Table, Flash } from '../utils'

const initial_options = data => {
  const options = {}
  for (let i = 0; i < data.length; i++) {
    if (data.hasOwnProperty(i)) options[data[i].id] = data[i].name
  }
  return options
}

const configure_public_channel = () => {
  let channel = socket.channel("public")

  // listen for events
  channel.on('add-item', ({ item }) => {
    window.item_table.row.add(item).draw().node()
    calculate_item_counts()
  })

  channel.on('delete-item', ({ id }) => {
    window.item_table.row(`#${id}`).remove().draw()
    calculate_item_counts()
  })

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.user != undefined) return

      const { displays, items, locations, mods, quests, user, moderator, admin } = params

      window.user = user
      window.moderator = moderator
      window.admin = admin

      const options = {
        displays: initial_options(displays),
        locations: initial_options(locations),
        mods: initial_options(mods),
        quests: initial_options(quests)
      }

      Table.item(items, options)
      Table.location(Data.get_item_count(locations, items, 'location_id'))
      Table.quest(Data.get_item_count(quests, items, 'quest_id'))
      Table.display(Data.get_item_count(displays, items, 'display_id'))
      Table.mod(Data.get_item_count(mods, items, 'mod_id'))

      if (user) join_user_channel(user)
      if (moderator) join_moderator_channel()
      if (admin) join_admin_channel()

      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", ({reason}) => Flash.error(reason))
}

export default configure_public_channel
