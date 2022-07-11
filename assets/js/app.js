
import Alpine from 'alpinejs'
import "phoenix_html"
import { Socket } from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import connect from './nexus'
import topbar from "topbar"

import $ from 'jquery'
var dt = require( 'datatables.net' )( window, $ );

$(document).ready(function () {
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
          visible: false,
          searchable: false
        },
        {
          // name
          targets: 2,
          className: "first bold"
        },
        {
          // location
          targets: 3
        },
        {
          // region
          targets: 4
        },
        {
          // display
          targets: 5
        },
        {
          // room
          targets: 6
        },
        {
          // mod
          targets: 7,
          render: initials => {
            return initials ? `<span class="inline-flex rounded-full bg-green-100 px-2 text-xs font-semibold leading-5 text-green-800">${initials}</span>` : null
          }
        },
        {
          // replica
          targets: 8,
          searchable: false,
          render: has_replica =>
            (has_replica ? `<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" /></svg>` : ""),
            width: "3.25rem"
        },
        {
          // url
          targets: 9,
          orderable: false,
          searchable: false,
          render: url =>
          (url ? `<a class="text-indigo-600 hover:text-indigo-900" href="${url}" target="_blank"><svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>` : ""),
          width: "3.25rem"
        },
      ],
      dom: '<"px-4 sm:px-6 lg:px-8 py-8"<"sm:flex sm:items-center sm:justify-between"lf><"mt-8 flex flex-col"<"-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8"<"inline-block min-w-full py-2 align-middle md:px-6 lg:px-8"<"relative overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg"t<"bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6"<"#table-info.hidden sm:block">p>>>>>>',
      initComplete: function () {
        // Apply the search
        this.api()
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
      stripeClasses: []
  }).on('draw init', function() {
    onDraw(table);
  })
});

window.Alpine = Alpine
Alpine.start()

// enable login
if(document.getElementById("login-button")){
  document.getElementById("login-button").addEventListener("click", () => connect())
}
if(document.getElementById("login-button-mobile")){
  document.getElementById("login-button-mobile").addEventListener("click", () => connect())
}

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Configure Live Sockets
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  }
})

// Connect if there are any LiveViews on the page
liveSocket.connect()
