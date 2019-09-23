import $ from 'jquery'

export default class MainView {
  mount() {
    // This will be executed when the document loads...
    $('#signInBtn').click(() => this.login())
  }

  unmount() {
    // This will be executed when the document unloads...

  }

  login(){
    console.log('login!')
  }
}
