import $ from 'jquery'
import dt from 'datatables.net'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    let table = $('#user-table').DataTable({
      dom: 't',
      paging: false,
      info: false
    });

    /* Custom filtering function which will search data in column four between two values */
    $.fn.dataTable.ext.search.push(
      function( settings, data, dataIndex ) {
          var min = parseInt( $('#min').val(), 10 );
          var max = parseInt( $('#max').val(), 10 );
          var age = parseFloat( data[3] ) || 0; // use data for the age column

          if ( ( isNaN( min ) && isNaN( max ) ) ||
              ( isNaN( min ) && age <= max ) ||
              ( min <= age   && isNaN( max ) ) ||
              ( min <= age   && age <= max ) )
          {
              return true;
          }
          return false;
      }
    );

    $('#search').on('keyup', function(){
      table.search( this.value ).draw()
    })
  }

  unmount() {
    super.unmount()
  }
}
