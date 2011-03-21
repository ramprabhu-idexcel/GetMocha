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
        
    $("form#user_login").validate({
      rules: {
                'user[email]': {
                required : true
              }
            },
        messages: {
          'user[email]': "can't be blank"
        },
        errorPlacement: function(error, element) {

        },
        debug:true
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
  }
  
  
 if(typeof UserEdit!="undefined" && UserEdit==true)
  {
    
    
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

     //Edit the User profile
  
  //To edit the first_name
  $('#first_name').css('visibility','visible');
 	$('#first_name').click(function(){
    $('#label_first_name').hide();
    $('#txt_firstname').show(); 
    $('#first_name').css('visibility','hidden');
    $('#save_firstname').css('visibility','visible');
    return false;
    });
    
    $('#save_firstname').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[first_name]" : $('#txt_firstname').val()},
          success:function(data){
		      		//$('#first_name_display').html(data);
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
       
   });
    
    
  //To edit the last_name  
    $('#last_name').css('visibility','visible');
    $('#last_name').click(function(){
    $('#label_last_name').hide();
    $('#txt_lastname').show(); 
    $('#last_name').css('visibility','hidden');
    $('#save_lastname').css('visibility','visible');
    return false;
       });
       
  	$('#save_lastname').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[last_name]" : $('#txt_lastname').val()},
        success:function(data){
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
   });
   

    
    //To edit the title
    $('#title').css('visibility','visible');
    $('#title').click(function(){
    $('#label_title').hide();
    $('#txt_title').show(); 
    $('#title').css('visibility','hidden');
    $('#save_title').css('visibility','visible');
    return false;
     });
     
  	$('#save_title').click(function(){
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
    $('#email').css('visibility','visible');
    $('#email').click(function(){
    $('#label_email').hide();
    $('#txt_email').show(); 
    $('#email').css('visibility','hidden');
    $('#save_email').css('visibility','visible');
    return false;
   });
     
  	$('#save_email').click(function(){
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
  });
   
   
    
    //To edit the phone no
   $('#phone').css('visibility','visible');
   $('#phone').click(function(){
   $('#label_phone').hide();
   $('#txt_phone').show(); 
   $('#phone').css('visibility','hidden');
   $('#save_phone').css('visibility','visible');
   return false;
   
    });
     
  	$('#save_phone').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[phone]" : $('#txt_phone').val()},
         success:function(data){
          if(data.success!="undefined")
           {
              $('#label_phone').text(data.success)
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
   $('#mobile').css('visibility','visible');
   $('#mobile').click(function(){
    $('#label_mobile').hide();
    $('#txt_mobile').show(); 
   $('#mobile').css('visibility','hidden');
   $('#save_mobile').css('visibility','visible');
    return false;
    });
     
  	$('#save_mobile').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[mobile]" : $('#txt_mobile').val()},
         success:function(data){
          if(data.success!="undefined")
           {
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
    
    $('#save_time_zone').click(function(){
         $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[time_zone]" : $('#time_zone').val()}
        });
        return false;
       });
    
    //To edit the password
   $('#password').css('visibility','visible');
   $('#password').click(function(){
    $('#label_password').hide();
    $('#txt_password').show(); 
     $('#confirm').show(); 
     $('#confirm_pass').show();
     $('#txt_confirm').show();
     $('#password').css('visibility','hidden');
    $('#save_confirm').css('visibility','visible');
    //~ $('#save_password').show(); 
     return false;
      });
     
  	$('#save_confirm').click(function(){
       
       if (($('#txt_confirm').val())!=($("#txt_password").val()))
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
   
	
     $('#mycontact1').click(function(){
        $('#mycontact1').toggleClass('open')
        $('#my_profile').hide();
        $('#myprofile1').toggleClass('open')
        $('#my_contacts').show();
        return false;
      });
      
    $('#myprofile1').click(function(){
      $('#mycontact1').toggleClass('open')
        $('#my_profile').show();
        $('#myprofile1').toggleClass('open')
        $('#my_contacts').hide();
        return false;

   });
   
  $('a#add_new_email').click(function(){
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
    
  //To upload the profile image
  /*
    $('#attach').fileUploadUI({
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
        
    
    $('.star.star_items').live('click',function(){
      var id=$('.message.messow.open').attr('id').split('msac')[1];
      $.ajax({
        url: '/star_message/'+id,
        type: 'get'
      });
      return false;
    });

    $('.message-star').live('click',function(){
      var path=$(this).attr('href');
      $(this).parent('div.message-body').parent('div.message').toggleClass('starred');
      $.ajax({
        url: path,
        type: 'get'
      });
      return false;
    });
    
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
    
    hide_header(); //hide the message headers initially
    hide_comment(); //hide the comment header initially
  
  }
  
  //Message second panel click function  
  $('.messow').live('click',function(){
    var id=$(this).attr('id').split('msac')[1];
    var primarUrl=(window.location+'').split('#')[0];
    var secondaryUrl=(window.location+'').split('#')[1];
    var loc=secondaryUrl.split('/')[0];
    window.location=primarUrl+"#"+loc+"/"+id;
    $('.message.messow.open').removeClass('open');
    $(this).removeClass('unread');
    $(this).addClass('open');
    $('.message_header').show(); 
  });
    
  //message reply link 
  $('.reply').click(function(){
    $('.comment-contain').slideToggle('slow');
    $('#comment-message').focus();
    return false;  
  });
  
  //message reply link in the expanded comment
  $('.reply-link').live('click',function(){
    $('.comment-contain').slideToggle('slow');
    $('#comment-message').focus();
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
        var comment=data.comment[0];
        reply+=('<div class="message message_comments '+(comment.is_starred ? "starred" : "" )+' " ><div class="message-body"><a class="message-star" href="#">Star</a>');
        reply+=('<a class="name message_name" href="#">'+comment.user+'</a><div class="has-attachment"></div><span class="message-time">'+comment.created_at+'</span>');
        reply+=('<div class="comment"><p>'+comment.comment+'</p>');
        reply+=('<a class="reply-link" href="#">Reply</a></div></div></div>');
        $('.prev-messages').append(reply).show('slow');
        $('.comment-contain').toggle('slow');
      }
    });
    return false;
   });
   
   
    
    
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
  
});//End of doc


function add_new_modal()
{
  $('#add_new_mods').show()
  /*$.ajax({
       type :'post',
       url :"/projects/add_new",
            success: function(data){
           document.getElementById('add_new_mod').innerHTML=data;  
       }
    });*/
 
}
function add_new_project()
{
  $.ajax({
       type :'get',
       url :"/projects/new",
            success: function(data){
			 $('#add_new_mod').html(data); 
       }
    });
      $('#add_new_mods').hide()
}
function add_new_message()
{
  $.ajax({
       type :'get',
       url :"/messages/new",
            success: function(data){
			$('#add_new_mod').html(data); 
       }
    });
       $('#add_new_mods').hide()
}
function project_cancel_button()
{
 $('.add-item-modal').hide()
    
}

function project_save_button()
{
var a=$('#data_name').val();
    var b=$('#data_invites').val();
    var c=$('#data_message').val();
    $.ajax({
       type :'post',
       url :"/projects",
       data : $('#form1').serialize(),
       success: function(data){
if(data.length==1)
         $('.add-item-modal').hide();
       },
	failure: function(){
alert("hi");
}
    });
}
function message_cancel_button()
{
$('.add-item-modal').hide()
}
	function message_save_button()
{
  $('#form2').submit();
$('.file_upload_start button').click();


 /*$.ajax({
       type :'post',
       url :"/messages",
       data : $('#form2').serialize(),
       success: function(data){
if(data.length==1)
         $('.add-item-modal').hide();
       }
    });*/
}
$('#start_uploads').click(function () {
    $('.file_upload_start button').click();
});

// Function for displaying third panel in project settings
function settings_thirdpanel(page)
{
if(page=="people")
{
document.getElementById('people_anchor').className="m-tab alt open";
document.getElementById('general_anchor').className="m-tab alt";
document.getElementById('settings_general').style.display="none";
document.getElementById('settings_people').style.display="block";
}
else
{
document.getElementById('general_anchor').className="m-tab alt open";
document.getElementById('people_anchor').className="m-tab alt";
document.getElementById('settings_people').style.display="none";
document.getElementById('settings_general').style.display="block";
}
}

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
