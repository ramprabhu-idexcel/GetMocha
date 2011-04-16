(function($) {
  initial_setup();
  
  Socky.prototype.respond_to_message = function(msg) {
    data = JSON.parse(msg);	

    alert(data);
  }
  
  
  $('a.project').live('click',function(){
    $('a.project').removeClass('open');
    $(this).addClass('open');
    var project_id=$(this).attr('href').split('#')[1];
    $('#chat_project_id').val(project_id);
    $('.r-panel').show();
  });
  
  
  $('#chat-send').live('click',function(){
    var chat=$('#chat-message').val();
    var project_id=$('#chat_project_id').val();
    $.ajax({
      url:'/chats',
      type: 'post',
      data:{'chat[message]':chat,
            'chat[project_id]':project_id}
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
    $('.r-panel').hide();
  }


 })(jQuery);