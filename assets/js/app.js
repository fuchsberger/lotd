import "phoenix_html"
import { Socket } from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import connect from './nexus'

import $ from 'jquery'
var dt = require( 'datatables.net' )( window, $ );

var hideCollected = false

function onDraw(dt){
  var info = dt.page.info()

  var {start, end, recordsDisplay, recordsTotal} = info

  var filterText = recordsDisplay == recordsTotal ? ""
    : ` (filtered from <span class="font-medium">${recordsTotal}</span> items)`

  var html = `<p class="text-sm text-gray-700">Showing <span class="font-medium">${start+1}</span> to <span class="font-medium">${end}</span> of <span class="font-medium">${recordsDisplay}</span> items${filterText}</p>`

  $('#table-info').html(html);
}

var table = $('#data-table').DataTable({
    ajax: '/api/items',
    columnDefs: [
      {
        // id
        targets: 0,
        visible: false,
        searchable: false
      },
      {
        // collected?
        targets: 1,
        className: "relative px-4",
        visible: $('#data-table').hasClass("has-character"),
        orderable: false,
        width: "3rem",
        type: "html",
        render: collected => (`<input type="checkbox" class="absolute left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" ${collected ? "checked": ""}><span class="hidden">${collected}</span>`)
      },
      {
        // name
        targets: 2,
        className: "whitespace-nowrap px-2 py-2 text-sm font-medium text-gray-900 truncate"
      },
      {
        // location
        targets: 3,
        className: "hidden sm:table-cell whitespace-nowrap px-2 py-2 text-sm text-gray-500 truncate"
      },
      {
        // region
        targets: 4,
        className: "hidden lg:table-cell whitespace-nowrap px-2 py-2 text-sm text-gray-500 truncate"
      },
      {
        // display
        targets: 5,
        className: "hidden md:table-cell whitespace-nowrap px-2 py-2 text-sm text-gray-500 truncate"
      },
      {
        // room
        targets: 6,
        className: "hidden xl:table-cell whitespace-nowrap px-2 py-2 text-sm text-gray-500 truncate"
      },
      {
        // url
        targets: 7,
        orderable: false,
        searchable: false,
        className: "whitespace-nowrap px-2 py-2 text-sm text-gray-500",
        render: url =>
        (url ? `<a class="text-indigo-600 hover:text-indigo-900" href="${url}" target="_blank"><svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>` : ""),
        width: "3.25rem"
      },
      {
        // moderator
        targets: 8,
        orderable: false,
        searchable: false,
        visible: $('#data-table').hasClass("moderate"),
        className: "whitespace-nowrap px-2 py-2 text-sm text-gray-500",
        defaultContent: `<a class="text-indigo-600 hover:text-indigo-900" href="#" target="_blank"><svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg></a>`,
        width: "3.25rem"
      }
    ],
    dom: '<"sm:flex sm:items-center sm:justify-between space-y-3"lf><"mt-4 flex flex-col"<"overflow-x-auto sm:-mx-6 lg:-mx-8"<"inline-block min-w-full py-2 align-middle md:px-6 lg:px-8"<"relative overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg"t<"bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6"<"#table-info.hidden sm:block">p>>>>>',
    initComplete: function () {
      // Apply the search
      this.api()
          // filter hideDisplayed
          .column(1)
          .search(hideCollected ? "false" : "")
          // search individual columns
          .columns()
          .every(function () {
              var that = this;

              $('input', this.footer()).on('keyup change clear', function () {
                  if (that.search() !== this.value) {
                      that.search(this.value).draw();
                  }
              });
          });
    },
    order: [[ 2, 'asc' ]],
    pagingType: "simple",
    stateSave: true,
    stripeClasses: []
}).on('draw init', function() {
  onDraw(table);
})

// toggle hidden items
$("#toggle-hidden").on("click", () => {
  hideCollected = !hideCollected
  table.column( 1 ).search(hideCollected ? "false" : "").draw()
  $("#toggle-hidden svg").toggleClass("hidden")
})

// enable mobile menu and user-dropdown
$(document).on("click", () => {
  $("#mobile-menu").addClass("hidden")
  $("#user-dropdown-menu").addClass("hidden")
})

$("#mobile-menu-button").on("click", e => {
  e.stopPropagation()
  $("#mobile-menu").toggleClass("hidden")
})

$("#mobile-menu").on("click", e => { e.stopPropagation()})

$("#user-dropdown-button").on("click", e => {
  e.stopPropagation()
  $("#user-dropdown-menu").toggleClass("hidden")
})

// enable login
if(document.getElementById("login-button")){
  document.getElementById("login-button").addEventListener("click", () => connect())
}
if(document.getElementById("login-button-mobile")){
  document.getElementById("login-button-mobile").addEventListener("click", () => connect())
}


// Configure Live Sockets
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Connect if there are any LiveViews on the page
liveSocket.connect()
