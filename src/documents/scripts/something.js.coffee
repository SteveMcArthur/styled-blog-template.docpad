elements = document.getElementsByTagName("*")
[].filter.call elements, (el) =>
    if el.currentStyle
        return el.currentStyle['backgroundImage'] isnt 'none'
    else if window.getComputedStyle
        return document.defaultView.getComputedStyle(el,null).getPropertyValue('background-image') isnt 'none'