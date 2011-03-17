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
 	$('#first_name').click(function(){
    $('#label_first_name').hide();
    $('#txt_firstname').show(); 
    $('#first_name').hide();
    $('#save_firstname').show(); 
    
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
    $('#save_firstname').hide(); 
    $('#label_first_name').show();
    $('#first_name').show();       
   });
    
    
  //To edit the last_name  
    $('#last_name').click(function(){
    $('#label_last_name').hide();
    $('#txt_lastname').show(); 
    $('#last_name').hide();
    $('#save_lastname').show(); 
     
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
    $('#save_lastname').hide(); 
    $('#label_last_name').show();
   $('#last_name').show();
     
   });
   

    
    //To edit the title
    
    $('#title').click(function(){
    $('#label_title').hide();
    $('#txt_title').show(); 
    $('#title').hide();
    $('#save_title').show(); 
     });
     
  	$('#save_title').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[title]" : $('#txt_title').val()},
           success:function(data){
          if(data.success!="undefined")
           {
              $('#label_title').text(data.success)
             }
           else
           {
             alert(data.error);
           }
			}			
          
        });
    
    $('#txt_title').hide(); 
    $('#save_title').hide(); 
    $('#label_title').show();     
    $('#title').show();
      
   });
   

    
        
   //To edit the email
    
   $('#email').click(function(){
    $('#label_email').hide();
    $('#txt_email').show(); 
    $('#email').hide();
    $('#save_email').show(); 
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
    $('#save_email').hide(); 
     $('#label_email').show();
    $('#email').show();
   
   });
   
   
    
    //To edit the phone no
    
   $('#phone').click(function(){
    $('#label_phone').hide();
    $('#txt_phone').show(); 
    $('#phone').hide();
    $('#save_phone').show(); 
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
             }
           else
           {
             alert(data.error);
           }
			}			
        });
    
    $('#txt_phone').hide(); 
    $('#save_phone').hide(); 
    $('#label_phone').show();
     $('#phone').show();
         
   });
   

    
        //To edit the mobile no
    
   $('#mobile').click(function(){
    $('#label_mobile').hide();
    $('#txt_mobile').show(); 
    $('#mobile').hide();
    $('#save_mobile').show(); 
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
             }
           else
           {
             alert(data.error);
           }
			}			
        });
    
    $('#txt_mobile').hide(); 
    $('#save_mobile').hide(); 
    $('#label_mobile').show();
     $('#mobile').show();
         
   });
   

    
    //To edit the Timezone
    
    $('#save_time_zone').click(function(){
         $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[time_zone]" : $('#time_zone').val()}
        });
       });
    
    //To edit the password
    
   $('#password').click(function(){
    $('#label_password').hide();
    $('#txt_password').show(); 
    $('#password').hide();
    $('#save_password').show(); 
     
  	$('#save_password').click(function(){
        $.ajax({
         url:"/updates/edit_password",
          type: "put",
          data:{"password" : $('#txt_password').val()}
        });
    $('#label_password').show();
    $('#txt_password').hide(); 
    $('#password').show();
    $('#save_password').hide(); 
         
   });
   
    });
    
 	
	
     $('#mycontact1').click(function(){
        $('#mycontact1').toggleClass('open')
        $('#my_profile').hide();
        $('#myprofile1').toggleClass('open')
        $('#my_contacts').show();
     
     
      });
    $('#myprofile1').click(function(){
      $('#mycontact1').toggleClass('open')
        $('#my_profile').show();
        $('#myprofile1').toggleClass('open')
        $('#my_contacts').hide();
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
  
  
      
 /* $('#p_add').click(function(){
    var a=$('#data_name').val();
    var b=$('#data_invites').val();
    var c=$('#data_message').val();
    $.ajax({
       type :'post',
       url :"/projects",
       data : $('#form1').serialize(),
       success: function(){
         $('.add-item-modal').hide();
       }
    });
  });
  
  $('#p_can').click(function(){
    $('.add-item-modal').hide()
  });
  $('#m_add').click(function(){
    
    $.ajax({
       type :'post',
       url :"/messages",
       data : $('#form2').serialize(),
       success: function(){
         $('.add-item-modal').hide();
       }
    });
  });
  
  $('#m_can').click(function(){
    $('.add-item-modal').hide()
  });*/
    
});
function add_new_modal()
{
  $.ajax({
       type :'post',
       url :"/projects/add_new",
            success: function(data){
			 document.getElementById('add_new_mod').innerHTML=data;  
       }
    });
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
 $.ajax({
       type :'post',
       url :"/messages",
       data : $('#form2').serialize(),
       success: function(data){
if(data.length==1)
         $('.add-item-modal').hide();
       }
    });
}


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
