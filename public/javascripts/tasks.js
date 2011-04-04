(function($) {
  $('body').attr('class','tasks');
  document.title= "Tasks | Mocha";
  $('.sort-by').hide();
  $('#reply_comment').hide();
  $('.star.star_items').hide();
  $('#trash_message').hide();

  //first pane
  $('.project').live('click',function(){
    $('.project').removeClass('open');
    $(this).addClass('open');
    return false;
  });



  var restfulApp = Backbone.Controller.extend({
    restfulUrl: $.host,
    routes: {
    ':all_task' : 'allTask',
    '*page' : 'projectTask',
    'tasks/*page' : 'projectTask',
    '*tasks/:project_id' : 'projectTask',
    },
    allTask: function(page){
      var restfulPageUrl = this.restfulUrl + page  
      this.loadRestfulData( restfulPageUrl );
    },
    projectTask: function(page){
      alert(page);
      var restfulPageUrl = this.restfulUrl + page  
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
        items.push('<div class="task '+(v.activity.is_starred ? "starred" : "")+'"><div class="left-icons">');
        if(v.activity.is_starred)
          items.push('<a class="task-star" href="#">Star</a>');       
        items.push('<div class="checkbox"><span class="icon'+(v.activity.resource.is_completed ? "checked" : "")+'"></span></div></div>');
        items.push('<div class="info">');
        items.push('<span class="task-time '+due_date_class(v.activity.resource.due_date_value)+'">'+v.activity.resource.due_date_value+'</span>');
        items.push('<span class="name">'+v.activity.resource.assigned_to+'</span>');
        items.push('</div>');
        items.push('<div class="task-name"><h4>'+v.activity.resource.name+'</h4></div>');
        items.push('<div class="clear-fix"/></div>');        
      });
    });
    $('.m-panel').html(items.join(''));
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
  
  var app = new restfulApp;
  Backbone.emulateHTTP = true;
  Backbone.emulateJSON = true
  Backbone.history.start();


 })(jQuery);