# You can use CoffeeScript in this file: http://coffeescript.org/
# SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/
$(document).on 'turbolinks:load', ->
  do ( $$ = window.Basimilch, $ = jQuery ) ->
    # SOURCE: http://stackoverflow.com/a/25904582
    # Disable scroll zooming and bind back the click event
    onMapMouseleaveHandler = (event) ->
      $(this).on('click', onMapClickHandler)
             .off('mouseleave', onMapMouseleaveHandler)
             .find('iframe').attr('disabled', true)
      # Enable scroll zooming and bind back the mouseleave event
    onMapClickHandler = (event) ->
      $(this).off('click', onMapClickHandler)
             .on('mouseleave', onMapMouseleaveHandler)
             .find('iframe').attr('disabled', false)
    # Enable map zooming with mouse scroll only when the user clicks the map
    $('.embedded-map-container').click onMapClickHandler
