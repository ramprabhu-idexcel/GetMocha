// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

  $('.user_drop_down').click(function(){
    $('.account-dropdown').toggle();
  });
  

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
  
  
});





