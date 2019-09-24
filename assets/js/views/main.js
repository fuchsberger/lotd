import $ from 'jquery'
import { login } from '../api/nexus'

export default class MainView {
  mount() {
    // This will be executed when the document loads...

    $('#signInBtn').click(() => login())
  }

  unmount() {
    // This will be executed when the document unloads...

  }
}
