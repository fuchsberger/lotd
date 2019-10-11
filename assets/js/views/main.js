import $ from 'jquery'
import 'datatables.net'
import 'timeago'
import socket from '../api/socket'
import login from '../api/nexus'

export default class MainView {

  enableTableFeatures() {
    $("table").on('draw.dt', function () {
      $('#loader-wrapper').addClass('d-none')
      $("time").timeago()
    })

    // enable filtering tables based on a searchfield
    $('table').on('click', 'a.search-field', function () {
      const text = $(this).text()
      $('#search').val( text )
      $('table').DataTable().search(text).draw()
    })

    // enable canceling a search
    $('#search-cancel').on('click', function () {
      $('#search').val('')
      $('table').DataTable().search('').draw()
    })
  }

  icon(name) {
    return `<span class="icon"><i class="icon-${name}"></i></span>`
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

    // if we have a table, create a datatable
    // if ($('table').length ) {



    //   // create datatable
    //   let table = $('table').DataTable({ dom: 't', paging: false, info: false })

    //   let info = table.page.info()

    //   // initial display total count
    //   $('.total-count').text(info.recordsTotal)

    //   // enable searching/filtering
    //   $('#search').on('keyup', function(){
    //     table.search( this.value ).draw()
    //     let info = table.page.info()

    //     // enable clean button
    //     if ($(this).val() == '') {
    //       $('#search-icon').removeClass('is-hidden')
    //       $('#search-cancel').addClass('is-hidden')
    //     } else {
    //       $('#search-icon').addClass('is-hidden')
    //       $('#search-cancel').removeClass('is-hidden')
    //     }

    //     // update filtered count
    //     $('.total-count').text(info.recordsTotal)
    //     $('.filtered-count')
    //       .text(info.recordsTotal != info.recordsDisplay ? info.recordsDisplay + ' / ' : '')
    //   })

    //   // enable search cancel button
    //   $('#search-cancel').on('click', function () {
    //     $('#search').val('')
    //     table.search('').draw()
    //     $('#search-icon').removeClass('is-hidden')
    //     $('#search-cancel').addClass('is-hidden')
    //   })

    //   // store table for unmount
    //   this.table = table
    // }

    // hide loader
    if(! $( "body" ).has( "table" ).length ) $('#loader-wrapper').addClass('is-hidden')
  }

  unmount() {
    // show loader
    $('#loader-wrapper').removeClass('is-hidden')

    // save current scroll position and view so after reloading same view it should scroll down
    sessionStorage.lastView = $('body').data('view')
    sessionStorage.scrollTop = $(window).scrollTop()

    if(this.table) this.table.destroy()
  }
}
