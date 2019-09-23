import $ from 'jquery'
import { connect } from '../api/nexus'

export default class MainView {
  mount() {
    // This will be executed when the document loads...
    $('#signInBtn').click(() => this.login())
    let uuid = sessionStorage.getItem("uuid")
    let token = sessionStorage.getItem("connection_token")

    console.log({
      "uuid":  uuid,
      "connection_token": token
    })
  }

  unmount() {
    // This will be executed when the document unloads...

  }

  login(){
    console.log('login!')
    connect()
  }
}
