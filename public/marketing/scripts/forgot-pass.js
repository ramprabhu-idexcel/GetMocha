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
	  
 
});

