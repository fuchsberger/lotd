import $ from "jquery"
require( 'datatables.net' )( window, $ );

$.ajaxSetup({ headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') } });

export function onDraw (table) {
  var info = table.page.info()

  var {start, end, recordsDisplay, recordsTotal} = info

  var filterText = recordsDisplay == recordsTotal ? ""
    : ` (filtered from <span class="font-medium">${recordsTotal}</span> entries)`

  var html = `<p class="text-sm text-gray-700">Showing <span class="font-medium">${start+1}</span> to <span class="font-medium">${end}</span> of <span class="font-medium">${recordsDisplay}</span> entries${filterText}</p>`

  $('#table-info').html(html);
}

export function editBtn (id) {
  return `<button type="button" class="edit-btn text-indigo-600 hover:text-indigo-900" data-id="${id}"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg></button>`
}

export function deleteBtn (id) {
  return `<button data-id="${id}" type="button" class="open-delete-modal text-red-600 hover:text-red-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></a>`
}

export function urlBtn (url) {
  return url ? `<a target="_blank" href="${url}" class="text-indigo-600 hover:text-indigo-900"><svg class="inline-block h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg></a>`: null
}

// helper function to populate a form via jquery
// usage example: populate('#MyForm', character, $.parseJSON(data));
function populate (frm, struct, data) {
  $.each(data, function(key, value){
    $(`[name="${struct}[${key}]"]`, frm).val(value);
  });
}

// helper function to get the struct from a table
// usage example: struct(any element in table);
function get_struct(element) {
  return $(element).closest("table")[0].id.split("-")[0]
}

// enables creation of entries
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

// enables updating of entries
$(".dataTable").on("click", ".edit-btn", e => {
  e.stopPropagation()

  let struct = get_struct(e.currentTarget)
  let id = $(e.currentTarget).data("id")
  let rowdata = $(`#${struct}-table`).dataTable().api().row(`#entry-${id}`).data()
  let formdata

  switch(struct){
    case "item":
      formdata = {
        name: rowdata[1],
        location_id: rowdata[2],
        mod_id: rowdata[6],
        url: rowdata[8]
      }
      break;

    case "location":
      formdata = {name: rowdata[1], region_id: rowdata[2]}
      break;

    case "region":
      formdata = {name: rowdata[0]}
      break;

    case "mod":
      formdata = {name: rowdata[1], url: rowdata[4]}
      break;
  }

  populate(".data-form", struct, formdata)

  $(".data-form").attr("action", `/api/${struct}/${id}`)
  $("#title-prefix").text(`Update`)
  $("#create-btn").addClass("hidden")
  $("#update-btn").removeClass("hidden")
  $("#data-form-modal").removeClass("hidden")
  $("#data-form-modal").find(".backdrop,.panel").removeClass("hidden")
})

// enables closing of modals
$("#data-form-modal .cancel").on("click", e => {
  e.stopPropagation()
  $("#data-form-modal").addClass("hidden")
  $("#data-form-modal").find(".backdrop,.panel").addClass("hidden")
})

// enables deleting of items
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
  // on success remove row and redraw table
  .done(({deleted_id}) => {
    $(`#${struct}-table`).dataTable().api().rows(`#entry-${deleted_id}`).remove().draw();
    $("#delete-modal").addClass("hidden")
    $("#delete-modal").find(".backdrop,.panel").addClass("hidden")
  })
})

$("#clear-filters").on("click", e => {
  e.stopPropagation()

  var table = $(e.target).closest("table").DataTable()

  table
  .columns()
  .every(function () {
    var column = this;

    $('input', this.header()).val("")
    $('select', this.header()).val("")

    column.search('', true, false).draw()
  })
})
