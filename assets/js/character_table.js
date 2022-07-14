import $ from "jquery"
import { onDraw } from "./tables"

var characterTable = $('#character-table').DataTable({
  ajax: "/api/character",
  autoWidth: false,
  dom: '<"table-wrapper"t>',
  order: [[ 4, 'desc' ]],
  searching: false,
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
