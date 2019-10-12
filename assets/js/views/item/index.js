import $ from 'jquery'
import 'datatables.net'
import 'datatables.net-responsive'
import MainView from '../main'

export default class View extends MainView {

  user_actions(found){
    return found
      ? `<a class='remove'>${this.icon('ok-squared')}</a>`
      : `<a class='collect'>${this.icon('plus-squared-alt')}</a>`
  }

  mount() {
    super.mount()

    // join item channel
    let channel = this.socket.channel("items")

    // listen for deleted items
    channel.on('add', ({ item }) => {
      this.table
        .row.add( item )
        .draw()
        .node()
    })
    channel.on('delete', ({ id }) => this.table.row(`#${id}`).remove().draw())

    channel.join()
      .receive("ok", ({ items }) => {

        this.items = items

        let columns = [
          {
            title: "Item", className: "all font-weight-bold", data: null, render: d => (
              d[2] ? `<a href="${d[2]}" target='_blank'>${d[1]}</a>` : d[1]
          )},
          { title: "Location", data: 3, render: d => this.search_field(d)},
          { title: "Quest", data: 4, render: d => this.search_field(d)},
          { title: "Display", data: 5, render: d => this.search_field(d) },
        ]

        // if moderator, add action column
        if (this.moderator || this.admin) columns.push({
          className: 'text-center small-cell',
          data: 0,
          render: id => this.manage_actions(id),
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
        if (this.authenticated) {

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
          if (this.moderator) {
            $('#item-table').on('click', '.delete', function () {
              let id = parseInt($(this).closest('tr').attr('id'))
              channel.push("delete", { id })
            })
          }

          // add collect / borrow column
          columns.splice(0, 0, {
            className: "all small-cell",
            render: found => this.user_actions(found),
            searchable: false,
            sortable: false,
            title: this.icon('ok-squared'),
            width: "25px"
          })
        }

        if (this.moderator) {
          $('#modal form').submit(function (e) {
            e.preventDefault()

            const data = $(this).serializeArray().reduce(function(obj, item) {
              obj[item.name] = item.value;
              return obj;
            }, {})

            channel.push('add', data)
              .receive('ok', () => {

                // reset form
                $('#name').val('').removeClass('is-invalid')
                $('#url').val('').removeClass('is-invalid')
                $('#mod_id').val('').removeClass('is-invalid')
                $('#quest_id').val('').removeClass('is-invalid')
                $('#location_id').val('').removeClass('is-invalid')
                $('#display_id').val('').removeClass('is-invalid')
                $('.invalid-feedback').remove()

                // close modal if "add more items..." was not checked
                if (!$('#continue').is(':checked')) $('#modal').modal('hide')
              })
              .receive('error', ({ errors }) => {
                for (var key in errors) {
                  if (errors.hasOwnProperty(key)) {
                    $(`#${key}`).addClass('is-invalid')
                      .after(`<div class="invalid-feedback">${errors[key]}</div>`)
                  }
                }
              })

          })
        }

        let table = $('table').DataTable({
          data: items,
          dom: 't',
          paging: false,
          info: false,
          order: [[this.authenticated ? 1 : 0, 'asc']],
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
