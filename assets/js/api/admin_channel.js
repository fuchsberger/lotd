import $ from 'jquery'
import socket from './socket'
import { Flash, Table, Data } from '../utils'

const configure_admin_channel = () => {
  let channel = socket.channel(`admin`)

  // listen for events
  channel.on('update-user', user => Data.update_user(user))

  channel.join()
    .receive("ok", ({ users }) => {

      if (window.admin_channel) return

      Table.user(users)

      // handle role events
      $('#user-table').on('click', 'a.demote-admin', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { admin: false }})
      })

      $('#user-table').on('click', 'a.promote-admin', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { admin: true }})
      })

      $('#user-table').on('click', 'a.demote-moderator', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { moderator: false }})
      })

      $('#user-table').on('click', 'a.promote-moderator', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("update-user", { id, params: { moderator: true }})
      })

      window.adminChannel = channel
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

export default configure_admin_channel
