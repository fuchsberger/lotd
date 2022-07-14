import $ from 'jquery'
import "phoenix_html"
import "./timeago"
import connect from './nexus'
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
  ajax: "/api/item",
  autoWidth: false,
  rowId: row => `entry-${row[7]}`,
  columnDefs: [
    { targets: [6, 7, 8], orderable: false, searchable: false},
    { targets: 0,
      orderable: false,
      visible: $('#item-table').hasClass("has-character"),
      type: "html",
      render: (collected, display, row) => `
        <input type="checkbox" data-id="${row[7]}" class="toggle inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" ${collected ? " checked" : ""}><div class="hidden">${collected}</div>
      `
    },
    { targets: 1, className: "font-medium text-gray-900 truncate"},
    {
      targets: 2,
      className: "truncate hidden sm:table-cell",
      render: location_id => `${$("#item-table").data("regions")[location_id] || ""}`
    },
    {
      targets: 3,
      className: "truncate hidden lg:table-cell",
      render: region_id => `${$("#item-table").data("regions")[region_id] || ""}`
    },
    {
      targets: 4,
      className: "truncate hidden md:table-cell",
      render: display_id => `${$("#item-table").data("displays")[display_id]}`
    },
    {
      targets: 5,
      className: "truncate hidden lg:table-cell" ,
      render: room_id => `${$("#item-table").data("rooms")[room_id]}`
    },
    { targets: 6, render: url => (url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null) },
    { targets: 7,
      visible: $('#item-table').hasClass("moderator"),
      render: (id, unknown, row) => {
        let data = JSON.stringify({
          name: row[1],
          location_id: row[2],
          display_id: row[4],
          mod_id: row[8],
          url: row[6]
        })
        return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-action="/api/item/${id}" data-struct="item" data-formdata='${data}'>Edit</button>`
      }
    },
    {
      targets: 8,
      visible: $('#item-table').hasClass("moderator"),
      data: 7, render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></a>` },
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
  ajax: "/api/mod",
  autoWidth: false,
  dom: `<"table-header"lf>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  order: [[ 2, 'desc' ]],
  rowId: row => `entry-${row[5]}`,
  pagingType: "simple",
  stateSave: true,

  language: {search: "", searchPlaceholder: "Search..."},
  columnDefs: [
    { targets: [0, 2, 3, 4, 5, 6], searchable: false },
    { targets: [0, 4, 5, 6], orderable: false },
    { targets: [5, 6], visible: $('#mod-table').hasClass("moderator")},
    { targets: 0,
      visible: $('#mod-table').hasClass("has-user"),
      type: "html",
      render: (active, display, row) => `
        <input type="checkbox" data-id="${row[5]}" class="toggle-mod inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" ${active ? " checked" : ""}><div class="hidden">${active}</div>`
    },
    { targets: 1, className: "font-medium text-gray-900 truncate"},
    { targets: 2, className: "hidden sm:table-cell text-right pr-12"},
    { targets: 3, className: "hidden md:table-cell text-right pr-10"},
    { targets: 4, render: url => (url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null) },
    { targets: 5, type: "html", render: (id, unknown, row) => {
      let data = JSON.stringify({ name: row[1] })
      return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-action="/api/character/${id}" data-struct="character" data-formdata='${data}'>Edit</button>`
    }
    },
    { targets: 6, type: "html", data: 5, render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>` }
  ]
}).on('draw init', function() { onDraw(modTable); })

var characterTable = $('#character-table').DataTable({
  ajax: "/api/character",
  autoWidth: false,
  dom: '<"table-wrapper"t>',
  order: [[ 4, 'desc' ]],
  searching: false,
  stateSave: true,
  paging: false,
  rowId: row => `entry-${row[5]}`,
  columnDefs: [
    { targets: [2, 3, 4] },
    { targets: [0, 5, 6], orderable: false, type: "html" },
    { targets: 0,
      type: "html",
      render: (active, display, row) => `
        <input type="radio" data-id="${row[5]}" class="activate-btn inline-block cursor-pointer focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300" ${active ? " checked" : ""}><div class="hidden">${active}</div>
      `
    },
    { targets: [0, 5, 6], type: "html" },
    { targets: 1, className: "font-medium text-gray-900 truncate"},
    { targets: 2, className: "pr-12 text-right"},
    {
      targets: 3,
      className: "hidden md:table-cell",
      render: date => `<time datetime="${date}Z">${date}</time>`
    },
    {
      targets: 4,
      className: "hidden sm:table-cell",
      render: date => `<time datetime="${date}Z">${date}</time>`
    },
    { targets: 5, render: (id, unknown, row) => {
        let data = JSON.stringify({ name: row[1] })
        return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-action="/api/character/${id}" data-struct="character" data-formdata='${data}'>Edit</button>`
      }
    },
    { targets: 6, data: 5, render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>` }
  ]
}).on('draw init', function() { $("time").timeago() })

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

// helper function to populate a form via jquery
// usage example: populate('#MyForm', character, $.parseJSON(data));
function populate(frm, struct, data) {
  $.each(data, function(key, value){
    $(`[name="${struct}[${key}]"]`, frm).val(value);
  });
}

$("#item-form").on("submit", function(e) {
  e.preventDefault()

  $(".data-form-alert").addClass("hidden")

  var action = $(e.target).attr("action")
  var data = {
    item: {
      name: $("#input-name").val(),
      url: $("#input-url").val(),
      location_id: $("#input-location-id").val(),
      mod_id: $("#input-mod-id").val(),
      display_id: $("#input-display-id").val()
    }
  }

  var method = (action.split("/").length - 1) == 3 ? "PUT" : "POST"
  $.ajax(action, { data, method })
  .done(data => {
    if (data.success){
      if( method == "PUT") {
        itemTable.row(`#entry-${data.item[7]}`).data(data.item).draw()
      } else {
        itemTable.row.add(data.item).draw()
      }

      $("#data-form-modal").addClass("hidden")
      $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
    } else {
      $("#data-form-alert").removeClass("hidden")
    }
  })
})

$("#mod-form").on("submit", function(e) {
  e.preventDefault()

  $(".data-form-alert").addClass("hidden")

  var action = $(e.target).attr("action")
  var data = {
    mod: { name: $("#input-name").val(), url: $("#input-url").val() }
  }

  var method = (action.split("/").length - 1) == 3 ? "PUT" : "POST"
  $.ajax(action, { data, method })
  .done(data => {
    if (data.success){
      if( method == "PUT") {
        modTable.row(`#entry-${data.mod[5]}`).data(data.mod).draw()
      } else {
        modTable.row.add(data.mod).draw()
      }

      $("#data-form-modal").addClass("hidden")
      $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
    } else {
      $("#data-form-alert").removeClass("hidden")
    }
  })
})

$("#character-form").on("submit", function(e) {
  e.preventDefault()

  $("#data-form-alert").addClass("hidden")

  var action = $(e.target).attr("action")
  var data = {
    character: { name: $("#input-name").val() }
  }

  var method = (action.split("/").length - 1) == 3 ? "PUT" : "POST"
  $.ajax(action, { data, method })
  .done(data => {
    if (data.success){
      if( method == "PUT") {
        characterTable.row(`#entry-${data.character[5]}`).data(data.character).draw()
      } else {
        characterTable.row.add(data.character).draw()
      }

      $("#data-form-modal").addClass("hidden")
      $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
    } else {
      $("#data-form-alert").removeClass("hidden")
    }
  })
})

// enables creation and updating of items
$("#add-btn").on("click", e => {
  e.stopPropagation()
  let {action, formdata, struct} = $(e.currentTarget).data()

  populate(".data-form", struct, formdata)
  $(".data-form").attr("action", action)
  $("#title-prefix").text(`New`)
  $("#create-btn").removeClass("hidden")
  $("#update-btn").addClass("hidden")
  $("#data-form-modal").removeClass("hidden")
  $("#data-form-modal").find(".backdrop,.panel").removeClass("hidden")
})

// enables creation and updating of entries
$(".dataTable").on("click", ".edit-btn", e => {
  e.stopPropagation()
  let {action, formdata, struct} = $(e.target).data()

  populate(".data-form", struct, formdata)

  $(".data-form").attr("action", action)
  $("#title-prefix").text(`Update`)
  $("#create-btn").addClass("hidden")
  $("#update-btn").removeClass("hidden")
  $("#data-form-modal").removeClass("hidden")
  $("#data-form-modal").find(".backdrop,.panel").removeClass("hidden")
})

$("#data-form-modal .cancel").on("click", e => {
  e.stopPropagation()
  $("#data-form-modal").addClass("hidden")
  $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
})

// enables deleting of items (with confirm modal)
$(".dataTable").on("click", ".open-delete-modal", e => {
  e.stopPropagation()
  const id = $(e.currentTarget).data("id")

  $("#delete-btn").data("id", id)
  $("#delete-modal").toggleClass("hidden")
  $("#delete-modal").find(".backdrop,.panel").toggleClass("hidden")
})

$("#delete-modal .cancel").on("click", e => {
  e.stopPropagation()
  $("#delete-modal").toggleClass("hidden")
  $("#delete-modal").find(".backdrop,.panel").toggleClass("hidden")
})

$("#delete-btn").on("click", e => {
  let {id, struct} = $(e.currentTarget).data()

  $.ajax(`/api/${struct}/${id}`, { method: "DELETE"} )
  // on succes remove row and redraw table
  .done(({deleted_id}) => {
    switch(struct){
      case "character": characterTable.rows(`#entry-${deleted_id}`).remove().draw(); break
      case "item": itemTable.rows(`#entry-${deleted_id}`).remove().draw(); break
      case "mod": modTable.rows(`#entry-${deleted_id}`).remove().draw(); break
      default:
    }

    $("#delete-modal").addClass("hidden")
    $("#delete-modal").find(".backdrop,.panel").addClass("hidden")
  })
})

// enable activation of characters
$("#character-table").on("click", ".activate-btn", e => {
  e.preventDefault()

  const id = $(e.currentTarget).data("id")

  $.ajax(`/api/character/${id}/activate`, { method: "PUT"} )
  // on succes update row and redraw table
  .done(data => {
    if(data.success){
      // update old row
      let oldCellData = characterTable.row(`#entry-${data.old_active_id}`).data()

      if(oldCellData){
        oldCellData[0] = false
        characterTable.row(`#entry-${data.old_active_id}`).data(oldCellData)
      }

      let newCellData = characterTable.row(`#entry-${id}`).data()
      newCellData[0] = true

      $(".character-name").text(newCellData[1])

      characterTable
      .row(`#entry-${id}`).data(newCellData)
      .draw()
    }
  })
})

// enable toggling of mods
$("#mod-table").on("click", ".toggle-mod", e => {
  e.preventDefault()

  const id = $(e.currentTarget).data("id")

  $.ajax(`/api/mod/${id}/toggle`, { method: "PUT"} )
  // on succes update row and redraw table
  .done(data => {
    if(data.success){
      // update old row
      let newData = modTable.row(`#entry-${id}`).data()
      newData[0] = !newData[0]

      modTable
      .row(`#entry-${id}`).data(newData)
      .draw()
    }
  })
})

// enable toggling of mods
$("#item-table").on("click", ".toggle", e => {
  e.preventDefault()

  const id = $(e.currentTarget).data("id")

  $.ajax(`/api/item/${id}/toggle`, { method: "PUT"} )
  // on success update row and redraw table
  .done(data => {
    if(data.success){
      // update old row
      let newData = itemTable.row(`#entry-${id}`).data()
      newData[0] = data.collected

      itemTable
      .row(`#entry-${id}`).data(newData)
      .draw()
    }
  })
})

// // enable toggling of all mods
// $("#toggle-all").on("click", e => {
//   e.preventDefault()

//   $.ajax(`/api/item/toggle-all`, { method: "PUT"} )
//   // on success update row and redraw table
//   .done(data => {
//     if(data.success){
//       location.reload() // TODO: set all column 1 to true or false
//     }
//   })
// })


