import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()

    // enable search on page load
    let searchtext = $('body').data('search')
    if (searchtext != '') this.search(searchtext)

    $('a.search-field').on('click', e => {
      e.preventDefault()
      this.search($(e.target).text())
    }).bind(this.table)
  }

  search(text){
    $('#search').val( text )
    this.table.search(text).draw()
    $('#search-icon').addClass('is-hidden')
    $('#search-cancel').removeClass('is-hidden')
  }

  unmount() {
    super.unmount()
  }
}
