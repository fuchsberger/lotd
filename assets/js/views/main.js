import $ from 'jquery'
import 'datatables.net'
import 'timeago'

import { login } from '../api/nexus'

export default class MainView {
  mount() {

    // enable mobile menu
    $(".navbar-burger").click(() => { $(".navbar-burger, .navbar-menu").toggleClass("is-active")})

    // enable login button
    $('#signInBtn').click(() => login())

    // enable dismissing of notifications
    $('.notification button.delete').on('click', function(){ $(this).parent().remove() })

    // if we have a table, create a datatable
    if ($('table').length ) {

      // enable timeago on table redraw
      $("table").on('draw.dt', function () {
        $('#loader-wrapper').addClass('is-hidden')
        $("time").timeago()
      })

      // create datatable
      let table = $('table').DataTable({ dom: 't', paging: false, info: false })

      let info = table.page.info()

      // initial display total count
      $('.total-count').text(info.recordsTotal)

      // enable searching/filtering
      $('#search').on('keyup', function(){
        table.search( this.value ).draw()
        let info = table.page.info()

        // enable clean button
        if ($(this).val() == '') {
          $('#search-icon').removeClass('is-hidden')
          $('#search-cancel').addClass('is-hidden')
        } else {
          $('#search-icon').addClass('is-hidden')
          $('#search-cancel').removeClass('is-hidden')
        }

        // update filtered count
        $('.total-count').text(info.recordsTotal)
        $('.filtered-count')
          .text(info.recordsTotal != info.recordsDisplay ? info.recordsDisplay + ' / ' : '')
      })

      // enable search cancel button
      $('#search-cancel').on('click', function () {
        $('#search').val('')
        table.search('').draw()
        $('#search-icon').removeClass('is-hidden')
        $('#search-cancel').addClass('is-hidden')
      })

      // store table for unmount
      this.table = table
    }

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
