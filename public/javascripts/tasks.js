(function($) {
  $('body').attr('class','tasks');
  document.title= "Tasks | Mocha";

  //first pane
  $('.project').live('click',function(){
    $('.project').removeClass('open');
    $(this).addClass('open');
    return false;
  });


 })(jQuery);