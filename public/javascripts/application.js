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





