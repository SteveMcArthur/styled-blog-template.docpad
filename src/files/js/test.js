       $(function () {
           var items = [];
           var i = 0;

           function containsTxt(txt) {
               for (i = 0; i++; i < items.length) {
                   if (items[i] == txt.toLowerCase()) {
                       return true;
                   }
               }
               return false;
           }
           $('[data-category]').each(function () {
               items.push(this.attr('data-category'));
           });
           $('#categories .item').each(function () {
               if (containsTxt($(this).text())) {
                   $(this).addClass('active');
               }
           });

       });