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

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("public", {})

  channel.join()
    .receive("ok", ({ items }) => {

      // enable timeago on table redraw
      $('#item-table').on('draw.dt', function () {
        $('#loader-wrapper').addClass('is-hidden')
        $("time").timeago()
      })

      let columns = [
        { visible: false },
        { title: "Name" },
        { title: "Location", render: d => search_field(d)},
        { title: "Quest", render: d => search_field(d)},
        { title: "Display", render: d => search_field(d)}
      ]
      let order = 1

      // user was logged in, add collect column
      if (items[0].length == 6) {
        columns.splice(1, 0, {
          render: d => (
            d ? `<a href='#'>${icon('ok-squared')}</a>`
              : `<a href='#'>${icon('plus-squared-alt')}</a>`
          ),
          searchable: false,
          sortable: false,
          title: icon('ok-squared'),
          width: "34px"
        })
        order = 2
      }

      let table = $('#item-table').DataTable({
        data: items,
        dom: 't',
        paging: false,
        info: false,
        order: [[order, 'asc']],
        columns
      })
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

    this.channel = channel
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
