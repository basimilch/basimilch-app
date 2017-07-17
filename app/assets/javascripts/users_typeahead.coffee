# SOURCE: http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/
$(document).on 'turbolinks:load', ->
  do ( $$ = window.Basimilch, $ = jQuery ) ->
   if $$.isAdminPage() and $('.users-typeahead').some()
      # DOC: https://github.com/twitter/typeahead.js/tree/v0.11.1
      # DOC: https://twitter.github.io/typeahead.js/examples/
      users = new Bloodhound
        datumTokenizer: (user) ->
          firstNameTokens = Bloodhound.tokenizers.whitespace(user.first_name);
          lastNameTokens  = Bloodhound.tokenizers.whitespace(user.last_name);
          emailTokens     = Bloodhound.tokenizers.whitespace(user.email);
          idTokens        = Bloodhound.tokenizers.whitespace(user.id);
          firstNameTokens.concat(lastNameTokens).concat(emailTokens).concat(idTokens);
        queryTokenizer: Bloodhound.tokenizers.whitespace
        prefetch: '/users.json'
        remote:
          url: '/users.json?q=%QUERY'
          wildcard: '%QUERY'
      users.initialize()
      # DOC: https://github.com/bootstrap-tagsinput/bootstrap-tagsinput/tree/0.8.0
      # DOC: http://bootstrap-tagsinput.github.io/bootstrap-tagsinput/examples/
      usersInput = $('.users-typeahead select[multiple=multiple]')
      usersInput.tagsinput
        itemValue: 'id'
        freeInput: false
        trimValue: true
        maxTags: usersInput.data('max-users')
        itemText: (user) -> user.first_name + " " + user.last_name
        typeaheadjs:[
            hint: false
            highlight: true
          ,
            name: 'users'
            display: (user) -> user.first_name + " " + user.last_name
            source: users.ttAdapter()
            templates:
              pending: [
                '<div class="tt-pending-message">',
                  '<span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>'
                '</div>'
              ].join('\n')
              empty: [
                '<div class="tt-empty-message">',
                  usersInput.data('typeahead-no-suggestions-msg'),
                '</div>'
              ].join('\n')
              suggestion: (user) ->
                [
                  '<div><div>'
                  user.first_name
                  user.last_name
                  '(' + user.id + ')'
                  '</div><div><small><i>'
                  user.email
                  '</i></small></div></div>'
                ].join('\n')
        ]
