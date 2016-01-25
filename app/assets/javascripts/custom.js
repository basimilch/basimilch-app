// DOC: https://github.com/rails/turbolinks#events
// DOC: http://stackoverflow.com/a/19834224/5764181
$(document).on('ready page:load', function() { ( function( $$, $, undefined ) {
  Turbolinks.enableProgressBar();
  // Initialize Bootstrap popovers
  // Source: http://getbootstrap.com/javascript/#popovers
  $('[data-toggle=popover]').popover();
  $('tr[data-href]').click( function() {
    document.location = $(this).data('href');
  });
}( window.Basimilch = window.Basimilch || {}, jQuery ));});

