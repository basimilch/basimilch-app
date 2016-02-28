# DOC: ORGANIZING JAVASCRIPT IN RAILS APPLICATION WITH TURBOLINKS
#      http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/

window.Basimilch ||= {}

# SOURCE: http://www.sitepoint.com/url-parameters-jquery/
Basimilch.urlParam = (name) ->
  results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href);
  {
    isPresent: -> return (results != undefined && results != null)
    val:       -> return if results then results[1] else undefined
  }

Basimilch.isAdminPage = -> $('body.admin').length == 1

Basimilch.setupFilterAction = (elemId, targetURL, queryParamName) ->
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
    $('tr[data-href]').click (e) ->
      document.location = $(this).data('href') unless $(e.target).is('a')
