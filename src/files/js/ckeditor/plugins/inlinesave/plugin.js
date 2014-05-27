CKEDITOR.plugins.add( 'inlinesave',
{

    init: function( editor )
	{
		editor.addCommand( 'inlinesave',
			{
				exec : function( editor )
				{

					addData();
					
					function addData() {
						var data = editor.getData();
                        var images = data.match(/<img\s+.+\/>/);
                        console.log("IMAGES: "+images.length);
                        data = data.replace(/<img\s+.+\/>/ig,"||");
                        var editable = editor.editable();
                        var editEl = $(editable.$);
						var dataID = editEl.closest('article').attr('data-id');
                        if (downshow){
                            data = downshow(data);
                            if (images.length > 0){
                                for(var i=0;i<images.length;i++){
                                    data = data.replace("||",images[i]);
                                }
                            }
                            if (editEl.hasClass('post')){
                                data = { content: data, id: dataID }
                            }
                                
                            console.log(data);
                        } else {
                            data = { editabledata: data, id: dataID }
                        }
						
						jQuery.ajax({

							type: "POST",

							//Specify the name of the file you wish to use to handle the data on your web page with this code:
							//<script>var dump_file="yourfile.php";</script>
							//(Replace "yourfile.php" with the relevant file you wish to use)
							//Data can be retrieved from the variable $_POST['editabledata']
							//The ID of the editor that the data came from can be retrieved from the variable $_POST['editorID']
							
							url: '/admin/save/'+dataID,

							data: data

						})

						.done(function (data, textStatus, jqXHR) {

							alert("Your content was successfully saved. [" + jqXHR.responseText + "]");

						})

						.fail(function (jqXHR, textStatus, errorThrown) {

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