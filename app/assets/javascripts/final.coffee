# You can use CoffeeScript in this file: http://coffeescript.org/
# SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/
$(document).on 'page:change', ->
  do ( $$ = window.Basimilch, $ = jQuery ) ->
    $('form').submit ->
      # Disable submit button on submit to prevent multiple form submissions.
      $(@).find('[type=submit]')
        .attr('disabled', true)
