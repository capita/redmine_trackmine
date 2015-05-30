$(document).ready(function ($) {
  $('#tracker_project_id').on('change', function() {
    var tracker_project_id = $(this).val();
    $.ajax('/mappings/update_labels', {
      success: function(response) {
        $.each(response, function(index, label){
          $('#mapping_label').append("<option value=" + label +">"+ label + "</option>");
        });
      },
      data: { 'tracker_project_id': tracker_project_id }
    });
  });
});