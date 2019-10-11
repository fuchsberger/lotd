import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()

    // Now that you are connected, you can join channels with a topic:
    let channel = this.socket.channel("items", { loaded: !!window.items })

    channel.join()
      .receive("ok", ({ items }) => {

        // save data to window
        window.items = items

        // enable timeago on table redraw
        $('#item-table').on('draw.dt', function () {
          $('#loader-wrapper').addClass('is-hidden')
          $("time").timeago()
        })

        let columns = [
          { visible: false },
          { title: "Name" },
          { title: "Location", render: d => this.search_field(d)},
          { title: "Quest", render: d => this.search_field(d)},
          { title: "Display", render: d => this.search_field(d)}
        ]
        let order = 1

        // user was logged in, add collect column
        if (items[0].length == 6) {

          // allow collecting of items
          $('#item-table').on('click', '.collect', function () {
            let id = parseInt($(this).closest('tr').attr('id'))
            channel.push("collect", { id })
              .receive('ok', () => {
                // find entry in items and mark as collected
                window.items[id - 1][1] = true
                $('#item-table').DataTable().cell($(this).parent()).data(true)
              })
          })

          // allow borrowing of items
          $('#item-table').on('click', '.remove', function () {
            let id = parseInt($(this).closest('tr').attr('id'))
            channel.push("remove", { id })
              .receive('ok', () => {
                // find entry in items and mark as collected
                window.items[id - 1][1] = false
                $('#item-table').DataTable().cell($(this).parent()).data(false)
              })
          })

          // add collect / borrow column
          columns.splice(1, 0, {
            render: d => (
              d ? `<a class='remove'>${this.icon('ok-squared')}</a>`
                : `<a class='collect'>${this.icon('plus-squared-alt')}</a>`
            ),
            searchable: false,
            sortable: false,
            title: this.icon('ok-squared'),
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
          rowId: 0,
          columns
        })

        this.enableTableFeatures()

        this.table = table
      })
      .receive("error", resp => { console.log("Unable to join", resp) })

    this.channel = channel
  }

  unmount() {
    super.unmount()
  }
}
