import $ from 'jquery'
import 'datatables.net'
import 'datatables.net-responsive'
import 'timeago'
import socket from '../api/socket'
import login from '../api/nexus'

export default class MainView {

  toggle_search_cancel(on = true) {
    if (on) {
      $('#search-control .icon-plus, #search-control .icon-search').addClass('d-none')
      $('#search-control .icon-cancel').removeClass('d-none')
    } else {
      $('#search-control .icon-plus, #search-control .icon-search').removeClass('d-none')
      $('#search-control .icon-cancel').addClass('d-none')
    }
  }

  enableTableFeatures(table) {

    // initially update the item count
    let info = table.page.info()
    $('#search-count').text(info.recordsDisplay)

    table.on('draw.dt', function () {
      // update filtered count
      let info = table.page.info()
      $('#search-count').text(info.recordsDisplay)
    })

    const toggle_search_cancel = this.toggle_search_cancel

    // enable filtering tables based on a searchfield
    table.on('click', 'a.search-field', function () {
      const text = $(this).text()
      $('#search').val(text)
      toggle_search_cancel(true)
      $('table').DataTable().search(text).draw()
    })

    // enable searching/filtering
    $('#search').on('keyup', function () {
      toggle_search_cancel(this.value != '')
      table.search(this.value).draw()
    })

    // enable canceling a search
    $('#search-control .icon-cancel').on('click', () => {
      $('#search').val('')
      table.search('').draw()
      toggle_search_cancel(false)
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
    return term ? `<a class='search-field'>${term}</a>` : ''
  }

  manage_actions(id) {
    const edit = `<a href='${this.module}/${id}/edit' class='icon-pencil'></a>`
    const del = `<a class='delete text-danger'><i class='icon-cancel'</a>`

    if (this.moderator && this.admin) return edit + del
    else if (this.moderator) return edit
    else if (this.admin) return del
    else return ''
  }

  mount() {

    // assign socket to view so we don't have to import it in each view
    this.socket = socket

    // establish roles
    this.authenticated = $('body').data('authenticated')
    this.moderator = $('body').data('moderator')
    this.admin = $('body').data('admin')

    // enable login button
    $('#signInBtn').click(() => login())

    // on clicking logout, disconnect all sockets
    $('#logout-button').click(() => window.userChannel.push("logout"))

    // enable menu
    let page = 'items'

    $('#menu a').click(function (e) {

      e.preventDefault()
      let id = $(this).data('id')

      // do nothing if clicking on current page
      if (page == id) return

      // otherwise close previous page and open the new one
      $('#menu .nav-item').removeClass('active')

      $(this).parent().addClass('active')
      $(`#${id}`).collapse('show')
      page = id
    })

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

      $('time').timeago()

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
