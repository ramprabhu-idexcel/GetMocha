// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  
  
  
  
  $('#txt_firstname').hide();
  $('#txt_lastname').hide();
  $('#txt_email').hide();
  $('#txt_password').hide();
  $('#save_firstname').hide();


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

 	$('#first_name').click(function(){
    $('#label_first_name').hide();
    $('#txt_firstname').show(); 
    $('#first_name').hide();
    $('#save_firstname').show(); 
     
  	$('#save_firstname').click(function(){
        $.ajax({
         url:"/edit_profile",type: "put",data:{first_name : $('#txt_firstname').val()}
        });
    $('#label_first_name').show();
    $('#txt_firstname').hide(); 
    $('#first_name').show();
    $('#save_firstname').hide(); 
         
   });
   
    });
    
    
 	$('#last_name').click(function(){
    $('#label_last_name').hide();
    $('#txt_lastname').show(); 
    $(this).text('Save');
    });
    
    
      
 	$('#email').click(function(){
    $('#label_email').hide();
    $('#txt_email').show(); 
    $(this).text('Save');
    });
    
        
 	$('#password').click(function(){
    $('#label_password').hide();
    $('#txt_password').show(); 
    $(this).text('Save');
    });
	
  
  
  
  
  
  

  // user account-dropdown
  
  $('.user_drop_down').click(function(){
    $('.account-dropdown').toggle();
  });
  
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
            window.location.href="/projects/new";
          }
        }
      });
      return false;
    });
  }
      
  $('#p_add').click(function(){
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
  });
    
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
