import socket from './socket'
import { Flash, Table } from '../utils'

const configure_admin_channel = () => {
  let channel = socket.channel(`admin`)

  channel.join()
    .receive("ok", ({ users }) => {
      Table.user(users)
      window.adminChannel = channel
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

export default configure_admin_channel
