jQuery( function() { ( function( $$, $, undefined ) {
  // Initialize Bootstrap popovers
  // Source: http://getbootstrap.com/javascript/#popovers
  $('[data-toggle=popover]').popover();
  $('tr[data-href]').click( function() {
    document.location = $(this).data('href');
  });
}( window.Basimilch = window.Basimilch || {}, jQuery ));});