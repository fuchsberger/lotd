import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import connect from './nexus'

import $ from 'jquery'
var dt = require( 'datatables.net' )( window, $ );

var hideCollected = false

$.ajaxSetup({ headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') } });

function onDraw(dt){
  var info = dt.page.info()

  var {start, end, recordsDisplay, recordsTotal} = info

  var filterText = recordsDisplay == recordsTotal ? ""
    : ` (filtered from <span class="font-medium">${recordsTotal}</span> entries)`

  var html = `<p class="text-sm text-gray-700">Showing <span class="font-medium">${start+1}</span> to <span class="font-medium">${end}</span> of <span class="font-medium">${recordsDisplay}</span> entries${filterText}</p>`

  $('#table-info').html(html);
}

var itemTable = $('#item-table').DataTable({
  ajax: "/api/items",
  autoWidth: false,
  columnDefs: [
    { targets: [6, 7, 8], orderable: false, searchable: false},
    { targets: [7, 8], data: 7, visible: $('#item-table').hasClass("moderator")},
    { targets: 0,
      orderable: false,
      visible: $('#item-table').hasClass("has-character"),
      type: "html",
      render: (collected, display, row) => `
        <input type="checkbox" data-id="${row[7]}" class="toggle-item inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" ${collected ? " checked" : ""}><div class="hidden">${collected}</div>
      `
    },
    { targets: 1, className: "font-medium text-gray-900 truncate"},
    { targets: 2, className: "truncate hidden sm:table-cell" },
    { targets: 3, className: "truncate hidden lg:table-cell" },
    { targets: 4, className: "truncate hidden md:table-cell" },
    { targets: 5, className: "truncate hidden lg:table-cell" },
    { targets: 6, render: url => (url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null) },
    { targets: 7, render: id => `<a href="${id}" class="text-indigo-600 hover:text-indigo-900">Edit</a>` },
    { targets: 8, render: id => `<a href="${id}" class="text-red-600 hover:text-red-900"><svg  class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></a>` },
  ],
  dom: `<"table-header"lf>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  initComplete: function () {
    // Apply the search
    this.api()
        // filter hideDisplayed
        .column(0)
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
  language: {search: "", searchPlaceholder: "Search...", emptyTable: "No items to show. Select some mods first!"},
  order: [[ 1, 'asc' ]],
  pagingType: "simple",
  // rowId: row => `item-${row[7]}`,
  stateSave: true
}).on('draw init', function() { onDraw(itemTable) })

// toggle hidden items
$("#toggle-hidden").on("click", () => {
  hideCollected = !hideCollected
  itemTable.column( 0 ).search(hideCollected ? "false" : "").draw()
  $("#toggle-hidden svg").toggleClass("hidden")
})

// toggle item
$("#item-table").on("change", ".toggle-item", e => {
  e.stopPropagation()
  id = $(e.target).data("id")
  cell = $(e.target).closest("td")
  // Assign handlers immediately after making the request,
  // and remember the jqXHR object for this request
  var jqxhr = $.ajax( `/character/toggle/${id}`, { method: "PUT"} )
  .done(({collected}) => {
    // on succes toggle data in cell and redrawn
    itemTable.cell(cell).data(collected).column( 0 ).search(hideCollected ? "false" : "").draw()
  })
})

var modTable = $('#mod-table').DataTable({
  autoWidth: false,
  dom: `<"table-header"lf>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  order: [[ 2, 'desc' ]],
  pagingType: "simple",
  stateSave: true,
  language: {search: "", searchPlaceholder: "Search..."},
  columnDefs: [
    { targets: [0, 2, 3, 4, 5, 6], searchable: false },
    { targets: [0, 4, 5, 6], orderable: false },
    { targets: 0, visible: $('#mod-table').hasClass("has-user") },
    { targets: 1},
    { targets: [5, 6], visible: $('#mod-table').hasClass("moderator")}
  ]
}).on('draw init', function() { onDraw(modTable); })

modTable.draw()

$('#character-table').DataTable({
  autoWidth: false,
  dom: '<"table-wrapper"t>',
  order: [[ 4, 'desc' ]],
  searching: false,
  stateSave: true,
  paging: false,
  columnDefs: [
    { targets: [2, 3, 4] },
    { targets: [0, 5, 6], orderable: false }
  ]
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

// enable dismissing of alerts
$(".alert button").on("click", el => {
  $(el.currentTarget).closest(".alert").remove()
})

// enable login
if(document.getElementById("login-button")){
  document.getElementById("login-button").addEventListener("click", () => connect())
}
if(document.getElementById("login-button-mobile")){
  document.getElementById("login-button-mobile").addEventListener("click", () => connect())
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
window.liveSocket = liveSocket
