(function($) {
  initial_setup();

  //first pane
  $('.all-tasks, .my-tasks, .starred, .completed').live('click',function(){
    var clicked=$(this);
    $('.sort-by-tooltip').hide();
    $('#comment_area').hide();
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
      data:{id : task_id},
      success:function(data){
        tasks_count(data);
        }
    });
    
    $(".checkbox > span.icon.icon-thd").toggleClass('checked');
    $('#comment_area').fadeOut('fast');
    var second_pane=$(this).parent().parent().parent();
    second_pane.fadeOut(700,function(){
      if(second_pane.prev().hasClass('sub-header') && (second_pane.next().hasClass('sub-header') || second_pane.next().length==0))
        second_pane.prev().remove();
    });
    return false;
  });

  $(".checkbox > span.icon.icon-thd").live('click',function(){
    $(this).toggleClass('checked');
    var second_pane=$('.task.tsem.open');
    second_pane.children('.left-icons').children('.checkbox').children('span').toggleClass('checked');
    var task_id=get_task_id();
    $.ajax({
      url:'/tasks/complete_task',
      type:'put',
      data:{id : task_id},
      success:function(data){
        tasks_count(data);
      }
    });
    $('#comment_area').fadeOut('fast');
    $('.task.tsem.open').fadeOut(700,function(){
    if(second_pane.prev().hasClass('sub-header') && second_pane.next().hasClass('sub-header'))
      second_pane.prev().remove();
      
    });
    return false;
  });
  
  
  $('.task.tsem').live('click',function(){
    if($(this).attr('class').search('starred') > -1)
            $('#task_star').css('background-position','-108px -29px');
        else
        $('#task_star').css('background-position','-108px -59px');
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
    var width=$('.filed-tasklist').width();
    var half=parseInt(width)/2.0;
    var left=half+37.25;
    $('.task-dropdown.task_list').css('left',left);
    $('.task-dropdown.task_list').fadeToggle();
    return false;
  });
  
  $('a.assigned-to').live('click',function(){
    var width=$('a.assigned-to').width();
    var left_pos=$('a.assigned-to').position().left;
    var half=parseInt(width)/2.0;
    var left=left_pos+half-107;
    $('.task-dropdown.assigned-to').css('left',left);
    $('.task-dropdown.assigned-to').fadeToggle();
    return false;
  });
    
  $('.expand_user').live('click',function(){
      var subscribe=$('.task-subscribe').text();
      var content=$('#all_subscribed').html();
      $('p.subscribers').html('Subscribed: '+content+'<a href="#" id="subscribe_task" class="task-subscribe"> '+subscribe+'</a>');
    return false;
  });
  
  $('a.edit.task_name').live('click',function(){
    var content=$(this).siblings('span').text();
    $(this).parent('h2').html('<textarea class="textfield" name="task[name]" rows="" cols="" id="task_name">'+content+'</textarea><a class="edit save_taskname" href="#" style="display: inline;">Save</a>');
    return false;
  });
  
  $('a.edit.task_description').live('click',function(){
    var content=$(this).siblings('span').text();
    $(this).parent('p').html('<textarea class="textfield" style="height: 160px;" cols="" rows="" onfocus="this.select()" id="task_description" name="task[description]">'+content+'</textarea><a class="edit save_task_desc" href="#" >Save</a><div class="clear-fix"></div>');
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
          if(typeof(data)=="object")
            alert(data.error);
          else
          {
            save_link.parent('h2').html('<span>'+content+'</span><a class="edit task_name" href="#">Edit</a>');
            $('.task.tsem.open').children('.task-name').children('h4').text(truncate_task_name(content));
          }
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
          if(typeof(data)=="object")
            alert(data.error);
          else
            save_link.parent('p').html('<span>'+content+'</span><a class="edit task_description" href="#">Edit</a>');
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
      type: 'get',
      success:function(data){
        var task=data.task;
        var result = data.subscribe;
        $('.subscribers').html('<p class="subscribers">'+task.subscribe+'<span id="all_subscribed" style="display:none;">'+task.all_subscribed+'</span><a id="subscribe_task" class="task-subscribe" href="#"> '+result+'</a></p>');
      }
    });
    
return false;
  });
  //task comments
  $('#reply_comment_task').live('click',function(){
         if ($('.comment-contain').css('display')=="none")
      {
      $('.comment-contain').show();
      }
      else
      {
      $('.comment-contain').hide();
      }
    //~ $('.comment-contain').slideToggle('slow',function(){
      $('.attachment').remove();	
      $('#comment-message').focus();
    //~ });
    return false;  
  });
  
  
  
  $('.blue-33.add_comment').live('click',function(){
    if($(this).hasClass('upload_in_progress'))
    {
      return false;
    }
    else
    {
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
          reply+=('<a class="reply-link" href="#">Reply</a></div></div><div class="clear-fix"></div></div>');
          $('.prev-messages').append(reply).show('slow');
          close_comment_area();
          if($('.message.message_comments').length>9)
            $('.expand-all').show();
          $('.attachment').remove();
        }
      });
    }
    return false;
  }
  });
  
  $('#trash_task').live('click',function(){
  var yes=confirm('Are you sure?');
  var task_id=get_task_id();
  if(yes)
  {
    var task_id=get_task_id();
    $('.task.tsem.open').remove();
    $.ajax({
      url:'/tasks/'+task_id,
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
      url: '/star_message/'+id+'?task=true',
      type: 'get',
      data:{'task':true},
      success:function(data)
      { 
        display_star_count(data.count);
        if(parent_div.hasClass('starred'))
        $('#task_star').css('background-position','-108px -29px');
        else
        $('#task_star').css('background-position','-108px -59px');
      }
    });
    return false;
  });
  
  //star the comment
  $('.message-star.star_comment').live('click',function(){
    var path=$(this).attr('href')+'?task=true';
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
    var task_header=$(this);
    $.ajax({
      url: '/task_lists/'+task_list_id,
      type:'put',
      data:{'task_list[name]' : content},
      success:function(data){
        if(typeof(data)=="object")
          alert(data.error);
        else
        task_header.parent('.sub-header').html('<a class="sec task_list" href="#">'+content+'</a>');
      }
    });
    
    return false;
  });
  
  $('.sort-by.task-sort').live('click',function(){
    $('.sort-by-tooltip.task-sort-down').toggle();
    return false;
  });
  
  $('.sort.sort-task').live('click',function(){
    $('.sort.sort-task').removeClass('selected');
    $(this).addClass('selected');
    if(window.location.hash.split('#').length>1)
    {
      var first_url=window.location.hash.split('#')[1].split('/')[0];
      var has_url=first_url.split('?')[0];
    }
    else
      var has_url=window.location.hash.split('#')[0]+'all_tasks';
    window.location.hash=has_url+'?sort_by='+$(this).children('span').attr('class')+'&order='+$('.asc-desc.sort-task.selected').children('span').attr('class');
    return false;
  });

  $('.asc-desc.sort-task').live('click',function(){
    $('.asc-desc.sort-task').removeClass('selected');
    $(this).addClass('selected');
    if(window.location.hash.split('#').length>1)
    {
      var first_url=window.location.hash.split('#')[1].split('/')[0];
      var has_url=first_url.split('?')[0];
    }
    else
      var has_url=window.location.hash.split('#')[0]+'all_tasks';
    window.location.hash=has_url+'?sort_by='+$('.sort.sort-task.selected').children('span').attr('class')+'&order='+$(this).children('span').attr('class');
    return false;
  });
  
  $('.tkl-down').live('click',function(){
    var task_list_content=$('.task.tsem.open');
    var sec_pan_content=$('.task.tsem.open').html();
    var task_list_id=$(this).children('span').attr('class').split('tkl:')[1];
    var task_id=get_task_id();
    var task_list_name=$(this).children('span').text();
    $('.tkl-down').removeClass('selected');
    var div='<div id="tk_'+task_id+'" class="actk:'+task_id+' task tsem open">'
    $(this).addClass('selected');
    $('.filed-tasklist').text(task_list_name);
    $.ajax({
      url:'tasks/'+task_id,
      type:'put',
      data:{'task[task_list_id]' : task_list_id},
      success:function(data){
        if(task_list_content.prev().hasClass('sub-header') && task_list_content.next().hasClass('sub-header'))
          task_list_content.prev().remove();
        task_list_content.remove();
        $('.tsk-detlt').attr('id','tklt'+task_list_id)
        if($('#tl'+task_list_id).length==0)
        {
          var  html_content='<div id="tl'+task_list_id+'" class="sub-header"><a class="sec task_list" href="#">'+task_list_name+'</a></div>';
          html_content+=div+sec_pan_content+'</div>';
          $('.m-panel').append(html_content);
        }
        else
          $(task_list_content).insertAfter($('#tl'+task_list_id));    
      }
    });
    //$('.task-dropdown task_list').css('display','none');
    $('.task-dropdown.task_list').hide();
  });
  
  $('.user_list').live('click',function(){
    $('.user_list').removeClass('selected');
    $(this).addClass('selected');
    var task_id=get_task_id();
    var user_id=$(this).attr('id').split('ul:')[1];
    var name=$(this).children('span').text();
    $.ajax({
      url:'/tasks/'+task_id+'/assign_task',
      type:'put',
      data:{'user_id' : user_id}
    });
    $('a.assigned-to').text(name);
    $('div.task.tsem.open').children('div.info').children('span.name').text(name);
    $('.task-dropdown.assigned-to').hide();
  });
  
  $('.name.message_name').live('click',function(){
    $(this).parent('div.message-body').parent('div.message.message_comments').toggleClass('open');
    return false;
  });
  
  $('.invite-btn.dp-down').live('click',function(){
    var email=$.trim($('#invite_email').val());
    if(email=="")
    {
      alert("Please enter a email");
      return false;
    }
    else if(IsValidEmail(email)==false)
    {
      alert('Please enter a valid email');
      return false;
    }
    var project_id=get_project_id();
    $.ajax({
      url:'/projects/invite_people',
      type: 'post',
      data: {'invite[email]':email,
             'invite[project_id]' :project_id}
    });
    $('.task-dropdown.assigned-to').fadeOut();
    $('#invite_email').val('');
    return false;
  });
  
  $('.cancel_comment').live('click',function(){
    close_comment_area();
    return false;
  });
  
  $('.reply-link').live('click',function(){
         if ($('.comment-contain').css('display')=="none")
      {
      $('.comment-contain').show();
      }
      else
      {
      $('.comment-contain').hide();
      }
      //~ $('.comment-contain').slideToggle('slow',function(){
        $('#comment-message').focus();
      //~ });
      return false;  
    });
  
   $('#sub_other_users').live('click',function(){
      var subscribe=$('#submsg').text();
      var content=$('#all_subscribed').html();
      $('p.subscribers').html('Subscribed: '+content+'<a href="#" id="submsg"> '+subscribe+'</a>');
      return false;
    });
  
  var restfulApp = Backbone.Controller.extend({
    restfulUrl: $.host,
    routes: {
    ':all_task'   : 'allTask',
    ':all_task/:activity_id' : 'taskComment'
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
      var purl=window.location.hash;
      if (purl.search('starred_tasks')>-1)
      {
        $('#starred_tasks').addClass('open');
      }
      else if (purl.search('all_tasks')>-1)
      {
        $('#all_tasks').addClass('open');
      }
      $.ajax({
        url: pageUrl,
        success: function(data){
          if(data=="The page you were looking doesn't exist")
document.getElementById('comment_area').innerHTML=data
else
{
          load_third_pane(data);
}
        }
      });
    }
  });

  function load_second_pane(data)
  {
    var items=[];
    $.each(data,function(index,value){
      items.push('<div class="sub-header" id="tl'+value[0].activity.resource.task_list_id+'"><a href="#" class="sec task_list">'+value[0].activity.resource.task_list_name+'</a></div>');
      var count=1;
      $.each(value,function(i,v){
        var starred=v.activity.is_starred;
        items.push('<div id="tk_'+ v.activity.id+'" class="actk:'+v.activity.id+' task '+(count%2==0 ? "alt " : "") +'tsem '+(starred ? "starred" : "")+'"><div class="left-icons">');
        items.push('<a class="task-star" href="#" '+(starred ? '' : 'style="display:none;"')+'>Star</a>');    
        items.push('<div class="checkbox"><span class="tk:'+v.activity.resource_id+' icon icon-sec '+(v.activity.resource.is_completed ? "checked" : "")+'"></span></div></div>');
        items.push('<div class="info">');
        items.push('<span class="task-time '+due_date_class(v.activity.resource.due_date_value[1])+'">'+v.activity.resource.due_date_value[0]+'</span>');
        items.push('<span class="name">'+v.activity.resource.assigned_to[0]+'</span>');
        items.push('</div><br />');
        items.push('<div class="task-name"><h4>'+truncate_task_name(v.activity.resource.name)+'</h4></div>');
        items.push('<div class="clear-fix"/></div>');        
        count=count+1;
      });
    });
    $('.m-panel').html(items.join(''));
    $('.sort-by.task-sort').show();
    if($('.task.tsem').children().length > 0)
    $($('.task.tsem')[0]).click();
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
    items.push('<div style="position:relative">');
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
    items.push('</div>');
    items.push('<div style="position:relative">');
     //if(task.assigned_to[0].length!=0)
    items.push('<p class="recipients">Assigned to <a class="assigned-to" href="#">'+task_assigned_name(task.assigned_to[0])+'</a></p>');
    
    //other teammembers
    items.push('<div class="task-dropdown assigned-to" style="display:none;">');
    items.push('<div class="task-dropdown-t"></div>');
    items.push('<ul>');
    $.each(task.team_members,function(i,v){
      items.push('<li class="user_list '+(task.assigned_to[1]==v.id ? "selected" : "")+'" id="ul:'+v.id+'"><span>'+v.name+'</span></li>');
    });
    items.push('</ul>')
    
    items.push('<input type="text" id="invite_email" onfocus="this.select()" onclick="this.value=\'\';"class="textfield" value="Invite by email" name="assign"/>');
    items.push('<a class="invite-btn dp-down" href="#">+</a>');
    items.push('</div>');
    items.push('</div>');
    items.push('<hr/>');
    items.push('<div class="main-content"><p><span>'+task.description+'</span><a class="edit task_description" href="#">Edit</a></p></div>');
     //Document attachment
    if(data.attach.attached_documents.length>0)
    {
      items.push('<div style="margin-top:20px;margin-bottom:20px;">')
      $.each(data.attach.attached_documents,function(index,value){
        items.push('<p>'+value+'</a></p>');
      });
      items.push('</div>')
    }
    
    //Image attachments
    if(data.attach.attach_image.length>0)
    {
      items.push('<div class="attachments">');
      $.each(data.attach.attach_image,function(index,value){
        items.push('<div class="attachment-thumb-frame">'+value+'</div>');
      });
      items.push('<div class="clear-fix"></div>')
      items.push('</div>');
    }
    items.push('<p class="subscribers">'+task.subscribe+'<span id="all_subscribed" style="display:none;">'+task.all_subscribed+'</span><a id="subscribe_task" class="task-subscribe" href="#"> '+ data.is_subscribed + '</a></p>');
    items.push('<span id="pk:'+task.project_id+'" class="pl_tk" style="display:none">Show</span>');
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
      items.push('<a class="reply-link" href="#">Reply</a></div></div><div class="clear-fix"></div></div>');
    });
    items.push('</div>')
    $('#comment_area').html(items.join(''));
    $('#comment_area').show();
  }
  

  
  function initial_setup()
  {
    $('body').attr('class','tasks');
    document.title= "Tasks | Mocha";
    $('.sort-by.task-sort').hide();
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
  
  function get_project_id()
  {
    return $('.pl_tk').attr('id').split('pk:')[1];
  }
  function display_star_count(count){
    if(count==0)
      $('a.starred.starred_count').html('<span class="icon"></span>Starred' );
    else
      $('a.starred.starred_count').html('<span class="num-tasks">'+count+'</span><span class="icon"></span>Starred' );
  }
  
  function IsValidEmail(email)
	{
    var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
    return filter.test(email);
	}
  
  function tasks_count(data)  
  {
     //~ if(data.completed_count==0)
       //~ $('#completed_tasks').hide();
     if(data.completed_count<1)
      //~ $('#completed_tasks').html('<span class="icon"></span>Completed');
        $('#completed_tasks').hide();
    else
       $('#completed_tasks').show();
      $('#completed_tasks').html('<span class="num-tasks">'+data.completed_count+'</span><span class="icon"></span>Completed');
    if(data.starred_count<1)
      $('#starred_tasks').html('<span class="icon"></span>Starred');
    else
      $('#starred_tasks').html('<span class="num-tasks">'+data.starred_count+'</span><span class="icon"></span>Starred');
    if(data.all_count<1)
      $('#all_tasks').html('<span class="icon"></span>All Tasks');
    else
      $('#all_tasks').html('<span class="num-tasks">'+data.all_count+'</span><span class="icon"></span>All Tasks');
    if(data.my_count<1)
      $('#my_tasks').html('<span class="icon"></span>My Tasks');
    else
      $('#my_tasks').html('<span class="num-tasks">'+data.my_count+'</span><span class="icon"></span>My Tasks');
  }
  
  function truncate_task_name(name)
  {
    if(name.length>55)
      return name.substring(0,55)+"...";
    else
      return name;
  }
  
  function task_assigned_name(name)
  {
    if(name=="")
      return "None"
    else
      return name
  }
  
  var app = new restfulApp;
  Backbone.emulateHTTP = true;
  Backbone.emulateJSON = true
  Backbone.history.start();


 })(jQuery);
