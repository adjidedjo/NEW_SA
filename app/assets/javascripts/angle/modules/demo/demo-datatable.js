// Demo datatables
// -----------------------------------

(function(window, document, $, undefined){

  if ( ! $.fn.dataTable ) return;

  $(function(){

    //
    // Zero configuration
    //
    
    $('#credit_checks').dataTable({
        'paging':   false,  // Table pagination
        'ordering': false,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#credit_limits').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#index-marketshare-brands').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#customerold-table').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#new-customer-table').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        'columns': [
            null,
            null,
            null,
            null,
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            null,
            { type: 'num-fmt' },
            null
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#customer-report-table').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        'columns': [
            null,
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' }
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#bp-table').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        'columns': [
            null,
            null,
            { type: 'num-fmt' }
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#productivities').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#table-revenue').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        columns: [
            null,
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' }
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        }
    });
    
    $('#table-revenue-products').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        initComplete: function () {
            this.api().columns().every( function () {
                var column = this;
                var select = $('<select><option value=""></option></select>')
                    .appendTo( $(column.footer()).empty() )
                    .on( 'change', function () {
                        var val = $.fn.dataTable.util.escapeRegex(
                            $(this).val()
                        );
 
                        column
                            .search( val ? '^'+val+'$' : '', true, false )
                            .draw();
                    } );
 
                column.data().unique().sort().each( function ( d, j ) {
                    select.append( '<option value="'+d+'">'+d+'</option>' )
                } );
            } );
        },
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#table-revenue-branches-national').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        columns: [
            null,
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' }
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>lTfgitp',
        buttons: [
            {extend: 'print', className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'}
        ]
    });
    
    $('#table-revenue-branch').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        columns: [
            null,
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' },
            { type: 'num-fmt' }
        ],
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        }
    });
    
    $('#stock-table').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>lTfgitp',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#most_item').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#held_orders').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#table-revenue-salesman').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        }
    });
    
    $('#salesman_customer').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#salesman_weekly').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#salesman_product').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#salesman_city').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>lTfgitp',
        buttons: [
            {extend: 'print', className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'}
        ]
    });
    
    $('#datatable_city').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });

    $('#table_without_filter1').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });

    $('#table_without_filter2').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });

    $('#datatable2').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });

    $('#datatable1').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#datatable_product').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });
    
    $('#datatable_customer').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // Datatable Buttons setup
        dom: '<"html5buttons"B>frtip',
        buttons: [
            'print', 'csvHtml5'
        ]
    });


    //
    // Filtering by Columns
    //

    var dtInstance2 = $('#datatable2').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': true, // https://datatables.net/extensions/responsive/examples/
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        }
    });
    var inputSearchClass = 'datatable_input_col_search';
    var columnInputs = $('tfoot .'+inputSearchClass);

    // On input keyup trigger filtering
    columnInputs
      .keyup(function () {
          dtInstance2.fnFilter(this.value, columnInputs.index(this));
      });


    //
    // Column Visibilty Extension
    //

    $('#datatable3').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': true, // https://datatables.net/extensions/responsive/examples/
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search:',
            sLengthMenu:  '_MENU_ records per page',
            info:         'Showing page _PAGE_ of _PAGES_',
            zeroRecords:  'Nothing found - sorry',
            infoEmpty:    'No records available',
            infoFiltered: '(filtered from _MAX_ total records)'
        },
        // set columns options
        'aoColumns': [
            {'bVisible':false},
            {'bVisible':true},
            {'bVisible':true},
            {'bVisible':true},
            {'bVisible':true}
        ],
        sDom:      'C<"clear">lfrtip',
        colVis: {
            order: 'alfa',
            'buttonText': 'Show/Hide Columns'
        }
    });

    //
    // AJAX
    //

    $('#datatable4').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': true, // https://datatables.net/extensions/responsive/examples/
        sAjaxSource: '/api/datatable',
        aoColumns: [
          { mData: 'engine' },
          { mData: 'browser' },
          { mData: 'platform' },
          { mData: 'version' },
          { mData: 'grade' }
        ]
    });
  });

})(window, document, window.jQuery);
