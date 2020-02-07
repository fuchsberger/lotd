import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {

  mount() {
    super.mount()

    // initialize Datatable
    $('#item-table').DataTable({
      ajax: '/api/items',
      columns: [
        { name: "id", visible: false },
        { name: "name", title:  "Name" },
        { name: "url", orderable: false },
      ],
      dom:
        "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'d-flex justify-content-center'i>",
      deferRender: true,
      initComplete: () => $('#loader-wrapper').hide(),
      order: [[1, 'asc']],
      rowId: 0,
      scrollY: 'calc(100vh - 185px)',
      scrollCollapse: true,
      scroller: true,
      stateSave: true
    })
  }

  unmount() {
    super.unmount()
  }
}

