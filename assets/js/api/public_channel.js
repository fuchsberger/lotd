import $ from 'jquery'
import { socket, join_user_channel } from '.'
import { Menu, Table } from '../utils'

const reset_modal = () => {
  // reset form
  $('#name').val('').removeClass('is-invalid')
  $('#url').val('').removeClass('is-invalid')
  $('#mod_id').val('').removeClass('is-invalid')
  $('#quest_id').val('').removeClass('is-invalid')
  $('#location_id').val('').removeClass('is-invalid')
  $('#display_id').val('').removeClass('is-invalid')
  $('.invalid-feedback').remove()

  // close modal if "add more items..." was not checked
  if (!$('#continue').is(':checked')) $('#modal').modal('hide')
}

const configure_public_channel = () => {
  let channel = socket.channel("public")

  // listen for deleted items
  channel.on('add', ({ item }) => {
    window.item_table
      .row.add( item )
      .draw()
      .node()
  })
  channel.on('delete', ({ id }) => window.item_table.row(`#${id}`).remove().draw())

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.user != undefined) return

      const { displays, items, locations, quests, user, moderator, admin } = params

      window.user = user
      window.moderator = moderator
      window.admin = admin

      window.displays = displays
      window.items = items
      window.locations = locations
      window.quests = quests

      if (user) {
        join_user_channel(user)
      } else {
        Table.item(items)
        Table.location(locations)
        Table.quest(quests)
        Table.display(displays)

        Menu.search('')
        $('#loader-wrapper').addClass('d-none')
      }
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default configure_public_channel
