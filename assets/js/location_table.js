import $ from "jquery"
import { onDraw } from "./tables"

var locationTable = $('#location-table').DataTable({
  ajax: "/api/location",
  autoWidth: false,
  dom: `<"table-header"f>
        <"table-wrapper"t>
        <"table-footer"<"#table-info">p>`,
  order: [[ 1, 'asc' ]],
  rowId: row => `entry-${row[3]}`,
  pageLength: 100,
  pagingType: "simple",
  language: {search: "", searchPlaceholder: "Search..."},
  columnDefs: [
    { targets: [0, 2, 4, 5], searchable: false },
    { targets: [0, 4, 5], orderable: false },
    { targets: [4, 5], visible: $('#location-table').hasClass("moderator")},
    {
      targets: 0,
      data: null,
      defaultContent: `
        <button type="button" class="details">
          <svg class="inline-block h-5 w-5 text-indigo-600 hover:text-indigo-900" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
          </svg>
          <svg class="hidden h-5 w-5 text-indigo-600 hover:text-indigo-900" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7" />
          </svg>
        </button>
      `,
    },
    { targets: 1, data: 1, className: "font-medium text-gray-900 truncate"},
    {
      targets: 2, data: 0,
      className: "hidden sm:table-cell text-right pr-8",
      render: items => items.length
    },
    {
      targets: 3, data: 2,
      className: "truncate hidden lg:table-cell",
      render: region_id => `${$("#location-table").data("regions")[region_id] || ""}`
    },
    {
      targets: 4,
      type: "html",
      data: 3,
      render: id => {
        return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-id="${id}">Edit</button>`
      }
    },
    {
      targets: 5,
      type: "html",
      data: 3,
      render: id => `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>`
    }
  ]
}).on('draw init', function() { onDraw(locationTable); })

/* Formatting function for row details - modify as you need */
function formatRegionExtraData(d) {
  var elements = []
  for(el of d[0]){
    elements.push($("#location-table").data("items")[el])
  }

  return `<span class="text-xs text-gray-500 w-full whitespace-normal">${elements.join(", ")}</span>`
}

// Add event listener for opening and closing details
$('#location-table tbody').on('click', '.details', function () {
  var tr = $(this).closest('tr');
  var row = locationTable.row(tr);

  if (row.child.isShown()) {
    // This row is already open - close it
    row.child.hide();
  } else {
    // Open this row
    row.child(formatRegionExtraData(row.data())).show();
  }
  $(this).find('svg').toggleClass("hidden inline-block")
});

$("#location-form").on("submit", function(e) {
  e.preventDefault()

  $(".data-form-alert").addClass("hidden")

  var action = $(e.target).attr("action")
  var data = {
    location: { name: $("#input-name").val(), region_id: $("#input-region-id").val() }
  }

  var method = (action.split("/").length - 1) == 3 ? "PUT" : "POST"
  $.ajax(action, { data, method })
  .done(data => {
    if (data.success){
      if( method == "PUT") {
        locationTable.row(`#entry-${data.location[3]}`).data(data.location).draw()
      } else {
        locationTable.row.add(data.location).draw()
      }

      $("#data-form-modal").addClass("hidden")
      $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
    } else {
      $("#data-form-alert").removeClass("hidden")
    }
  })
})
