import $ from 'jquery'
import 'datatables.net'
import 'timeago'

import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()

    // enable timeago on table redraw
    $("#character-table").on('draw.dt', function() {
      $("time").timeago()
    });


    let table = $('#character-table').DataTable({
      dom: 't',
      paging: false,
      info: false
    });

    let info = table.page.info()

    $('.total-count').text(info.recordsTotal)

    $('#search').on('keyup', function(){
      table.search( this.value ).draw()
      let info = table.page.info()

      $('.total-count').text(info.recordsTotal)
      if(info.recordsTotal != info.recordsDisplay) $('.filtered-count').text(info.recordsDisplay + ' / ')
      else $('.filtered-count').text("")
    })

    this.table = table
  }

  unmount() {
    this.table.destroy()
    super.unmount()
  }
}
