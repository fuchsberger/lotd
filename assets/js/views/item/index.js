import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()

    // enable search on page load
    $('#search').val($('body').data('search'))
  }

  unmount() {
    super.unmount()
  }
}
