import $ from 'jquery'
import 'datatables.net'
import 'datatables.net-responsive'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()

    // join item channel
    let channel = this.socket.channel("items")

    channel.join()
      .receive("ok", ({ items, moderator }) => {

        let columns = [
          { visible: false },
          { title: "Item", className: "all" },
          { title: "Location", render: d => this.search_field(d)},
          { title: "Quest", render: d => this.search_field(d)},
          { title: "Display", render: d => this.search_field(d) },

        ]
        let order = 1

        // if moderator, add action column
        if (moderator) columns.push({
          className: 'text-center small-cell',
          data: 0,
          render: id => (`<a href="items/${id}/edit" class="icon-pencil"></a>`),
          searchable: false,
          orderable: false,
          title: 'Actions'
        })

        columns.push({
          className: 'control all small-cell',
          data: null,
          defaultContent: '',
          orderable: false
        })

        // user was logged in, add collect column
        if (items[0].length == 6) {

          // allow collecting of items
          $('#item-table').on('click', '.collect', function () {
            let id = parseInt($(this).closest('tr').attr('id'))
            channel.push("collect", { id })
              .receive('ok', () => {
                // find entry in items and mark as collected
                $('#item-table').DataTable().cell($(this).parent()).data(true)
              })
          })

          // allow borrowing of items
          $('#item-table').on('click', '.remove', function () {
            let id = parseInt($(this).closest('tr').attr('id'))
            channel.push("remove", { id })
              .receive('ok', () => {
                // find entry in items and mark as collected
                $('#item-table').DataTable().cell($(this).parent()).data(false)
              })
          })

          // allow deleting of items
          if (moderator) {
            $('#item-table').on('click', '.delete', function () {
              let id = parseInt($(this).closest('tr').attr('id'))
              channel.push("delete", { id })
            })
          }

          // add collect / borrow column
          columns.splice(1, 0, {
            className: "all small-cell",
            render: d => (
              d ? `<a class='remove'>${this.icon('ok-squared')}</a>`
                : `<a class='collect'>${this.icon('plus-squared-alt')}</a>`
            ),
            searchable: false,
            sortable: false,
            title: this.icon('ok-squared'),
            width: "25px"
          })
          order = 2
        }

        let table = $('table').DataTable({
          data: items,
          dom: 't',
          paging: false,
          info: false,
          order: [[order, 'asc']],
          responsive: {
            details: {
              type: 'column',
              target: -1
            }
          },
          rowId: 0,
          columns
        })

        this.enableTableFeatures(table)
        this.ready()
        this.table = table
      })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }

  unmount() {
    super.unmount()
  }
}
