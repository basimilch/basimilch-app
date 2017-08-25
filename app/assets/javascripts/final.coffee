# You can use CoffeeScript in this file: http://coffeescript.org/
# SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/

do ( $$ = window.Basimilch ||= {}, $ = jQuery ) ->

  $(document).on 'turbolinks:load', ->
    $$.loadingScreen.stop()
    $('form').submit ->
      # Disable submit button on submit to prevent multiple form submissions.
      $(@).find('[type=submit]')
        .attr('disabled', true)
      $$.loadingScreen.start()
    # DOC: http://bootstrapdocs.com/v3.3.6/docs/javascript/#tooltips
    $('[data-toggle="tooltip"]').tooltip()
    # DOC: http://bootstrapdocs.com/v3.3.6/docs/javascript/#tabs-usage
    $('#myTabs a').click (e) ->
      e.preventDefault()
      $(this).tab('show')
