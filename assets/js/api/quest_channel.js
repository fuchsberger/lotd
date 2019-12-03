import $ from 'jquery'
import socket from './socket'
import { Flash, Table } from '../utils'

const configure_channel = () => {
  $('#loader-wrapper').removeClass('d-none')

  if(window.channel) window.channel.leave()
  let channel = socket.channel(`quest`)

  channel.join()
    .receive("ok", ({ quests }) => {
      Table.quest(quests)

      window.channel = channel
      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", ({ reason }) => {
      Flash.error(reason)
      $('#loader-wrapper').addClass('d-none')
    })
}

export default configure_channel
