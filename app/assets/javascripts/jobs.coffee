# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

do ( $$ = window.Basimilch ||= {}, $ = jQuery ) ->

  # $(document).on 'ready page:load', (($$, $)->
  # SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/

  $(document).on 'turbolinks:load', ->
    $('#job_job_type_id').change ->
      $('body').css 'cursor', 'wait'
      location.href = $(@).data('targetUrl') + "?job_type=" + $(@).val()
    $$.setupFilterAction 'job_type_filter_selector', "job_type"
    $$.setupFilterAction 'job_month_filter_selector', "month"
    if $$.isAdminPage()
      usersInput = $('#users')
      submitBtn = $('.signup-other-users input[type=submit]')
      usersInput.on 'itemAdded itemRemoved', (e) ->
        # e.item: contains the item
        submitBtn.prop 'disabled', not usersInput.val()
