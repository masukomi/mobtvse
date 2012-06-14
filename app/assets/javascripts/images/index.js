$('.images_in_month .image_link').mouseover(function(obj) {
  $('#image_preview').innerHTML('<img src="'+obj.attr('href')+'">');
});

