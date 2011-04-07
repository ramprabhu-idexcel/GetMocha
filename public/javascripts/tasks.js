(function($) {
  initial_setup();

  //first pane
  $('.all-tasks, .my-tasks, .starred, .completed').live('click',function(){
    var clicked=$(this);
    first_pane_class(clicked);
  });

  $('.project').live('click',function(){
    var clicked=$(this);
    first_pane_class(clicked);
    var project_id=clicked.attr('id').split('tpi')[1];
    window.location.hash='#'+project_id;
    return false;
  });
  
  
  //complete/reopen the tasks
  $(".checkbox > span.icon.icon-sec").live('click',function(){
    $(this).toggleClass('checked');
    var tk_id=$(this).attr('class').split(' ')[0];
    var task_id=tk_id.split(':')[1];
    $.ajax({
      url:'/tasks/complete_task',
      type:'put',
      data:{id : task_id}
    });
    return false;
  });

  $(".checkbox > span.icon.icon-thd").live('click',function(){
    $(this).toggleClass('checked');
    $('.task.tsem.open').children('.left-icons').children('.checkbox').children('span').toggleClass('checked');
    var task_id=get_task_id();
    $.ajax({
      url:'/tasks/complete_task',
      type:'put',
      data:{id : task_id}
    });
    return false;
  });
  
  $('.task.tsem').live('click',function(){
    var activity_id=$(this).attr('class').split(' ')[0].split('actk:')[1];
    var has_url=window.location.hash;
    $('.task.tsem').removeClass('open');
    $(this).addClass('open');
    if(has_url=="")
      var secondary_url="all_tasks";
    else
      var secondary_url=(window.location.hash).split('#')[1].split('/')[0];
    window.location.hash="#"+secondary_url+"/"+activity_id;
    $('.task_header').show();
  });
  
  $('.filed-tasklist').live('click',function(){
    $('.task-dropdown.task_list').fadeToggle();
    return false;
  });
  
  $('a.assigned-to').live('click',function(){
    $('.task-dropdown.assigned-to').fadeToggle();
    return false;
  });
  
  //subscribe tasks
  $('.task-subscribe').live('click',function(){
    return false;
  });
  
  $('.expand_user').live('click',function(){
    return false;
  });
  
  $('a.edit.task_name').live('click',function(){
    var content=$(this).siblings('span').text();
    $(this).parent('h2').html('<textarea class="textfield" name="task[name]" rows="" cols="" id="task_name">'+content+'</textarea><a class="edit save_taskname" href="#" style="display: inline;">Save</a>');
    return false;
  });
  
  $('a.edit.task_description').live('click',function(){
    var content=$(this).siblings('span').text();
    $(this).parent('p').html('<textarea class="textfield" style="height: 160px;" cols="" rows="" onfocus="this.select()" id="task_description" name="task[description]">'+content+'</textarea><a class="edit save_task_desc" href="#" style="display: inline;">Save</a>');
    return false;
  });
  
  $('a.edit.save_taskname').live('click',function(){
    var content=$('#task_name').val();
    if($.trim(content)=="")
      alert("Please enter the task name");
    else
    {
      var task_id=$('div.message-body').children('span.tsk-det').attr('id').split('tk:')[1];
      var save_link=$(this);
      $.ajax({
        url:'/tasks/'+task_id,
        type:'put',
        data:{'task[name]':content},
        success:function(data){
          if(data=="success")
            save_link.parent('h2').html('<span>'+content+'</span><a class="edit task_name" href="#">Edit</a>');
          else
            alert(data);
        }
      });
    }
    return false;
  });
  
  $('a.edit.save_task_desc').live('click',function(){
    var content=$('#task_description').val();
    if($.trim(content)=="")
      alert("Please enter the task description");
    else
    {
      var task_id=get_task_id();
      var save_link=$(this);
      $.ajax({
        url:'/tasks/'+task_id,
        type:'put',
        data:{'task[description]':content},
        success:function(data){
          if(data=="success")
            save_link.parent('p').html('<span>'+content+'</span><a class="edit task_description" href="#">Edit</a>');
          else
            alert(data);
        }
      });
    }
    return false;    
  });
  //subscribe
  $('.task-subscribe').live('click',function(){
    var id=get_activity_id();
    var content=$(this).text();
    $.ajax({
      url:'/subscribe/'+id,
      type: 'get'
    });
    var result = (content=="Subscribe" ? "Unsubscribe" : "Subscribe");
    $(this).text(result);
  });
  //task comments
  $('#reply_comment_task').live('click',function(){
    $('.comment-contain').slideToggle('slow',function(){
      $('.attachment').remove();	
      $('#comment-message').focus();
    });
    return false;  
  });
  
  
  
  $('.blue-33.add_comment').live('click',function(){
    if($.trim($('#comment-message').val())=="")
    {
      alert('Please enter a Comment ');
    }
    else
    {
      var activity_id=get_activity_id();
      $('#act').val(activity_id);
      var reply="";
      $.ajax({
        url: '/comments',
        type: 'post',
        data: $('form#add_com_msg').serialize(),
        success:function(data){
          attach=data.attach;
          var comment=data.comment[0];
          reply+=('<div class="message message_comments '+(comment.is_starred ? "starred" : "" )+' " ><div class="message-body"><a class="message-star star_comment" href="/star_message/'+comment.id+'">Star</a>');
          if(attach==false)
          reply+=('<a class="name message_name" href="#">'+comment.user+'</a><span class="message-time">'+comment.created_at+'</span>');
          else
          reply+=('<a class="name message_name" href="#">'+comment.user+'</a>');
          if((comment.attach.attach_image.length>0) || (comment.attach.attached_documents.length>0))
          reply+='<div class="has-attachment"></div>';
          reply+=('<span class="message-time">'+comment.created_at+'</span>');
          reply+=('<div class="comment"><p>'+comment.comment+'</p>');
          if(comment.attach.attached_documents.length>0)
          {
            reply+=('<div style="margin-top:20px;margin-bottom:20px;">')
            $.each(comment.attach.attached_documents,function(index,value){
              reply+=('<p>'+value+'</p>');
            });
            reply+=('</div>')
          }
          if(comment.attach.attach_image.length>0)
          {
            reply+=('<div class="attachments">');
            $.each(comment.attach.attach_image,function(index,value){
              reply+=('<div class="attachment-thumb-frame">'+value+'</div>');
            });
            reply+=('<div class="clear-fix"></div></div>');
          }
          reply+=('<a class="reply-link" href="#">Reply</a></div></div></div>');
          $('.prev-messages').append(reply).show('slow');
          close_comment_area();
          if($('.message.message_comments').length>9)
            $('.expand-all').show();
          $('.attachment').remove();
        }
      });
    }
    return false;
  });
  
  $('#trash_task').live('click',function(){
  var yes=confirm('Are you sure?');
  var task_id=get_task_id();
  if(yes)
  {
    var task_id=get_task_id();
    $('.task.tsem.open').remove();
    $.ajax({
      url:'/tasks'+task_id,
      type:'delete'
    });
  }
  return false;
  });
  
  //star the tasks
  $('.star.task_star, a.task-star').live('click',function(){
    if($('.task.tsem.open').length>0)
    {
      var id=get_activity_id();
      var parent_div=$('.task.tsem.open');
      parent_div.children().children('a.task-star').toggle();
    }
    else
    {
      var id=$(this).parent().parent().attr('class').split(' ')[0].split('actk:')[1];
      var parent_div=$(this).parent().parent();
      $(this).toggle();
    }
    parent_div.toggleClass('starred')
    $.ajax({
      url: '/star_message/'+id,
      type: 'get',
      data:{'task':true},
      success:function(data)
      { 
        display_star_count(data.count);
      }
    });
    return false;
  });
  
  //star the comment
  $('.message-star.star_comment').live('click',function(){
    var path=$(this).attr('href');
    $(this).parent('div.message-body').parent('div.message').toggleClass('starred');
    $.ajax({
      url: path,
      type: 'get',
      success:function(data)
      { 
        display_star_count(data.count);
      }
    });
    return false;
  });
  
  //edit task list
  $('a.sec.task_list').live('click',function(){
    var content=$(this).text();
    $(this).parent('.sub-header').html('<input type="text" class="tklist textfield" value="'+content+'"></input>');
    $('.tklist.textfield').focus();
    return false;
  });
  
  $('.tklist').live('blur',function(){
    var task_list_id=$(this).parent('.sub-header').attr('id').split('tl')[1];
    var content=$(this).val();
    $.ajax({
      url: '/task_lists/'+task_list_id,
      type:'put',
      data:{'task_list[name]' : content}
    });
    $(this).parent('.sub-header').html('<a class="sec task_list" href="#">'+content+'</a>');
    return false;
  });
  
  $('.sort-by').live('click',function(){
    return false;
  });
  
  $('.tkl-down').live('click',function(){
    $('.tkl-down').removeClass('selected');
    $(this).addClass('selected');
    var task_list=$(this).children('span').attr('class').split('tkl:')[1];
    var task_id=get_task_id();
    $.ajax({
      url:'tasks/'+task_id,
      type:'put',
      data:{'task[task_list_id]' : task_list}
    });
  });
  
  var restfulApp = Backbone.Controller.extend({
    restfulUrl: $.host,
    routes: {
    ':all_task'   : 'allTask',
    ':all_task/:activity_id' : 'taskComment',
    },
    allTask: function(page){
      if(page=="")
      {
        page="all_tasks";
        $('.all-tasks').addClass('open');
      }
      var restfulPageUrl = this.restfulUrl+'tasks/'+ page  
      this.loadRestfulData( restfulPageUrl );
    },
    taskComment: function(page){
      var hash_url=window.location.hash;
      var activity_id=hash_url.split('/')[1];
      var restfulPageUrl = this.restfulUrl +'tasks/task_comment/'+ activity_id;  
      this.loadCommentData( restfulPageUrl );
    },
    loadRestfulData: function( pageUrl ){
      $.ajax({
        url: pageUrl,
        success: function(data){
          load_second_pane(data);
        }
      });
    },
    loadCommentData: function( pageUrl ){
      $.ajax({
        url: pageUrl,
        success: function(data){
          load_third_pane(data);
        }
      });
    }
  });

  function load_second_pane(data)
  {
    var items=[];
    $.each(data,function(index,value){
      items.push('<div class="sub-header" id="tl'+value[0].activity.resource.task_list_id+'"><a href="#" class="sec task_list">'+value[0].activity.resource.task_list_name+'</a></div>');
      $.each(value,function(i,v){
        var starred=v.activity.is_starred;
        items.push('<div class="actk:'+v.activity.id+' task tsem '+(starred ? "starred" : "")+'"><div class="left-icons">');
        items.push('<a class="task-star" href="#" '+(starred ? '' : 'style="display:none;"')+'>Star</a>');    
        items.push('<div class="checkbox"><span class="tk:'+v.activity.resource_id+' icon icon-sec '+(v.activity.resource.is_completed ? "checked" : "")+'"></span></div></div>');
        items.push('<div class="info">');
        items.push('<span class="task-time '+due_date_class(v.activity.resource.due_date_value)+'">'+v.activity.resource.due_date_value+'</span>');
        items.push('<span class="name">'+v.activity.resource.assigned_to+'</span>');
        items.push('</div>');
        items.push('<div class="task-name"><h4>'+v.activity.resource.name+'</h4></div>');
        items.push('<div class="clear-fix"/></div>');        
      });
    });
    $('.m-panel').html(items.join(''));
    $('.sort-by').show();
  }
  
  function load_third_pane(data)
  {
    var items=[];
    task=data.task;
    items.push('<div class="message-body">')
    items.push('<span style="display:none;" class="tsk-det" id="tk:'+task.id+'"></span>')
    items.push('<span style="display:none;" class="tsk-detlt" id="tklt'+task.task_list_id+'"></span>')
    items.push('<div class="checkbox"><span class="icon icon-thd '+(task.is_completed ? "checked":"")+'"></span></div>');
    items.push('<h2><span>'+task.name+'</span><a class="edit task_name" href="#">Edit</a></h2>');
    items.push('<p class="filed-under">Filed under <a class="filed-tasklist" href="#">'+task.task_list_name+'</a></p>');
    //other task-list-names
    items.push('<div class="task-dropdown task_list" style="display:none;">');
    items.push('<div class="task-dropdown-t"></div>');
    items.push('<ul>');
    $.each(task.other_task_lists,function(i,v){
      items.push('<li class="tkl-down '+(task.task_list_id==v.task_list.id ? "selected" : "")+'"><span class="tkl:'+v.task_list.id+'">'+v.task_list.name+'</span></li>');
    });      
    items.push('</ul>');
    items.push('</div>');
    items.push('<p class="recipients">Assigned to <a class="assigned-to" href="#">'+task.assigned_to+'</a></p><hr/>');
    //other teammembers
    items.push('<div class="task-dropdown assigned-to" style="display:none;">');
    items.push('<div class="task-dropdown-t"></div>');
    items.push('<ul>');
    $.each(task.team_members,function(i,v){
      items.push('<li class="" id="ul:'+v.id+'"><span>'+v.name+'</span></li>');
    });
    items.push('</ul>')
    
    items.push('<input type="text" onfocus="this.select()" onclick="this.value=\'\';"class="textfield" value="Invite by email" name="assign"/>');
    items.push('<a class="invite-btn" href="#">+</a>');
    items.push('</div>');
    items.push('<div class="main-content"><p><span>'+task.description+'</span><a class="edit task_description" href="#">Edit</a></p></div>');
    items.push('<p class="subscribers">'+task.subscribe+' <a class="task-subscribe" href="#">unsubscribe</a></p>');
    items.push('</div>');
    //comments
    items.push('<div class="prev-messages">');
    $.each(data.comments,function(index,comment){
      items.push('<div class="message message_comments '+(comment.is_starred ? "starred" : "" )+' " ><div class="message-body"><a class="message-star star_comment" href="/star_message/'+comment.id+'">Star</a>');
      items.push('<a class="name message_name" href="#">'+comment.user+'</a>');
      if((comment.attach.attached_documents.length>0) || (comment.attach.attach_image.length>0))
        items.push('<div class="has-attachment"></div>');
      items.push('<span class="message-time">'+comment.created_at+'</span>');
      items.push('<div class="comment"><p>'+comment.comment+'</p>');
      if(comment.attach.attached_documents.length>0)
      {
        items.push('<div style="margin-top:20px;margin-bottom:20px;">')
        $.each(comment.attach.attached_documents,function(index,value){
          items.push('<p>'+value+'</p>');
        });
        items.push('</div>')
      }
      if(comment.attach.attach_image.length>0)
      {
        items.push('<div class="attachments">');
        $.each(comment.attach.attach_image,function(index,value){
          items.push('<div class="attachment-thumb-frame">'+value+'</div>');
        });
        items.push('<div class="clear-fix"></div></div>');
      }
      items.push('<a class="reply-link" href="#">Reply</a></div></div></div>');
    });
    items.push('</div>')
    $('#comment_area').html(items.join(''));
  }
  
  function due_date_class(date_value)
  {
    switch(date_value)
    {
    case "Today":
      return "today";
    case "Yesterday":
      return "overdue";
    default:
      return "";
    }
  }
  
  function initial_setup()
  {
    $('body').attr('class','tasks');
    document.title= "Tasks | Mocha";
    $('.sort-by').hide();
    $('#reply_comment').hide();
    $('.star.star_items').hide();
    $('#trash_message').hide();
    $('.task_header').hide();
  }
  
  function first_pane_class(clicked){
    $('.all-tasks, .my-tasks, .starred, .completed, .project').removeClass('open');
    clicked.addClass('open');
  }
  
  function get_activity_id()
  {
    return $('.task.tsem.open').attr('class').split(' ')[0].split('actk:')[1];
  }
  
  function get_task_id()
  {
    return $('div.message-body').children('span.tsk-det').attr('id').split('tk:')[1];
  }
  
  function display_star_count(count){
    if(count==0)
      $('a.starred.starred_count').html('<span class="icon"></span>Starred' );
    else
      $('a.starred.starred_count').html('<span class="num-tasks">'+count+'</span><span class="icon"></span>Starred' );
  }
  
  var app = new restfulApp;
  Backbone.emulateHTTP = true;
  Backbone.emulateJSON = true
  Backbone.history.start();


 })(jQuery);