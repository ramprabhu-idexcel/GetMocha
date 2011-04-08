$(document).ready(function() {
	
	$('#pass-reset').replaceWith('<span id="pass-reset-js">Forgot Password?</span>');
	$('.wrap').css({'overflow-x':'hidden','overflow-y':'hidden'}).removeClass('under-cup');
	$('#pass-reset-js').css('position','relative');
	$('.reset-form').css({'display':'block', 'top':'60px'});
	$('.login-form').css({'top':'60px'});
	
	
	$('#pass-reset-js').click(function() {
			
			$('.login-form').animate({ left : '-100%' }, {duration:1000, easing:"easeInOutQuart" });
			$('.reset-form').animate({ left : '50%', marginLeft : '-180' }, {duration:1000, easing:"easeInOutQuart" });
			$('#pass-reset-js').replaceWith('<a href="#" id="pass-reset-js">Forgot Password?</a>');
	});
	

  //signup and login
  
    $('#user_signup').live('click',function(){
      $.ajax({
        url:'/users',
        data: $('form#user_new').serialize(),
        type: "POST"        
      });
      return false;
    });
     
   $('#remember_me').live('click',function(){
      if($('#remember_me').is(':checked'))
      {
         $('#remember_hidden_id').val("1")
      }
       else
       {
           $('#remember_hidden_id').val("0")
       }

     });
     
   $('#user_submit').live('click',function(){
             
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
  
 
});

