(function($) {
  initial_setup();
  $.unread_count={};
  $.prev_user_id=0;
  $.chat_ids=[];
  $(window).load(function() {
    var page = window.location.hash;
    if(page!="")
    {
      
      var project_id=page.split('#')[1];
      $('#cp'+project_id).addClass('open');
      $('#cp'+project_id).click();
    }
  });
  
  Socky.prototype.respond_to_message = function(msg) {
    data = JSON.parse(msg);	
    //for chat messages
    if(data[0]=="chat")
    {
      if($.inArray(data[5],$.chat_ids)<0)
      {
        $.chat_ids.push(data[5]);
        if(data[3]==parseInt($('#chat_project_id').val()))
        {
          var chat_class="";
          if($.prev_user_id==data[1].id)
          {
          chat_class="same-user";
          }
          else
            chat_class="";
          $.prev_user_id=data[1].id;
          var chat_content='<div class="message recent '+chat_class+'"><div class="color" style="background-color:#'+data[1].color+'"></div>';
          chat_content+='<div class="name"><span>'+data[1].name+'</span></div>';
          chat_content+='<div class="content most-recent">'+data[2];
          var image_attachments=data[4].attach_image;
          var file_attachments=data[4].attached_documents;
          if(file_attachments.length>0 && image_attachments.length>0)
          {
            chat_content+='<div class="attachments">';
            //File attachments
            if(file_attachments.length>0)
            {
              $.each(file_attachments,function(index,value){
                chat_content+=(value+'<br />');
              });
            }
            
            //Image attachments
            if(image_attachments.length>0)
            {
              chat_content+=('<div class="attachments">');
              $.each(image_attachments,function(index,value){
                chat_content+=('<div class="attachment-thumb-frame">'+value+'</div>');
              });
              chat_content+=('<div class="clear-fix"></div>')
              chat_content+=('</div>');
            }
             chat_content+=('</div>');
          }
          chat_content+=('</div></div>');
          $('.chat-container').prepend(chat_content);
        }
      }
    }
    else if(data[0]=="count")
    {
        if(typeof($.unread_count[data[1]])!="undefined")
          $.unread_count[data[1]]+=1;
        else
          $.unread_count[data[1]]=1;
        show_unread_count(data[1],$.unread_count[data[1]]);
    }
    //for online users
    else if(data[0]=="online_users")
    {
      if($('#cp'+data[1].project_id).hasClass('open') && $('#ui'+data[1].id).length==0)
      {
        var content=add_online_users(data[1]);
        $('.m-panel').append(content.join(''));
      }
    }
    // to remove the offline users
    else if(data[0]=="offline_users")
    {
      if($('#cp'+data[1].project_id).hasClass('open') && $('#ui'+data[1].id).length>0)
        remove_online_user(data[1]);
    }
  }
  
  function add_online_users(user)
  {
    var items=[];
    var alt_class="";
    alt_class=($('.m-tab:last').hasClass('alt') ? "" : "alt");
    items.push('<div id="ui'+user.id+'" class="m-tab '+alt_class+'">');
    items.push('<div class="left-icons">');
    items.push('<div class="avatar-mini"></div>');
    items.push('<img src="'+user.image+'" class="avatar-mini-img" alt="avatar"/>');
    items.push('</div>');
    items.push('<div class="info">');
    items.push('<span class="position">'+user.title+'</span><br/>');
    items.push('<span class="name">'+user.name+'</span>');
    items.push('<span class="p-number"></span>');
    items.push('<span class="email"><a href="mailto:'+user.email+'">'+user.email+'</a></span>');
    items.push('</div>');
    items.push('<div class="clear-fix"></div>');
    items.push('</div>');
    return items;
  }
  
  function remove_online_user(user)
  {
    if($('#ui'+user.id).length>0)
      $('#ui'+user.id).remove();
  }
  
  function show_unread_count(project_id,count)
  {
    var project_link=$('#cp'+project_id);
    if(project_link.length>0 && !project_link.hasClass('open'))
    {
      var project_name=project_link.text();
      if(count==0)
      {
        project_link.html('<span class="icon"></span>'+project_name);
        project_link.removeClass('has-unread');
      }
      else
      {
        project_link.html('<span class="num-unread">'+count+'</span><span class="icon"></span>'+project_name);
        project_link.addClass('has-unread');
      }
    }
  }
  
  $('a.project').live('click',function(){
    if($('.project.open').length>0)
      var old_project_id=$('.project.open').attr('id').split('cp')[1];
    else
      var old_project_id="";
    $('a.project').removeClass('open');
    $(this).addClass('open');
    var project_name=$(this).html().split('<span class="icon"></span>')[1];
    var project_id=$(this).attr('href').split('#')[1];
    $(this).html('<span class="icon"></span>'+project_name);
    $(this).removeClass('has-unread');
     $.unread_count[project_id]=0;
    if(old_project_id==project_id)
      old_project_id="";
    $.ajax({
      url:'/chats/'+project_id+'/project_chat?old='+old_project_id,
      type: 'get',
      success:function(data){
        if($('.m-panel-contain').length>0)
          $('.m-panel-contain').remove();
        if($('.r-panel-contain').length>0)
          $('.r-panel-contain').remove();
        $(data).insertAfter('.l-panel-contain');
      }
    });
    $('.chat-header').show();
    $('.r-panel').show();
    $('#chat-message').focus();
  });
  
  
  $('#chat-send').live('click',function(){
    var chat=$('#chat-message').val();
    var project_id=get_project_id();
    send_chat();
  });
  
  $('#chat-message').live('keypress',function(event){
    if(event.keyCode==13)
    {
      send_chat();
    }
  });
  
  function send_chat()
  {
    var chat=$('#chat-message').val();
    var project_id=get_project_id();
    if($.trim(chat)!="")
    {
      $.ajax({
        url:'/chats',
        type: 'post',
        data:{'chat[message]':chat,
              'chat[project_id]':project_id}
      });
      $('#chat-message').val('');
      $('.attach-contain').hide();
      $('#attachment_files').html('');
    }
    $('#chat-message').focus();
  }
  
  $('.popout').live('click',function(){
    var project_id=get_project_id()
    window.open('/popout-chat/'+project_id, 'Chat'+project_id, 'width = 580, height = 670, scrollbars,resizable,status');
  });
  
  $(window).unload(function()
  { 
    /*if($('.project.open').length>0)
      var old_project_id=$('.project.open').attr('id').split('cp')[1];
    else
      var old_project_id="";*/
      //alert("Bye for now");
    
  });
  
 

  
  function lastPostFunc()
  {
    alert('scrolling');
  }
  
  function get_project_id()
  {
    return $('#chat_project_id').val();
  }
  
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
     $('.chat-header').hide();
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
