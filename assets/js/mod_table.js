import $ from "jquery"
import { onDraw } from "./tables"

var modTable = $('#mod-table').DataTable({
  ajax: "/api/mod",
  autoWidth: false,
  dom: `<"table-header"lf>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  order: [[ 2, 'desc' ]],
  rowId: row => `entry-${row[5]}`,
  pagingType: "simple",
  language: {search: "", searchPlaceholder: "Search..."},
  columnDefs: [
    { targets: [0, 2, 3, 4, 5, 6], searchable: false },
    { targets: [0, 4, 5, 6], orderable: false },
    { targets: [4, 5], visible: $('#mod-table').hasClass("moderator")},
    { targets: 0,
      visible: $('#mod-table').hasClass("has-user"),
      type: "html",
      render: (active, display, row) => `
        <input type="checkbox" data-id="${row[5]}" class="toggle-mod inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" ${active ? " checked" : ""}><div class="hidden">${active}</div>`
    },
    { targets: 1, className: "font-medium text-gray-900 truncate"},
    { targets: 2, className: "hidden sm:table-cell text-right pr-12"},
    { targets: 3, className: "hidden md:table-cell text-right pr-10"},
    {
      targets: 4,
      type: "html",
      data: 5,
      render: (id, unknown, row) => {
        let data = JSON.stringify({ name: row[1] })
        return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-action="/api/mod/${id}" data-struct="mod" data-formdata='${data}'>Edit</button>`
      }
    },
    {
      targets: 5,
      type: "html",
      data: 5,
      render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>`
    },
    {
      targets: 6,
      data: 4,
      render: url => (url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null)
    }
  ]
}).on('draw init', function() { onDraw(modTable); })

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
