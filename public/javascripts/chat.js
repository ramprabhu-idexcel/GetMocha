(function($) {
  initial_setup();
  
  Socky.prototype.respond_to_message = function(msg) {
    data = JSON.parse(msg);	
    if(data[3]==$('#chat_project_id').val())
    {
      var chat_content='<div class="message recent"><div class="color" style="background-color:#'+data[1].color+'"></div>';
      chat_content+='<div class="name"><span>'+data[1].name+'</span></div>';
      chat_content+='<div class="content most-recent">'+data[2]+'</div></div>'
      $('.chat-container').prepend(chat_content);
    }
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
  
  
  $('#chat-message').live('keypress',function(){
    var chat=$('#chat-message').val();
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
//~ $('#people_settings_popup').live('click',function(){
//~ $('.modal invite-modal').toggle()
//~ });
//~ function add_people_settings()
//~ {
//~ document.getElementById('add_people').style.display="block";
//~ document.getElementById('invite_message').value="";
//~ document.getElementById('invite_name').value="";
//~ document.getElementById('invite_email').value="";
//~ }

//~ function send_people_invite()
//~ {
//~ proj_id=document.getElementById('project_id').value;
//~ name=document.getElementById('invite_name').value;
//~ email=document.getElementById('invite_email').value;
//~ message=document.getElementById('message').value;
//~ var pars = "project_id=" + proj_id +  "&name="+ name +  "&email="+ email +  "&message="+ message;
//~ $.ajax({
       //~ type :'get',
       //~ url : "/projects/invite_people_settings?"+pars,
			  //~ success: function(data){
				//~ if(data.length==1)
				//~ document.getElementById('add_people').style.display="none";
							//~ document.getElementById('invite_name').value="";
			//~ document.getElementById('invite_email').value="";
			//~ document.getElementById('message').value="";
				//~ }
    //~ });
//~ }
//~ function cancel_people_invite()
//~ {
			//~ document.getElementById('add_people').style.display="none";
			//~ document.getElementById('invite_name').value="";
			//~ document.getElementById('invite_email').value="";
			//~ document.getElementById('message').value="";
//~ }