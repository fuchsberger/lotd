import $ from "jquery"
import { editBtn, deleteBtn, urlBtn, onDraw } from "./tables"

var hideCollected = false
var moderator = $('#item-table').hasClass("moderator")

var itemTable = $('#item-table').DataTable({
  ajax: "/api/item",
  autoWidth: false,
  rowId: row => `entry-${row[7]}`,
  columnDefs: [
    { targets: [0, 2, 3, 4, 5, 6, 7, 8], searchable: false},
    { targets: 0,
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
      render: location_id => `${$("#item-table").data("locations")[location_id] || ""}`
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
    { targets: 7, data: 7, visible: moderator, render: editBtn },
    { targets: 8, data: 7, visible: moderator, render: deleteBtn },
    { targets: 9, data: 8, render: urlBtn }
  ],
  dom: `<"table-wrapper"t><"table-footer"<"#table-info">p>`,
  initComplete: function () {
    // Apply the search
    this.api()
    // filter hideDisplayed
    .column(0)
    .search(hideCollected ? "false" : "")
    // search individual columns
    .columns()
    .every(function () {
      var column = this;

      // input boxes
      $('input', this.header()).on('keyup change clear', function () {
          if (column.search() !== this.value) {
            column.search(this.value).draw();
          }
      });

      // select boxes
      $('select', this.header()).on("change", e => {
        let type = e.target.name.split("[")[1].slice(0, -1) + "s"
        let val = $("#item-table").data(type)[e.target.value] || ""
        column.search(val).draw();
      })
    });
  },
  language: {search: "", searchPlaceholder: "Search...", emptyTable: "No items to show. Select some mods first!"},
  orderable: false,
  pageLength: 100,
  pagingType: "simple",
  lengthChange: false,
  // paging: false,
}).on('draw init', function() { onDraw(itemTable) })

// toggle hidden items
$("#toggle-hidden").on("click", () => {
  hideCollected = !hideCollected
  itemTable.column( 0 ).search(hideCollected ? "false" : "").draw()
  $("#toggle-hidden svg").toggleClass("hidden")
})

$("#item-table thead input").on("click", e => {
  e.stopPropagation()
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
