# DOC: ORGANIZING JAVASCRIPT IN RAILS APPLICATION WITH TURBOLINKS
#      http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/

do ( $$ = window.Basimilch ||= {}, $=jQuery ) ->
  $.extend $$,
    # SOURCE: http://www.sitepoint.com/url-parameters-jquery/
    urlParam: (name) ->
      results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href);
      {
        isPresent: -> return (results != undefined && results != null)
        val:       -> return if results then results[1] else undefined
      }

    isAdminPage: -> $('body.admin').length == 1

    setupFilterAction: (elemId, targetURL, queryParamName) ->
      $('#' + elemId).change ->
        $('body').css 'cursor', 'wait'
        val = $(@).val()
        queryParamRegExp = new RegExp "[?&]" + queryParamName + "=[^&]*(?:&|$)"
        queryString = location.search
                              .replace(queryParamRegExp, "")
                              .replace(/^([^?])/, "?$1") # Ensure it begins with '?'
        appendChar = if queryString then "&" else "?"
        location.href = targetURL + queryString +
          ( if val then appendChar + queryParamName + "=" + val else "")

    # SOURCE: https://github.com/slipstream/SlipStreamUI/blob/fdcf44aa/clj/resources/static_content/js/request.js#L70-L88
    loadingScreen:
      start: ->
        $('#loading-screen').removeClass 'hidden'
        $('#loading-screen .backdrop').stop().animate {opacity: 0.25}, 400
      stop: ->
        $('#loading-screen:not(.hidden) .backdrop').stop().animate {opacity: 0}, 200, 'swing', ->
            $('#loading-screen').addClass('hidden')

  # Array prototype extensions
  $.extend Array.prototype,
    contains: (thing) -> ($.inArray(thing, @) == -1) ? false : true

  # String prototype extensions
  $.extend String.prototype,
    # Replaces each nth occurrence of a number with the correponding nth argument.
    # If the nth argument is 'null' or 'undefined', the nth number is not updated.
    # DOC: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace
    updateNumber: (newNumber1, newNumber2, ...) ->
      i = 0
      all_numbers_re = /\d+(?:\.\d+)?/g
      newNumbers = Array.prototype.slice.call arguments
      this.replace all_numbers_re, (match) -> newNumbers[i++] || match

  # jQuery extensions
  $.fn.extend
    # Like normal 'data(key, value)' but triggers 'datachange' event.
    # SOURCE: http://stackoverflow.com/a/16781831
    setData: (key, value) -> $(this).data(key, value).trigger('datachange')
    # Updates the text of the matching element by applying the function f to the
    # current text.
    updateText: (f) -> this.text(f(this.text()))
    # Updates the value of the matching element by applying the function f to the
    # current value.
    updateVal: (f) -> this.val(f(this.val()))
    # Returns true if the current selection contains at least one element.
    some: -> this.length > 0
    # Returns true if the current selection does not contain any elements.
    none: -> this.length = 0
    # Returns true if the current element or any parent matches the selector 'sel'.
    containedIn: (sel) -> this.closest(sel).some()



# DOC: https://github.com/rails/turbolinks#events
# DOC: http://stackoverflow.com/a/19834224
# $(document).on 'ready page:load', ->

# SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/
$(document).on 'page:change', ->
  # SOURCE: http://stackoverflow.com/a/7736247
  do ( $=jQuery ) ->
    Turbolinks.enableProgressBar();
    # Initialize Bootstrap popovers
    # SOURCE: http://getbootstrap.com/javascript/#popovers
    $('[data-toggle=popover]').popover()
    $('[data-href]').click (e) ->
      document.location = $(this).data('href') unless $(e.target).containedIn('a')
