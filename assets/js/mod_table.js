import $ from "jquery"
import { editBtn, deleteBtn, urlBtn, onDraw } from "./tables"

var moderator = $('#item-table').hasClass("moderator")

var modTable = $('#mod-table').DataTable({
  ajax: "/api/mod",
  autoWidth: false,
  dom: `<"table-header"lf>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  order: [[ 2, 'desc' ]],
  rowId: row => `entry-${row[5]}`,

  paging: false,
  searching: false,
  columnDefs: [
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
    { targets: 4, data: 5, visible: moderator, render: editBtn },
    { targets: 5, data: 5, visible: moderator, render: deleteBtn },
    { targets: 6, data: 4, render: urlBtn }
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
