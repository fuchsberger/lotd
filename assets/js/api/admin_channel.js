import $ from 'jquery'
import socket from './socket'
import { Flash, Table, Data } from '../utils'

const configure_channel = () => {

  $('#loader-wrapper').removeClass('d-none')

  let channel = socket.channel(`admin`)

  // listen for events
  channel.on('update-user', user => Data.update_user(user))

  channel.join()
    .receive("ok", ({ users }) => {

      if(window.channel) window.channel.leave()

      // handle role events
      $('table').on('click', 'a.demote-admin', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { admin: false }})
      })

      $('table').on('click', 'a.promote-admin', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { admin: true }})
      })

      $('table').on('click', 'a.demote-moderator', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { moderator: false }})
      })

      $('table').on('click', 'a.promote-moderator', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { moderator: true }})
      })

      Table.user(users)

      window.channel = channel

      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", ({ reason }) => {
      Flash.error(reason)
      $('#loader-wrapper').addClass('d-none')
    })
}

export default configure_channel
