import $ from "jquery"
import { editBtn, deleteBtn, urlBtn, onDraw } from "./tables"

var hideCollected = false
var moderator = $('#item-table').hasClass("moderator")

var itemTable = $('#item-table').DataTable({
  ajax: "/api/item",
  autoWidth: false,
  rowId: row => `entry-${row[7]}`,
  columnDefs: [
    { targets: [7, 8], searchable: false},
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
  language: {search: "", searchPlaceholder: "Search...", emptyTable: "No items to show. Select some mods first!"},
  lengthChange: false,
  ordering: false,
  pageLength: 100,
  pagingType: "simple",


}).on('draw init', function() { onDraw(itemTable) })

// Search functionality
$('#item-filter-form').on("change", () => search())

function search (){
  let data = $("#item-filter-form").serializeArray().slice(1).reduce(function(obj, item) {
    obj[item.name] = item.value || "";
    return obj;
  }, {});

  data.display = data.display ? $("#item-table").data("displays")[data.display] : ""
  data.location = data.location ? $("#item-table").data("locations")[data.location] : ""
  data.region = data.region ? $("#item-table").data("regions")[data.region] : ""
  data.room = data.room ? $("#item-table").data("rooms")[data.room] : ""
  data.mod = data.mod ? $("#item-table").data("mods")[data.mod] : ""

  itemTable
  .column(0).search(hideCollected ? "false" : "")
  .columns([1,2,4]).search(data.name)
  .column(2).search(data.location ? '^' + data.location + '$' : '', true, false)
  .column(3).search(data.region ? '^' + data.region + '$' : '', true, false)
  .column(4).search(data.display ? '^' + data.display + '$' : '', true, false)
  .column(5).search(data.room ? '^' + data.room + '$' : '', true, false)
  .column(6).search(data.mod ? '^' + data.mod + '$' : '', true, false)
  .draw()
}
$('#item-filter-form').on("submit", e => {e.preventDefault()})
$('#item-filter-form_name').on("keyup", () => search())

// toggle hidden items
$("#toggle-hidden").on("click", () => {
  hideCollected = !hideCollected
  // itemTable.column( 0 ).search(hideCollected ? "false" : "").draw()
  $("#toggle-hidden svg").toggleClass("hidden")
  search()
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
