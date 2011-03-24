$.messages;
 (function($) {

           var restfulApp = Backbone.Controller.extend({
               restfulUrl: "http://localhost:3000/",
               routes: {
               '*message/:project_id' : 'projectMessage',
               "*page":                    "findMessage", //This simply matches any urls that weren't caught above and assigns it to "page"
               },
                
              findMessage: function( page ){
                if( /all_messages/.test(page) || /starred_messages/.test(page)) {
                    var restfulPageUrl = this.restfulUrl + page  
                    this.loadRestfulData( restfulPageUrl );
                    $('.sort-by').show();
                    $('.message_header').hide();
                    $('#comment_area').html('');
                }
               },
               projectMessage:function(page){
               
                  var path=(window.location+"").split('?')[0];
                  path=path.split('#')[1];
                  if((/^all_messages\/[1-9]/.test(path)) ||(/^starred_messages\/[1-9]/.test(path)))
                  {
                    var restfulPageUrl = this.restfulUrl + path  
                    this.loadCommentData( restfulPageUrl );         
                  }
                  else{
                    url=(window.location+"").split('?');
                    params=path.split('/');
                    if(params.length<3)
                    {
                      if(url.length>1)
                      {
                        path=path+"?"+url[1];
                      }
                      var restfulPageUrl = this.restfulUrl + path  
                      this.loadRestfulData( restfulPageUrl );    
                      $('.message_header').hide();
                      $('#comment_area').html('');  
                    }   
                    else
                    {
                      var restfulPageUrl = this.restfulUrl + path  
                      this.loadCommentData( restfulPageUrl );     
                    }
                  }
                  $('.sort-by').show();
               },
               loadRestfulData: function( pageUrl ){
                   $.ajax({
                       url: pageUrl,
                       success: function(data){  
                        $.messages=data
                        var items=[];
                        $.each(data,function(index,val){
                          items.push('<div class="date-bar"><a href="#" class="date-title">'+parse_date(index)+'</a></div>');
                          $.each(val,function(i,v){
                            items.push('<div class="message messow '+(v.activity.is_read ? "" : " unread")+' mpi'+v.activity.resource.project_id+'" id= "msac'+v.activity.id+'"><div class="left-icons"><div class="avatar-mini"></div><img alt="avatar" width= "20" height ="21" class="avatar-mini-img" src="'+v.activity.resource.user.image_url+'"/>')
                            if(v.activity.is_starred)
                            items.push('<a class="message-star" href="#">Star</a>');
                            if(v.activity.has_attachment)
                            items.push('<div class="has-attachment"></div>');
                            items.push('</div><div class="info"><span class="name">'+v.activity.resource.user.name+'</span><span class="message-time">'+v.activity.created_time+'</span></div>')
                            items.push('<div class="excerpt"><h4>'+v.activity.resource.subject+'</h4><p>'+v.activity.resource.message+'</p></div><div class="clear-fix"></div></div>');
                            result=items.join(' ')
                            $('#message_area').html(result);

                          });
                        });
                      }
                   });
               },
               loadCommentData :function(pageUrl){
                  var comments=[];
                  //to load the second panel
                  if(typeof($.messages)=="undefined")
                  {
                    path=(window.location+"").split('#')[1].split('/')[0];
                    change_id=(window.location+"").split('#')[1].split('/')[1];
                    load_path=this.restfulUrl+path;
                    this.loadRestfulData(load_path);
                    $('div#msac'+change_id).addClass('open');
                  }
                  
                  //to load the third panel
                  $.ajax({
                      url: pageUrl,
                      success: function(data){  
                        comments.push('<div class="message-body"><h2>'+data.message.subject+'<a class="edit subject_edit" href="#">Edit</a></h2>');
                        comments.push('<p class="post-time">'+data.message.updated_date+' by <a href="#" class="user-name">'+data.message.name+'</a></p><hr/>');
                        comments.push('<div class="main-content"><p>'+data.message.message+'<a class="edit message_edit" href="#">Edit</a></p></div>');
                        //Document attachment
                        if(data.message.attach.attached_documents.length>0)
                        {
                          comments.push('<div style="margin-top:20px;margin-bottom:20px;">')
                          $.each(data.message.attach.attached_documents,function(index,value){
                            comments.push('<p><a href="'+value+'">'+get_filename(value)+'</a></p>');
                          });
                          comments.push('</div>')
                        }
                        
                        //Image attachments
                        if(data.message.attach.attached_images.length>0)
                        {
                          comments.push('<div class="attachments">');
                          $.each(data.message.attach.attached_images,function(index,value){
                            comments.push('<div class="attachment-thumb-frame"><a href="'+value+'"><img alt="attachment" src="'+value+'" width="75" height="75"/></a></div>');
                          });
                          comments.push('<div class="clear-fix"></div>')
                          comments.push('</div>');
                        }
                       
                        comments.push('<p class="subscribers">'+data.message.subscribed_user+' <span id="all_subscribed" style="display:none;">'+data.message.all_subscribed+'</span><a href="#" id="submsg">'+(data.message.is_subscribed ? "Unsubscribe": "Subscribe")+'</a></p></div>');
                        //Comments
                        comments.push('<div class="prev-messages">');
                        $.each(data.comments,function(index,comment){
                          comments.push('<div class="message message_comments '+(comment.is_starred ? "starred" : "" )+' " ><div class="message-body"><a class="message-star" href="/star_message/'+comment.id+'">Star</a>');
                          comments.push('<a class="name message_name" href="#">'+comment.user+'</a><span class="message-time">'+comment.created_at+'</span>');
                          comments.push('<div class="comment"><p>'+comment.comment+'</p>');
                          if(comment.attach.attach_image.length>0)
                          {
                            comments.push('<div class="attachments">');
                            $.each(comment.attach.attach_image,function(index,value){
                              comments.push('<div class="attachment-thumb-frame"><img alt="attachment" src="'+value+'" width="75" height="75"/></div>');
                            });
                            comments.push('<div class="clear-fix"></div></div>');
                          }
                          comments.push('<a class="reply-link" href="#">Reply</a></div></div></div>');
                        });
                        comments.push('</div>');
                        var result=comments.join(' ');
                        $('#comment_area').html(result);
                        if(data.comments.length>0)
                        $('.expand-all').show();
                      }
                     });
               }
            });

           var app = new restfulApp;
           //Initiate a new history and controller class
           Backbone.emulateHTTP = true;
           Backbone.emulateJSON = true
           Backbone.history.start();
 
       })(jQuery);