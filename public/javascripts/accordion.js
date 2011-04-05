$(document).ready(function() {
 	
 	$(".accordion .content").hide();
	//ACCORDION BUTTON ACTION	
	
	$('.accordion .row').click(function() {
		if (!$(this).hasClass('open')){
			$('.accordion .content').slideUp('normal');
			$('.accordion .row').removeClass('open');
			$(this).addClass('open');
			
			
			/* Corrects for jumping bug in slideDown() */
			
			var $div = $(this).children(".accordion .content");
			
			$div.css({visiblity:'hidden',position:'absolute',display:'inline'})
			var divHeight = $div.height();
			$div.css({visiblity:'visible',position:'static',display:'block'});
			
			$div.css({ height : 0 });
	
			$div.show().animate({ height : divHeight }, {duration:500, easing:"easeInOutQuart" }, function(){
				$div.height('auto');
			})	
		}
	});
 
});


