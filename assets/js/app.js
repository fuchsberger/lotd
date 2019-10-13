import CSS from '../css/app.scss'

import $ from 'jquery'
import 'bootstrap'
import 'datatables.net'
import 'datatables.net-responsive'
import 'timeago'
import "phoenix_html"
import { login, join_public_channel } from './api'
import { Menu } from './utils'

const toggle_search_cancel = (on = true) => {
  if (on) {
    $('#search-control .icon-plus, #search-control .icon-search').addClass('d-none')
    $('#search-control .icon-cancel').removeClass('d-none')
  } else {
    $('#search-control .icon-plus, #search-control .icon-search').removeClass('d-none')
    $('#search-control .icon-cancel').addClass('d-none')
  }
}

// Executed when page is loaded
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

$( document ).ready(function() {

  // enable menu functionality
  Menu.enable()

  // set up and connect channels
  join_public_channel()

  // if we have a table (not item table), create a datatable
  // if ($('table').not( "#item-table" ).length ) {

  //   // create datatable
  //   let table = $('table').DataTable({ dom: 't', paging: false, info: false })

  //   let info = table.page.info()

  //   // initial display total count
  //   $('.total-count').text(info.recordsTotal)

  //   // enable search cancel button
  //   $('#search-cancel').on('click', function () {
  //     $('#search').val('')
  //     table.search('').draw()
  //     $('#search-icon').removeClass('is-hidden')
  //     $('#search-cancel').addClass('is-hidden')
  //   })

  //   $('time').timeago()
  // }
})
