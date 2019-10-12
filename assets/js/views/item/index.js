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
        console.log(items)

        let authenticated = items[0].length == 7

        let order = items[0].length == 7 ? 2 : 1

        let columns = [
          { visible: false },
          {
            title: "Item", className: "all font-weight-bold", data: null, render: d => (
              d[2] ? `<a href="${d[2]}" target='_blank'>${d[1]}</a>` : d[1]
          )},
          { title: "Location", data: 3, render: d => this.search_field(d)},
          { title: "Quest", data: 4, render: d => this.search_field(d)},
          { title: "Display", data: 5, render: d => this.search_field(d) },

        ]

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
        if (authenticated) {

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
        }

        let table = $('table').DataTable({
          data: items,
          dom: 't',
          paging: false,
          info: false,
          order: [[authenticated ? 1 : 0, 'asc']],
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
