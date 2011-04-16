(function($) {
  initial_setup();
  
  
  $('a.project').live('click',function(){
    $('a.project').removeClass('open');
    $(this).addClass('open');
  });
  
  
  
  
  
  
  function initial_setup()
  {
    $('body').attr('class','chat');
    document.title= "Chats | Mocha";
    $('.sort-by.task-sort').hide();
    $('#reply_comment').hide();
    $('.star.star_items').hide();
    $('#trash_message').hide();
    $('.task_header').hide();
  }


 })(jQuery);