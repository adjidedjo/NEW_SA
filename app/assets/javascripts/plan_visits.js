// Place all the behaviors and hooks related to the matching controller here.



//--- Filestyle
//= require bootstrap-filestyle/src/bootstrap-filestyle
//--- Tags input
//= require bootstrap-tagsinput/dist/bootstrap-tagsinput.min
//--- Chosen
//= require chosen_v1.2.0/chosen.jquery.min
//--- Slider ctrl
//= require seiyria-bootstrap-slider/dist/bootstrap-slider.min
//--- Input Mask
//= require jquery.inputmask/dist/jquery.inputmask.bundle
//--- Wysiwyg
//= require bootstrap-wysiwyg/bootstrap-wysiwyg
//= require bootstrap-wysiwyg/external/jquery.hotkeys
//--- Parsley
//= require parsleyjs/dist/parsley.min
//--- Moment
//= require moment/min/moment-with-locales.min
//--- DatetimePicker
//= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
//--- Upload
//= require jquery-ui/ui/widget
//= require blueimp-tmpl/js/tmpl
//= require blueimp-load-image/js/load-image.all.min
//= require blueimp-canvas-to-blob/js/canvas-to-blob
//= require blueimp-file-upload/js/jquery.iframe-transport
//= require blueimp-file-upload/js/jquery.fileupload
//= require blueimp-file-upload/js/jquery.fileupload-process
//= require blueimp-file-upload/js/jquery.fileupload-image
//= require blueimp-file-upload/js/jquery.fileupload-audio
//= require blueimp-file-upload/js/jquery.fileupload-video
//= require blueimp-file-upload/js/jquery.fileupload-validate
//= require blueimp-file-upload/js/jquery.fileupload-ui
//--- xEditable
//= require x-editable/dist/bootstrap3-editable/js/bootstrap-editable.min
//--- Validate
//= require jquery-validation/dist/jquery.validate
//--- Steps
//= require jquery.steps/build/jquery.steps
// --- ColorPicker
//= require mjolnic-bootstrap-colorpicker/dist/js/bootstrap-colorpicker.js
// --- Cropper
//= require cropper/dist/cropper.js
// --- Select2
//= require select2/dist/js/select2

jQuery(function() {

    $('form').on('click', '.remove_record', function(event) {
        $(this).prev('input[type=hidden]').val('1');
        $(this).closest('tr').hide();
        return event.preventDefault();
    });
    
    $('#plan_visit_customer_plan_visits_attributes_0_customer').autocomplete({
        source : $('#plan_visit_customer_plan_visits_attributes_0_customer').data('cus-source'),
        messages: {
          noResults: '',
          results: ''
        }
    });

    $('form').on('click', '.add_fields', function(event) {
        var regexp,
            time;
        time = new Date().getTime();
        regexp = new RegExp($(this).data('id'), 'g');
        $('.fields').append($(this).data('fields').replace(regexp, time));
        $('#plan_visit_customer_plan_visits_attributes_' + time + '_customer').autocomplete({
            source : $('#plan_visit_customer_plan_visits_attributes_' + time + '_customer').data('cus-source'),
            messages: {
                noResults: '',
                results: ''
            }
        });
        return event.preventDefault();

        
    });
});

