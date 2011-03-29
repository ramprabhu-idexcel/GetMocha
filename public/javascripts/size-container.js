
   function setHeight()
   {
      var sHGT;
      srcobj=document.getElementById('container');
      if (self.innerHeight)
      {
	   sHGT = self.innerHeight;
	}
      else
      { 
         if (document.documentElement && document.documentElement.clientHeight)
         {
	      sHGT = document.documentElement.clientHeight;
         }
         else
         {
            if (document.body)
            {
              sHGT = document.body.clientHeight;
            }
         }
      }
      sHGT=sHGT-(document.getElementById('container').offsetTop);
      	/*if (document.width < 1000){
  			document.getElementById('container').style.height=(sHGT - height of scrollbar) +"px";
  		}
  		else {
  			document.getElementById('container').style.height=sHGT+"px";
  		}
  		*/
  		document.getElementById('container').style.height=sHGT+"px";
   }
   
   function setChatHeight()
   {
      var inputHeight;
      var panelHeight;
      if(document.getElementsByClassName('comment-contain').length>0)
      {
        inputHeight = document.getElementsByClassName('comment-contain')[0].offsetHeight;
        panelHeight = document.getElementsByClassName('r-panel-contain')[0].offsetHeight;
      }
      if(document.getElementsByClassName('chat-container').length>0)
      document.getElementsByClassName('chat-container')[0].style.height = (panelHeight - inputHeight - 30) +"px";
   }


window.onload=function(){
	setHeight();
	setChatHeight();
};

window.onresize=function(){
	setHeight();
	setChatHeight();
};

