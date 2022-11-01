// Demo datatables
// -----------------------------------

(function(window, document, $, undefined){

  if ( ! $.fn.dataTable ) return;

  $(function(){

    //
    // Zero configuration
    //
    
    $('#table-revenue-accessories').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        'scrollX': true,
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
        ]
    });
    
    $('#table-aging-stock').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': true,
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        initComplete: function () {
            this.api().columns([0,1]).every( function () {
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
    
    
    
    $('#table-revenue-branches-national-scroll').dataTable({
        'paging':   false,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     false,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'filter': false,
        'scrollX': true,
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
        ]
    });
    
    $('#datatable_outstanding_order').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'order': [[ 8, "desc" ]],
        'aoColumnsDefs': [
            { "sType": "numeric", "aTargets": [ 8 ] }
         ],
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
        ]
    });
    
    $('#outs_order_all_brand').dataTable({
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        'responsive': false, // https://datatables.net/extensions/responsive/examples/
        'order': [[ 9, "desc" ]],
        'aoColumnsDefs': [
            { "sType": "numeric", "aTargets": [ 9 ] }
         ],
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
        ]
    });
    
    $('#datatable_customer_active').dataTable({
        'paging':   true,  // Table pagination
        'order': [[4, 'desc'], [ 5, 'desc' ]],  // Column ordering
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
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
