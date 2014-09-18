/*global CKEDITOR, jQuery, downshow, setTimeout */
var $ = $ || jQuery;
CKEDITOR.plugins.add( 'inlinesave',
{
    
    init: function( editor )
    {
        editor.addCommand( 'inlinesave',
            {
                exec : function()
                {

                    addData();
                    
                    function addData() {
                        var data = $("[contenteditable]");
                        var content = data.filter(".post").html();
                        var title = data.filter("h1").children("a").html();
                        var images = content.match(/<img\s+[^>]+\/?>/);
                        content = content.replace(/<img\s+[^>]+\/?>/ig,"||");
                        var dataID = $(data[0]).closest('article').attr('data-id');
                        if (downshow){
                            content = downshow(content);
                            if (images.length > 0){
                                for(var i=0;i<images.length;i++){
                                    content = content.replace("||",images[i]+"\n");
                                }
                            }
                        }
                        var output = { content: content, title: title, id: dataID };
                        
                        $.ajax({

                            type: "POST",

                            //Specify the name of the file you wish to use to handle the data on your web page with this code:
                            //<script>var dump_file="yourfile.php";</script>
                            //(Replace "yourfile.php" with the relevant file you wish to use)
                            //Data can be retrieved from the variable $_POST['editabledata']
                            //The ID of the editor that the data came from can be retrieved from the variable $_POST['editorID']
                            
                            url: '/admin/save/'+dataID,

                            data: output

                        })

                        .done(function (data) {

                            var w = $('body').width();
                            var h = $('body').height();
                            var left = parseInt(Math.round((w - 300) / 2), 10);
                            var top = parseInt(Math.round((h - 100) / 2), 10);
                            var html = '<div id="message-sent" class="panel" style="display:none;width: 300px; height: 100px;z-index:9999;position:absolute;top:'+top+'px;left:'+left+'px;">' +
                                '<section><h5>'+data.title+' updated</h5></section></div>';
                            $('body').append(html);
                            var msg =  $('#message-sent');
                            msg.show();
                            setTimeout(function () {
                                msg.fadeOut(2000).remove();
                            }, 1000);
                            //alert("Your content was successfully saved. [" + jqXHR.responseText + "]");

                        })

                        .fail(function (jqXHR) {

                            alert("Error saving content. [" + jqXHR.responseText + "]");

                        });
                    }

                }
            });
        editor.ui.addButton( 'Inlinesave',
        {
            label: 'Save',
            command: 'inlinesave',
            icon: this.path + 'images/inlinesave.png'
        } );
    }
} );