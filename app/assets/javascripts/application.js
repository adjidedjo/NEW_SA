// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//

//--- Angle
//= require penjualan_salesman
//= require dashboard
//= require tables
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-select/dist/js/bootstrap-select.min
//= require_tree ./angle/

$(function(){

    $('form').on('click', '.remove_record', function(event) {
        $(this).prev('input[type=hidden]').val('1');
        $(this).closest('tr').hide();
        return event.preventDefault();
    });

    $('form').on('click', '.add_fields', function(event) {
        var regexp,
            time;
        time = new Date().getTime();
        regexp = new RegExp($(this).data('id'), 'g');
        $('.fields').append($(this).data('fields').replace(regexp, time));
        return event.preventDefault();
    });

}); 