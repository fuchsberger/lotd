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

// helper function to populate a form via jquery
// usage example: populate('#MyForm', character, $.parseJSON(data));
function populate (frm, struct, data) {
  $.each(data, function(key, value){
    $(`[name="${struct}[${key}]"]`, frm).val(value);
  });
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
  let {action, formdata, struct} = $(e.target).data()

  populate(".data-form", struct, formdata)

  $(".data-form").attr("action", action)
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
