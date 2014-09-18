/** Global window, document **/

  

 function scrollFn(){
        var scrollTop = window.screenY;
	    var headerHeight =  document.getElementById('header').offsetHeight;
	    var navEl = document.getElementById('nav');
	 	console.log('scroll top : ' + scrollTop);
        if(scrollTop >= headerHeight)  {
            navEl.className += 'fixed';
        } 

        if(scrollTop < headerHeight)
        {
              navEl.className = navEl.className.replace( /(?:^|\s)fixed(?!\S)/g , '' );
        }
    }

document.onscroll = scrollFn;