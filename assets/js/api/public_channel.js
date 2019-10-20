import $ from 'jquery'
import { socket, join_moderator_channel, join_user_channel } from '.'
import { Data, Table, Flash } from '../utils'

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

      Table.location(locations)
      Table.quest(quests)
      Table.display(displays)
      Table.mod(mods)
      Table.item(items)

      if (user) join_user_channel(user)
      else Data.calculate_item_counts()

      if (moderator) join_moderator_channel()

      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", ({reason}) => Flash.error(reason))
}

export default configure_public_channel
