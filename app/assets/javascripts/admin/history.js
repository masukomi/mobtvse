(function(window,undefined){

  /* Temporarily disabling this
     functionality because it 
     doesn't work with MObtvse urls
   */
   return false;
  var History = window.History;

  if ( !History.enabled ) {
    return false;
  }

  History.Adapter.bind(window,'statechange',function windowStateChange(){
    var State = History.getState();
    fn.log(State.data, State.title, State.url);

    switch(State.title) {
      case 'admin':

        break;

      case 'edit':

        break;

      case 'new':

        break;
    }
  });

})(window, fn);
