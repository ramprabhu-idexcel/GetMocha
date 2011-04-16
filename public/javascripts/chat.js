(function($) {
  initial_setup();
  
  
  
  
  $('a.project').live('click',function(){
    $('a.project').removeClass('open');
    $(this).addClass('open');
  });
  
  
  $('#chat-send').live('click',function(){
    var chat=$('#chat-message').val();
    $.ajax({
      url:'/chats',
      type: 'post',
      data:{'chat[message]':chat}
    });
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