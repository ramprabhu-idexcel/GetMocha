// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  
  //signup and login
  
  if(typeof Signup!="undefined" && Signup==true)
  {
    $('#user_submit').click(function(){
      $.ajax({
        url:'/users',
        data: $('form#user_new').serialize(),
        type: "POST"        
      });
      return false;
    });
  }

  if(typeof Login!="undefined" && Login==true)
  {
     
   $('#remember_me').click(function(){
        $('#remember_hidden_id').val("1")
     return true;
     });
     
   $('#user_submit').click(function(){
             
      if (($('#user_email').val()=="") && ($("#user_password").val()==""))
       {
            alert("Email and Password can't be blank");
       }
       
      else if ($('#user_email').val()=="")
        { 
           alert("Email can't be blank");
        }
       else if ($("#user_password").val()=="")
       {
           alert("Password can't be blank");
       }
       else
      {       
     
      $.ajax({
        url:'/users/sign_in',
        data: $('form#user_login').serialize(),
        type: "POST",
        success: function(data){
          if(data!="redirect")
          {
            alert(data);
          }
          else
          {
            window.location.href="/messages";
          }
        }
      });
    }
      return false;
    });
    
    $('#forgot_pass').click(function(){
     // $('#fpwd').submit();
      $.ajax({
        url:'/users/password',
        data: $('form#fpwd').serialize(),
        type: "POST",
        success: function(data){
            window.location.href="/";
          }
      });
       return false;
    });
  }
  
      

 
  
 if(typeof UserEdit!="undefined" && UserEdit==true)
  {
        
  
   
  } //end of user edit

  // user account-dropdown
  
  $('.user_drop_down').click(function(){
    $('.account-dropdown').toggle();
    return false;
  });
  
     $('.delete').click(function(){
         $(this).parent('span').remove();
       $.ajax({
         url: $(this).attr('href'),
         type: 'delete',
       });
    return false;
  });
  
  $('.delete').live('click',function(){
         $(this).parent('span').remove();
       $.ajax({
         url: $(this).attr('href'),
         type: 'delete',
       });
    return false;
  });
    
  
  //Message page codings
  if(typeof Message!="undefined" && Message==true)
  {   
    
    //hide the message headers 
    function hide_header(){
      $('.message_header').hide(); 
      $('.sort-by').hide(); 
      $('.comment-contain').hide();
    }
    
    //hide the comment header
    function hide_comment(){
      $('.message_header').hide();
      $('#comment_area').html('');
      $('.comment-contain').hide();
    }
    
    function close_comment_area()
    {
      $('.comment-contain').toggle('slow');
      $('#comment-message').val('');
    }
    //find the current url
    function sort_path()
    {
      var path=window.location+"";
      path= path.split('?')[0];
      var sort_by=$('.sort.selected').text();
      var order=$('.asc-desc.selected').children('span').attr('class');
      window.location=path+'?sort_by='+sort_by+'&order='+order;
    }
    
    //Expand all message
    $('#message_expand').live('click',function(){
      $('.message.message_comments').addClass('open');
      $('.expand-all').hide();
      return false;
    });
    
    //Expand single message
    $('.name.message_name').live('click',function(){
      $(this).parent('div.message-body').parent('div.message.message_comments').addClass('open');
      return false;
    });
        
    //Star the messages
    $('.star.star_items').live('click',function(){
      var id=$('.message.messow.open').attr('id').split('msac')[1];
      $('#msac'+id).children('div.left-icons').children('a.message-star.secpan').toggle();
      $.ajax({
        url: '/star_message/'+id,
        type: 'get',
        success:function(data)
        { 
          $('a.starred.starred_count').html('<span class="num-tasks">'+data.count+'</span><span class="icon"></span>Starred' );
        }
      });
      return false;
    });
    
    //Star the messages from the second panel
    
    $('.message-star.secpan').live('click',function(){
      var parent_div=$(this).parent().parent();
      var id=parent_div.attr('id').split('msac')[1];
      $(this).toggle();
      $.ajax({
        url: '/star_message/'+id,
        type: 'get',
        success:function(data)
        { 
          $('a.starred.starred_count').html('<span class="num-tasks">'+data.count+'</span><span class="icon"></span>Starred' );
        }
      });
      if($('#starred_messages').hasClass('open'))
        parent_div.remove();
      return false;
    });
    //Star the comments
    $('.message-star.star_comment').live('click',function(){
      var path=$(this).attr('href');
      $(this).parent('div.message-body').parent('div.message').toggleClass('starred');
      $.ajax({
        url: path,
        type: 'get',
        success:function(data)
        {
          $('a.starred.starred_count').html('<span class="num-tasks">'+data.count+'</span><span class="icon"></span>Starred' );
        }
      });
      return false;
    });
    
    //delete the messages
    $('#trash_message').live('click',function(){
      var activity_id=$('.message.messow.open').attr('id').split('msac')[1];
      $.ajax({
        url: '/messages',
        type:'delete',
        data:{'activity_id':activity_id}
      });
      $('#comment_area').fadeOut('');
      $('.comment-input').hide();
      $('#msac'+activity_id).fadeOut('slow',function(){$(this).remove()});
      return false;
    });
    
    //first panel change the class
    $('.project,.all-messages,.starred').click(function(){
      $('.project.open,.all-messages,.starred').removeClass('open'); 
      $(this).addClass('open');
    });
    
    //display the sort message
    $('.sort-by').click(function(){
      $('.sort-by-tooltip').slideToggle('slow');
      return false;
    });
    
    //Message page sorting
    $('.sort').click(function(){
      $('.sort').removeClass('selected');
      $(this).addClass('selected');
      sort_path();
    });
    
    $('.asc-desc').click(function(){
      $('.asc-desc').removeClass('selected');
      $(this).addClass('selected');
      sort_path();
    });
    
    $('.subject_edit').live('click',function(){
      var content=$(this).parent('h2').text().split('Edit')[0];  
      //$(this).parent('h2').hide();
      $(this).parent().html('<textarea class="textfield" cols="" rows="" name="message[subject]" id="message_subject" >'+content+'</textarea><a class="edit save_subject" style="display: inline;" href="#">Save</a><div class="clear-fix"></div>');
      return false;
    })
    
    $('.message_edit').live('click',function(){
      var content=$(this).parent('p').text().split('Edit')[0];
      $(this).parent('p').html('<textarea class="textfield" style="height: 160px;" cols="" rows="" name="message" id="message_message">'+content+'</textarea><a class="edit save_message" style="display: inline;" href="#">Save</a><div class="clear-fix"></div>')
      return false;
    });
    
    $('.save_subject').live('click',function(){
    var activity_id=$('.message.messow.open').attr('id').split('msac')[1];
      $.ajax({
        url:'messages/'+activity_id,
        type:'put',
        data:{'message[subject]' : $('#message_subject').val()}        
      });
      new_content=$('#message_subject').val();
      $('.message.messow.open').children('.excerpt').children('h4').text(new_content);
      $(this).parent().html(new_content+'<a class="edit subject_edit" href="/edit">Edit</a><div class="clear-fix"></div>');
      return false;
    });
    
    $('.save_message').live('click',function(){
      var activity_id=$('.message.messow.open').attr('id').split('msac')[1];
      $.ajax({
        url:'messages/'+activity_id,
        type:'put',
        data:{'message[message]' : $('#message_message').val()}        
      });
      new_content=$('#message_message').val();
      message_content=$('#message_message').val();
      if(new_content.length>77)
      {
        new_content=new_content.substring(0,77)+"...";
      }
      $('.message.messow.open').children('.excerpt').children('p').text(new_content);
      $(this).parent().html(message_content+'<a class="edit message_edit" href="#">Edit</a><div class="clear-fix"></div>');
      return false;
    });
    
    
    $('.user-name').live('click',function(){
      return false;
    });
    
    
    
    $('.messow').live('click',function(){
      var id=$(this).attr('id').split('msac')[1];
      var primarUrl=(window.location+'').split('#')[0];
      var secondaryUrl=(window.location+'').split('?')[0];
      var loc=secondaryUrl.split('#')[1].split('/')[0];
      if(loc=="project")
      {
        loc=secondaryUrl.split('#')[1].split('/')[0]+'/'+secondaryUrl.split('#')[1].split('/')[1]
      }
      window.location=primarUrl+"#"+loc+"/"+id;
      $('.message.messow.open').removeClass('open');
      //change the all message count
      if($(this).hasClass('unread'))
      { 
        count=$('a#all_messages').children('span.num-unread');
        project_id=$(this).attr('class').split('mpi')[1];
        project_count=$('#project_list_messages'+project_id).children('span.num-unread');
        count_val=parseInt(count.text());
        project_val=parseInt(project_count.text());
        if(count_val<1)
        {
          count.remove();
        }
        else
        {
          count.text(count_val-1);
        }
        if(project_val<1)
        {
          project_count.remove();
        }
        else
        {
          project_count.text(project_val-1)
        }
      }
      //chane the read class
      $(this).removeClass('unread');
      $(this).addClass('open');
      //hide the header and the sort drop down
      $('.sort-by-tooltip').hide();
      $('.message_header').show(); 
      
    });
  
    $('#all_messages, .project, .starred').click(function(){
      $('.expand-all').hide();
    });
    
    //message reply link and reply in the comment
    $('.reply, .reply-link').click(function(){
      $('.comment-contain').slideToggle('slow',function(){
        $('#comment-message').focus();
      });
      return false;  
    });
    
  
    //Add message comments  
    $('.blue-33.add_comment').live('click',function(){
      var activity_id=$('.message.messow.open').attr('id').split('msac')[1];
      $('#act').val(activity_id);
      var reply="";
      $.ajax({
        url: '/comments',
        type: 'post',
        data: $('form#add_com_msg').serialize(),
        success:function(data){
          attach=data.attach;
          var comment=data.comment[0];
          reply+=('<div class="message message_comments '+(comment.is_starred ? "starred" : "" )+' " ><div class="message-body"><a class="message-star" href="#">Star</a>');
          if(attach==false)
          reply+=('<a class="name message_name" href="#">'+comment.user+'</a><span class="message-time">'+comment.created_at+'</span>');
          else
          reply+=('<a class="name message_name" href="#">'+comment.user+'</a><div class="has-attachment"></div><span class="message-time">'+comment.created_at+'</span>');
          reply+=('<div class="comment"><p>'+comment.comment+'</p>');
          reply+=('<a class="reply-link" href="#">Reply</a></div></div></div>');
          $('.prev-messages').append(reply).show('slow');
          close_comment_area();
        }
      });
      return false;
    });
   
    //Cancel link in add new comment
    $('.cancel_comment').live('click',function(){
      close_comment_area();
      return false;
    });

    $('.date-title').live('click',function(){
      return false;
    });
      
    //subscribe/unsubscribe message
    $('#submsg').live('click',function(){
      var id=$('.message.messow.open').attr('id').split('msac')[1];
      $.ajax({
        url:'/subscribe/'+id,
        type: 'get'
      });
      var content=$(this).text();
      var result = (content=="Subscribe" ? "Unsubscribe" : "Subscribe");
      $(this).text(result);
      return false;
    });
    
    
    
    
    hide_header(); //hide the message headers initially
    hide_comment(); //hide the comment header initially
  
  }//end of message
  
  //Message second panel click function  

  
  //drop down
  $('#add-new').click(function(){
    $('#add_new_mods').slideToggle('fast');
    return false;
  });
  
  //add new message modal
  
  $('.create_message').live('click',function(){
    $.ajax({
      type :'get',
      url :"/messages/new",
      success: function(data){
        $('#add_new_mod').html(data); 
        $('#add_new_mod').show();
      }
    });
    $('#add_new_mods').hide();
    return false;
  });

  //show create project pop-up
  $('.create_project').live('click',function(){
    $.ajax({
      type :'get',
      url :"/projects/new",
      success: function(data){
			 $('#add_new_mod').html(data); 
        $('#add_new_mod').show();
      }
    });
    $('#add_new_mods').hide()
    return false;
  });
  
  //cancel message modal
  $('#m_can').live('click',function(){
    $('.add-item-modal').hide();
    return false;
  });
  
  //Cancel project modal
  $('#p_can').live('click',function(){
    $('.add-item-modal').hide();
    return false;
  });
  
  //Save project
  $('#p_add').live('click',function(){
    var a=$('#data_name').val();
    var b=$('#data_invites').val();
    var c=$('#data_message').val();
    $.ajax({
      type :'post',
      url :"/projects",
      data : $('#form1').serialize(),
      success: function(data){
        a=data.search(/alert/);
      	if(a!=0 && a!=6){
         $('.add-item-modal').hide();
	if(window.location.href='/settings')
         document.getElementById('projects_list').innerHTML=data;
        else
         document.getElementById('messages_projects_list').innerHTML=data;
        }
      },
      failure: function(){
        alert("Error");
      }
    });
    return false;
  });
  
  //Message save button
  $('#m_add').live('click',function(){
    $.ajax({
      type :'post',
      url :"/messages",
      data : $('#form2').serialize(),
      success: function(data){
      new_content=$('#message_message').val();
      if(new_content.length>77)
      {
        new_content=new_content.substring(0,77)+"...";
      }
        message='';
        message+='<div id="msac'+data.activity_id+'" class="message messow mpi'+data.project_id+'">';
        message+='<div class="left-icons"><div class="avatar-mini"></div><img width="20" height="21" src="'+data.user_image+'" class="avatar-mini-img" alt="avatar"/></div>';
        message+='<div class="info"><span class="name">'+data.name+'</span><span class="message-time">'+data.message_date+'</span></div> ';
        message+='<div class="excerpt"><h4>'+data.subject+'</h4><p>'+new_content+'</p></div><div class="clear-fix"></div></div>';
        header=$('a.date-title:contains("'+data.date_header+'")');
        if(header)
        {
          $(message).insertAfter(header.parent());
        }
        else
        {
          date_header='<div class="date-bar"><a class="date-title" href="#">'+data.date_header+'</a></div>';
          $(date_header+message).prependTo('#message_area')
        }
        if(typeof(data.name)!="undefined")
        $('.add-item-modal').hide();
      }
    });
    return false;
  });
  
  $('#start_uploads').live('click',function () {
    $('.file_upload_start button').click();
  });
  
  $('.create_task, .create_task_list').click(function(){
    return false;
  });
  
  $('#my_account').live('click',function(){
    $.get('/settings-profile', function(data) {
      $('#container').html(data);
    });
    $('.account-dropdown').hide();
    return false;
  });
  
  $('.settings.project-settings').live('click',function(){
    $.get('/settings', function(data) {
      $('#container').html(data);
    });
    $('.message_header').hide();
  });
  
   /************************************************Edit the User profile*****************************************/
  
  $('.my-account.open').live('click',function(){
    return false;
  });
  
  $('#mycontact1').live('click',function(){
    $('#mycontact1').toggleClass('open')
    $('#my_profile').hide();
    $('#myprofile1').toggleClass('open')
    $('#my_contacts').show();
    $('#people_settings_popup').show();
    return false;
  });
      
  $('#myprofile1').live('click',function(){
    $('#mycontact1').toggleClass('open')
    $('#my_profile').show();
    $('#myprofile1').toggleClass('open')
    $('#my_contacts').hide();
    return false;
   });
  
  
  
  $('#colorSelector').ColorPicker({
    color: '#0000ff',
    onShow: function (colpkr) {
      $(colpkr).fadeIn(500);
      return false;
    },
    onHide: function (colpkr) {
      $(colpkr).fadeOut(500);
      $.ajax({
        url:'/updates/edit_profile',
        type:'put',
        data:{'user[color]':$('#choose_color_value').val()}
      });
      return false;
    },
    onChange: function (hsb, hex, rgb) {
      $('#choose_color').css('backgroundColor', '#' + hex);
      $('#choose_color_value').val(hex);
    }
  });

  
  //To edit the first_name
 	$('#first_name').live('click',function(){
    $('#label_first_name').hide();
    $('#txt_firstname').show(); 
    $('#first_name').css('visibility','hidden');
    $('#save_firstname').css('visibility','visible');
    return false;
  });
    
  $('#save_firstname').live('click',function(){
    if($('#txt_firstname').val()=="")
    {
      alert("please enter your firstname");
    }
    else
    {
      $.ajax({
        url:"/updates/edit_profile",
        type: "put",
        data:{"user[first_name]" : $('#txt_firstname').val()},
        success:function(data){
         if(data.success!="undefined")
         {
            $('#label_first_name').text(data.success)
           }
         else
         {
           alert(data.error);
         }
   			}	
      });
      $('#txt_firstname').hide(); 
      $('#save_firstname').css('visibility','hidden');
      $('#label_first_name').show();
      $('#first_name').css('visibility','visible');
      return false;
    }
  });
    
    
  //To edit the last_name  
    $('#last_name').live('click',function(){
      $('#label_last_name').hide();
      $('#txt_lastname').show(); 
      $('#last_name').css('visibility','hidden');
      $('#save_lastname').css('visibility','visible');
      return false;
    });
       
  	$('#save_lastname').live('click',function(){
      if($('#txt_lastname').val()=="")
       {
        alert("please enter your lastname");
       }
      else
      {
        $.ajax({
        url:"/updates/edit_profile",
        type: "put",
          data:{"user[last_name]" : $('#txt_lastname').val()},
        uccess:function(data){
          if(data.success!="undefined")
           {
              $('#label_last_name').text(data.success)
             }
           else
           {
             alert(data.error);
           }
			}			
          
    });
    $('#txt_lastname').hide(); 
    $('#save_lastname').css('visibility','hidden');
    $('#label_last_name').show();
    $('#last_name').css('visibility','visible');
    return false;
     }
  
   });
   

    
    //To edit the title
    $('#title').live('click',function(){
    $('#label_title').hide();
    $('#txt_title').show(); 
    $('#title').css('visibility','hidden');
    $('#save_title').css('visibility','visible');
    return false;
     });
     
  	$('#save_title').live('click',function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[title]" : $('#txt_title').val()},
           success:function(data){
          if(data.success!="undefined")
           {
              $('#label_title').text(data.success);
              $('#label_title').css('visibility','visible');
             }
           else
           {
             alert(data.error);
           }
			}			
          
        });
    
    $('#txt_title').hide(); 
    $('#save_title').css('visibility','hidden');
    $('#label_title').show();     
    $('#title').css('visibility','visible');
     return false;
   });
   

    
        
   //To edit the email
    $('#email').live('click',function(){
    $('#label_email').hide();
    $('#txt_email').show(); 
    $('#email').css('visibility','hidden');
    $('#save_email').css('visibility','visible');
    return false;
   });
     
  	$('#save_email').click(function(){
        if($('#txt_email').val()=="")
       {
          alert("pls enter your email");
       }
        else
       {
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[email]" : $('#txt_email').val()},
         success:function(data){
          if(data.success!="undefined")
           {
              $('#label_email').text(data.success)
             }
           else
           {
             alert(data.error);
           }
			}			
        });
    $('#txt_email').hide(); 
    $('#save_email').css('visibility','hidden');
     $('#label_email').show();
    $('#email').css('visibility','visible');
     return false;
      }   
        
  });
   
   
    
    //To edit the phone no

   $('#phone').live('click',function(){
   $('#label_phone').hide();
   $('#txt_phone').show(); 
   $('#phone').css('visibility','hidden');
   $('#save_phone').css('visibility','visible');
   return false;
   
    });
     
  	$('#save_phone').live('click',function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[phone]" : $('#txt_phone').val()},
         success:function(data){
          if(data.success!="undefined")
           {
if(data.success.length=="0")
              $('#label_phone').text("-");
else
              $('#label_phone').text(data.success);
             $('#label_phone').css('visibility','visible');
             }
           else
           {
             alert(data.error);
           }
			}			
        });
    
   $('#txt_phone').hide(); 
    $('#save_phone').css('visibility','hidden');
     $('#label_phone').show();
    $('#phone').css('visibility','visible');
    return false;
        
   });
   

    
        //To edit the mobile no
   $('#mobile').live('click',function(){
    $('#label_mobile').hide();
    $('#txt_mobile').show(); 
   $('#mobile').css('visibility','hidden');
   $('#save_mobile').css('visibility','visible');
    return false;
    });
     
  	$('#save_mobile').live('click',function(){
      $.ajax({
        url:"/updates/edit_profile",
        type: "put",
        data:{"user[mobile]" : $('#txt_mobile').val()},
        success:function(data){
          if(data.success!="undefined")
          {
            if(data.success.length=="0")
              $('#label_mobile').text("-");
            else
              $('#label_mobile').text(data.success)
              $('#label_mobile').css('visibility','visible');
             }
           else
           {
            alert(data.error);
           }
        }			
      });
      $('#txt_mobile').hide(); 
      $('#save_mobile').css('visibility','hidden');
      $('#label_mobile').show();
      $('#mobile').css('visibility','visible');
      return false;
   });
   
    //To edit the Timezone
    $('#save_time_zone').live('click',function(){
         $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[time_zone]" : $('#time_zone').val()}
        });
        return false;
       });
    
    //To edit the password
  $('#password').live('click',function(){
    $('#label_password').hide();
    $('#txt_password').show(); 
    $('#confirm').show(); 
    $('#confirm_pass').show();
    $('#txt_confirm').show();
    $('#password').css('visibility','hidden');
    $('#save_confirm').css('visibility','visible');
     return false;
  });
     
  	$('#save_confirm').live('click',function(){
      
      if(($('#txt_password').val()=="")&&($('#txt_confirm').val()=="")) 
      {
         alert('please enter the password & Confirm password');
      }
      else if($('#txt_password').val()=="")
       {
          alert("please enter the password");
       }
       else if ($('#txt_confirm').val()=="")
       {
          alert("please enter the confirm password");
       }
       else if(($('#txt_password').val().length) < 6)
       {
          alert('password & confirm password should be minimum 6 characters');
       }
             
       else if (($('#txt_confirm').val())!=($("#txt_password").val()))
        {
          alert('password & Confirm Password should be same');
        }
      else
      {
        $.ajax({
        url:"/updates/edit_password",
        type: "put",
        data:{"password" : $('#txt_password').val(),
              "confirm"  : $('#txt_confirm').val()}
      });

        $('#label_password').show();
        $('#txt_password').hide(); 
        $('#password').css('visibility','visible');
        $('#save_password').css('visibility','hidden');
        $('#confirm').hide(); 
        $('#confirm_pass').hide();    
        return false;
      }  
   });
   
	
    
   
  $('a#add_new_email').live('click',function(){
    $('#semail').append("<div class='info-right'><span class='info hidden'>********</span><input class='textfield' type='text' value='' name='secondary_emails' /> <a class='edit save_email' href='#' >Save</a></div><br />");
    return false;
  });
  
  $('.save_email').live('click', function() {
    var link=$(this);
    var email=link.siblings('input.textfield');
    $.ajax({
      url:'/updates/create_secondary_email',
      type:'POST',
      data:{"secondary_email":email.val()},
      success: function(data){
        if(typeof(data)=="string")
        {
          email.siblings('span.info.hidden').html(data);
          email.siblings('span.info.hidden').removeClass('hidden');
          email.remove();
          link.remove();
        }
        else
        {
          alert(data.error);
        }
      }      
    });
    return false;
  });

  /********************************End of user profile***************/
  
  
  
  
  
  
  
  
});//End of doc











/* $('#attach').fileUploadUI({
        uploadTable: $('#files'),
        downloadTable: $('#files'),
        buildUploadRow: function (files, index) {
            return $('<tr><td class="file_upload_preview"><\/td>' +
                    '<td>' + files[index].name + '<\/td>' +
                    '<td class="file_upload_progress"><div><\/div><\/td>' +
                    '<td class="file_upload_start">' +
                    '<button class="ui-state-default ui-corner-all" title="Start Upload">' +
                    '<span class="ui-icon ui-icon-circle-arrow-e">Start Upload<\/span>' +
                    '<\/button><\/td>' +
                    '<td class="file_upload_cancel">' +
                    '<button class="ui-state-default ui-corner-all" title="Cancel">' +
                    '<span class="ui-icon ui-icon-cancel">Cancel<\/span>' +
                    '<\/button><\/td><\/tr>');
        },
        buildDownloadRow: function (file) {
            return $('<tr><td>' + file.name + '<\/td><\/tr>');
        },
        beforeSend: function (event, files, index, xhr, handler, callBack) {
            handler.uploadRow.find('.file_upload_start').click(callBack);
        }
      
    });*/




function remove_people_settings(id, proj_id)
{
var pars = "user=" + id  + "&project_id=" + proj_id;
var where_to= confirm("Are you sure to remove this person?");
if(where_to==true)
{
  $.ajax({
       type :'post',
       url : "/del_people?"+pars,
       success: function(data){
			 document.getElementById('settings_pane').innerHTML=data;
			 document.getElementById('settings_people').style.display="block";
			 document.getElementById('people_anchor').className="m-tab alt open";
			 }
    });
}
else
{
return false;
}
}

function change_public_access(proj_id)
{
var pub_access=document.getElementById('settings_public_access').className;
var access=true;
if(pub_access=="icon")
access=false;
var pars = "project_id=" + proj_id + "&change_field=public_access" + "&checked="+ access;
 $.ajax({
       type :'post',
       url : "/update_proj_settings?"+pars,
       success: function(data){
			 document.getElementById('settings_pane').innerHTML=data;
			 document.getElementById('settings_general').style.display="block";
			 document.getElementById('general_anchor').className="m-tab alt open";
			 }
    });
}

function settings_project_info(edit)
{
if(edit=="edit")
{
document.getElementById('settings_project_name').style.display="none";
document.getElementById('text_anchor').className="textfield";
document.getElementById('edit_anchor').innerHTML="Save";
}
else
{
  var pub_access=document.getElementById('settings_project_name').className;
var access=true;
if(pub_access=="icon")
access=false;
var pars = "project_id=" + proj_id + "&change_field=public_access" + "&checked="+ access;
 $.ajax({
       type :'post',
       url : "/update_proj_settings?"+pars,
       success: function(data){
			 document.getElementById('settings_pane').innerHTML=data;
			 document.getElementById('settings_general').style.display="block";
			 document.getElementById('general_anchor').className="m-tab alt open";
         }
     });
}
}

function parse_datetime(datetime)
{
  var x = datetime.match(/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/);
  var parsed_date=new Date(x[1],parseInt(x[2])-1,x[3]);
  var current_date=Date.today();
  if(parsed_date.toString()==current_date.toString())
  {
    if(parseInt(x[4])>12)
    {
      var t=" PM"
      x[4]=x[4]-12;
    }
    else
    {
      var t=" AM"
    }
    var a=x[4]+":"+x[5]+t;
  }
  else
  {
    var a=x[3]+"/"+x[2]+"/"+x[1];
  }
  return a;
}

function parse_date(date)
{
  var d=Date.parse(date)
  var year=d.getFullYear();
  var month=d.getMonth();
  var dat=d.getDate();
  var day=d.getDay();
  var month_names = ['January','Febraury','March','April','May','June','July','August','September','October','November','December'];
  var month_short_names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var day_names=['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  var day_short_names=['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  var parsed_date=day_names[day]+", "+month_names[month]+", "+dat+", "+year;
  return parsed_date;
}

function get_filename(path)
{
  pos=path.lastIndexOf("/")
  return path.substring(pos+1);
}

function get_date()
{
  var d=Date.today();
  var year=d.getFullYear();
  var month=parseInt(d.getMonth()+1);
  if(month<10)
    month="0"+month;
  var date=d.getDate();
  return year+'-'+month+'-'+date;
}

function from_date(date_string)
{
  // date string format Friday, March, 25, 2011
  d=date_string.split(',');
  month=find_month(d[1]);
  date=$.trim(d[2]);
  year=$.trim(d[3]);
  return year+'-'+month+'-'+date;

}

function find_month(month)
{
  month=$.trim(month);
  var month_names = ['January','Febraury','March','April','May','June','July','August','September','October','November','December'];
  month_number=month_names.indexOf(month)+1;
  if(month_number<10)
    month_number="0"+month_number;
  return month_number;
}
