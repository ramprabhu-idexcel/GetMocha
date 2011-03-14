function addClass(obj)
  {
  	var cName = String(obj.className);
  	
  	if (cName.indexOf("open") == -1){
    	obj.className += " open";
    	/*if (cName.indexOf("unread") != -1){
	   		obj.className = obj.className.replace(/\bunread\b/,'');
		}*/
	    	
    }
    
    return;
  }
  
  
function checkBox(obj)
  {
  	var cName = String(obj.className);
  	
  	if (cName.indexOf("checked") == -1){
    	obj.className += " checked";
    	/*if (cName.indexOf("unread") != -1){
	   		obj.className = obj.className.replace(/\bunread\b/,'');
		}*/
	    	
    }
    
    return;
  }
  