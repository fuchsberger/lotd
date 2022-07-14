import $ from "jquery"
import { onDraw } from "./tables"

var hideCollected = false

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
    {
      targets: 6,
      className: "truncate hidden xl:table-cell" ,
      render: mod_id => `${$("#item-table").data("mods")[mod_id]}`
    },
    { targets: 7,
      data: 7,
      visible: $('#item-table').hasClass("moderator"),
      render: (id, unknown, row) => {
        let data = JSON.stringify({
          name: row[1],
          location_id: row[2],
          display_id: row[4],
          mod_id: row[6],
          url: row[8]
        })
        return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-action="/api/item/${id}" data-struct="item" data-formdata='${data}'>Edit</button>`
      }
    },
    {
      targets: 8,
      data: 7,
      visible: $('#item-table').hasClass("moderator"),
      render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></a>`
    },
    {
      targets: 9,
      data: 8,
      render: url => (url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null)
    }
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
  pagingType: "simple"
}).on('draw init', function() { onDraw(itemTable) })

// toggle hidden items
$("#toggle-hidden").on("click", () => {
  hideCollected = !hideCollected
  itemTable.column( 0 ).search(hideCollected ? "false" : "").draw()
  $("#toggle-hidden svg").toggleClass("hidden")
})


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

// enable toggling of items
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
