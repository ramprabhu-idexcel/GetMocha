function setChatHeight()
   {
	  var inputHeight;
      var panelHeight;
      inputHeight = document.getElementsByClassName('comment-contain')[0].offsetHeight;
      panelHeight = document.getElementsByClassName('popout-contain')[0].offsetHeight;
      document.getElementsByClassName('chat-container')[0].style.height = (panelHeight - inputHeight - 30) +"px";
   }

	
window.onload=function(){
	setChatHeight();
};

window.onresize=function(){
	setChatHeight();
};
