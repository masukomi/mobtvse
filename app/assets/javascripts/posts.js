$(function() {

  $(".kudo_heart").hover(
      function() {
       $(this).animate({ fontSize: '110%'}, 100);
      },
      function() {
      $(this).animate({ fontSize: '80%'}, 100);
     }
   );


});

function toggleDetails(post_id){
  $("#post_details_" +post_id).slideToggle( 230, 'swing');
  toggleToggler(post_id);
}
function toggleToggler(post_id){
  var toggler = $("#details_toggle_" +post_id);
  if (toggler.hasClass('icon-caret-down')){
    toggler.removeClass('icon-caret-down').addClass('icon-caret-up');
  } else {
    toggler.removeClass('icon-caret-up').addClass('icon-caret-down');
  }
}
