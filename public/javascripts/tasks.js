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
  
  var restfulApp = Backbone.Controller.extend({
    restfulUrl: $.host,
    routes: {
    ':all_task'   : 'allTask',
    '*page'       : 'projectTask',
    'tasks/*page' : 'projectTask',
    '*task/:project_id' : 'projectTask',
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
    projectTask: function(page){
      var restfulPageUrl = this.restfulUrl +'tasks/'+ page  
      this.loadRestfulData( restfulPageUrl );
    },
    loadRestfulData: function( pageUrl ){
      $.ajax({
        url: pageUrl,
        success: function(data){
          load_second_pane(data);
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