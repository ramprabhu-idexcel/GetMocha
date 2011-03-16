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
  
  
 if(typeof Edit!="undefined" && Edit==true)
  {
     //Edit the User profile
    
    $('#txt_firstname').hide();
    $('#txt_lastname').hide();
    $('#txt_email').hide();
    $('#txt_password').hide();
    $('#txt_title').hide();

    $('#save_firstname').hide();
    $('#save_lastname').hide();
    $('#save_title').hide();
    $('#save_email').hide();


    $('#myprofile2').hide();
    $('#mycontact2').hide();

    $('.user_drop_down').click(function(){
    $('.account-dropdown').toggle();
    });
  
    $('#colorSelector').ColorPicker({
	color: '#0000ff',
	onShow: function (colpkr) {
		$(colpkr).fadeIn(500);
		return false;
	},
	onHide: function (colpkr) {
		$(colpkr).fadeOut(500);
       var a=$('#choose_color').val();
    $.ajax({
     	url: "/edit_profile",        
      type :"put",
      data :{color: $('#choose_color').val()}
    });
   		return false;
	},
	onChange: function (hsb, hex, rgb) {
		$('#choose_color').css('backgroundColor', '#' + hex);
    $('#choose_color').val(hex);
	}
});

  //To edit the first_name
 	$('#first_name').click(function(){
    $('#label_first_name').hide();
    $('#txt_firstname').show(); 
    $('#first_name').hide();
    $('#save_firstname').show(); 
     
  	$('#save_firstname').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[first_name]" : $('#txt_firstname').val()}
        });
    $('#label_first_name').show();
    $('#txt_firstname').hide(); 
    $('#first_name').show();
    $('#save_firstname').hide(); 
         
   });
   
    });
    
    
  //To edit the last_name  
    $('#last_name').click(function(){
    $('#label_last_name').hide();
    $('#txt_lastname').show(); 
    $('#last_name').hide();
    $('#save_lastname').show(); 
     
  	$('#save_lastname').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[last_name]" : $('#txt_lastname').val()}
        });
    $('#label_last_name').show();
    $('#txt_lastname').hide(); 
    $('#last_name').show();
    $('#save_lastname').hide(); 
         
   });
   
    });
    
    //To edit the title
    
    $('#title').click(function(){
    $('#label_title').hide();
    $('#txt_title').show(); 
    $('#title').hide();
    $('#save_title').show(); 
     
  	$('#save_title').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[title]" : $('#txt_title').val()}
        });
    $('#label_title').show();
    $('#txt_title').hide(); 
    $('#title').show();
    $('#save_title').hide(); 
         
   });
   
    });
    
        
   //To edit the email
    
   $('#email').click(function(){
    $('#label_email').hide();
    $('#txt_email').show(); 
    $('#email').hide();
    $('#save_email').show(); 
     
  	$('#save_email').click(function(){
        $.ajax({
         url:"/updates/edit_profile",
          type: "put",
          data:{"user[email]" : $('#txt_email').val()}
        });
    $('#label_email').show();
    $('#txt_email').hide(); 
    $('#email').show();
    $('#save_email').hide(); 
         
   });
   
    });
    
    
 	
	
   $('#mycontact1').click(function(){
      $('#user_information').hide();
      $('#myprofile2').show();
      $('#myprofile1').hide();
      $('#mycontact1').hide();
      $('#mycontact2').show();
      $('.drag-drop').hide();
      $.ajax({
     	url: "/edit_profile",        
        }); 
     
     
      });
   $('#myprofile2').click(function(){
       $('#user_information').show();
       $('#myprofile2').hide();
       $('#myprofile1').show();
       $('#mycontact1').show();
       $('#mycontact2').hide();
       
   });
   
 } 

  // user account-dropdown
  
  $('.user_drop_down').click(function(){
    $('.account-dropdown').toggle();
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
			 document.getElementById('add_new_mod').innerHTML=data;  
       }
    });
}
function add_new_message()
{
  $.ajax({
       type :'get',
       url :"/messages/new",
            success: function(data){
			 document.getElementById('add_new_mod').innerHTML=data;  
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
       success: function(){
         $('.add-item-modal').hide();
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
       success: function(){
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
