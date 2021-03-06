// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){

  $('.language_to').click(function(){
    var language_to = $.trim($(this).attr('lang_sym'));
    $.ajax({
      type: 'POST',
      url: Routes.translation_center_set_lang_to_path(),
      data: { lang : language_to },
      success: function(){
        location.reload();
      }
    });
  });

  $('.language_from').click(function(){
    var language_from = $.trim($(this).attr('lang_sym'));
    $.ajax({
      type: 'POST',
      url: Routes.translation_center_set_lang_from_path(),
      data: { lang : language_from },
      success: function(){
        location.reload();
      }
    });

  });

  $("body").on({
    ajaxStart: function() { 
      $('#loading').show();
    },
    ajaxStop: function() { 
      $('#loading').hide();
    }    
  });

});
