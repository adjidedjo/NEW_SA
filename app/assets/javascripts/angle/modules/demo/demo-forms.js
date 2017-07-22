// Forms Demo
// -----------------------------------

(function(window, document, $, undefined) {

    $(function() {

        // BOOTSTRAP SLIDER CTRL
        // -----------------------------------

        if ($.fn.slider)
            $('[data-ui-slider]').slider();

        // CHOSEN
        // -----------------------------------

        if ($.fn.chosen)
            $('.chosen-select').chosen();

        // MASKED
        // -----------------------------------

        if ($.fn.inputmask)
            $('[data-masked]').inputmask();

        // FILESTYLE
        // -----------------------------------

        if ($.fn.filestyle)
            $('.filestyle').filestyle();

        // WYSIWYG
        // -----------------------------------

        if ($.fn.wysiwyg)
            $('.wysiwyg').wysiwyg();

        // DATETIMEPICKER
        // -----------------------------------

        if ($.fn.datetimepicker) {
            var d = new Date();
            $('#datepicker1').datetimepicker({
                icons : {
                    time : 'fa fa-clock-o',
                    date : 'fa fa-calendar',
                    up : 'fa fa-chevron-up',
                    down : 'fa fa-chevron-down',
                    previous : 'fa fa-chevron-left',
                    next : 'fa fa-chevron-right',
                    today : 'fa fa-crosshairs',
                    clear : 'fa fa-trash'
                },
               format : 'DD/MM/YYYY',
               // minDate: d.setDate(d.getDate()-2),
               maxDate: new Date()
            }).attr('readonly', 'true');
            // marketshare
            $('#datems1').datetimepicker({
                icons : {
                    time : 'fa fa-clock-o',
                    date : 'fa fa-calendar',
                    up : 'fa fa-chevron-up',
                    down : 'fa fa-chevron-down',
                    previous : 'fa fa-chevron-left',
                    next : 'fa fa-chevron-right',
                    today : 'fa fa-crosshairs',
                    clear : 'fa fa-trash'
                },
                viewMode : 'months',
                format : 'MM/YYYY'
               // minDate: d.setDate(d.getDate()-2),
               // maxDate: new Date()
            }).attr('readonly', 'true');
            // marketshare
            $('#datems2').datetimepicker({
                icons : {
                    time : 'fa fa-clock-o',
                    date : 'fa fa-calendar',
                    up : 'fa fa-chevron-up',
                    down : 'fa fa-chevron-down',
                    previous : 'fa fa-chevron-left',
                    next : 'fa fa-chevron-right',
                    today : 'fa fa-crosshairs',
                    clear : 'fa fa-trash'
                },
                viewMode : 'months',
                format : 'MM/YYYY'
               // minDate: d.setDate(d.getDate()-2),
               // maxDate: new Date()
            }).attr('readonly', 'true');
            // only time
            $('#datetimepicker2').datetimepicker({
                format : 'LT'
            });
            // View mode
            $('#datetimepicker3').datetimepicker({
                viewMode : 'months',
                format : 'MM/YYYY'
            });

        }

    });

})(window, document, window.jQuery);
