import $ from 'jquery'
import 'datatables.net'
import 'datatables.net-responsive'
import 'timeago'
import socket from '../api/socket'
import login from '../api/nexus'

export default class MainView {

  enableTableFeatures(table) {

    // initially update the item count
    let info = table.page.info()
    $('#search-count').text(info.recordsDisplay)

    table.on('draw.dt', function () {
      // update filtered count
      let info = table.page.info()
      $('#search-count').text(info.recordsDisplay)
    })

    // enable filtering tables based on a searchfield
    table.on('click', 'a.search-field', function () {
      const text = $(this).text()
      $('#search').val(text)
      $('#search-control .icon-search').addClass('d-none')
      $('#search-control .icon-cancel').removeClass('d-none')
      $('table').DataTable().search(text).draw()
    })

    // enable searching/filtering
    $('#search').on('keyup', function(){
      table.search( this.value ).draw()
    })

    // enable canceling a search
    $('#search-control .icon-cancel').on('click', () => {
      $('#search').val('')
      table.search('').draw()
      $('#search-control .icon-search').removeClass('d-none')
      $('#search-control .icon-cancel').addClass('d-none')
    })
  }

  icon(name) {
    return `<span class="icon"><i class="icon-${name}"></i></span>`
  }

  loading() {
    $('#loader-wrapper').removeClass('d-none')
  }

  ready() {
    $('#loader-wrapper').addClass('d-none')
  }

  search_field(term) {
    return `<a class='search-field'>${term}</a>`
  }

  mount() {

    // assign socket to view so we don't have to import it in each view
    this.socket = socket

    // enable login button
    $('#signInBtn').click(() => login())

    // on clicking logout, disconnect all sockets
    $('#logout-button').click(() => window.userChannel.push("logout"))

    // if we have a table (not item table), create a datatable
    if ($('table').not( "#item-table" ).length ) {

      // create datatable
      let table = $('table').DataTable({ dom: 't', paging: false, info: false })

      let info = table.page.info()

      // initial display total count
      $('.total-count').text(info.recordsTotal)

      // enable search cancel button
      $('#search-cancel').on('click', function () {
        $('#search').val('')
        table.search('').draw()
        $('#search-icon').removeClass('is-hidden')
        $('#search-cancel').addClass('is-hidden')
      })

      // store table for unmount
      this.table = table

      this.ready()
    }

    // hide loader
    if(! $( "body" ).has( "table" ).length ) this.ready()
  }

  unmount() {
    this.loading()
    if(this.table) this.table.destroy()
  }
}
