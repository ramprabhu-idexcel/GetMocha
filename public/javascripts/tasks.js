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
  
  $('.sub-header').live('click',function(){
    return false;
  });
  
  //complete/reopen the tasks
  $(".checkbox > span.icon").live('click',function(){
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
  
  $('.task.tsem').live('click',function(){
    var activity_id=$(this).attr('class').split(' ')[0].split('actk:')[1];
    var has_url=window.location.hash;
    $('.task.tsem').removeClass('open');
    $(this).addClass('open');
    if(has_url=="")
      var secondary_url="all_tasks";
    else
      var secondary_url=(window.location.hash).split('#')[1];
    window.location.hash="#"+secondary_url+"/"+activity_id;
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
    return false;
  });
  
  $('a.edit.save_task_desc').live('click',function(){
    var content=$('#task_description').val();
    var task_id=$('div.message-body').children('span.tsk-det').attr('id').split('tk:')[1];
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
    return false;    
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
      items.push('<div class="sub-header"><a href="#">'+value[0].activity.resource.task_list_name+'</a></div>');
      $.each(value,function(i,v){
        var starred=v.activity.is_starred;
        items.push('<div class="actk:'+v.activity.id+' task tsem '+(starred ? "starred" : "")+'"><div class="left-icons">');
        items.push('<a class="task-star" href="#" '+(starred ? '' : 'style="display:none;"')+'>Star</a>');    
        items.push('<div class="checkbox"><span class="tk:'+v.activity.resource_id+' icon '+(v.activity.resource.is_completed ? "checked" : "")+'"></span></div></div>');
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
    items.push('<div class="message-body">');
    items.push('<span style="display:none;" class="tsk-det" id="tk:'+task.id+'"></span>')
    items.push('<div class="checkbox"><span class="icon '+(task.is_completed ? "checked":"")+'"></span></div>');
    items.push('<h2><span>'+task.name+'</span><a class="edit task_name" href="#">Edit</a></h2>');
    items.push('<p class="filed-under">Filed under <a class="filed-tasklist" href="#">'+task.task_list_name+'</a></p>');
    //other task-list-names
    items.push('<div class="task-dropdown task_list" style="display:none;">');
    items.push('<div class="task-dropdown-t"></div>');
    items.push('<ul>');
    $.each(task.other_task_lists,function(i,v){
      items.push('<li><span class="tkl:'+v.task_list.id+'">'+v.task_list.name+'</span></li>');
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
    $('.r-panel').html(items.join(''));
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
  }
  
  function first_pane_class(clicked){
    $('.all-tasks, .my-tasks, .starred, .completed, .project').removeClass('open');
    clicked.addClass('open');
  }
  
  var app = new restfulApp;
  Backbone.emulateHTTP = true;
  Backbone.emulateJSON = true
  Backbone.history.start();


 })(jQuery);