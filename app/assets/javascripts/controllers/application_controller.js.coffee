R12Team33.ApplicationController = Ember.Controller.extend

  isLoggedIn: false
  isReady: false
  current_user: null
  signin: null
  signout: null

  fetchCurrentUser: () ->
    scope = @
    $.ajax
      url: "/current_user?uuid=#{localStorage.getItem('uuid')}"
      error: (e, xhr, settings) ->
        if e.status is 404
          scope.set('isLoggedIn', false)
          scope.set('current_user', null)
        else
          console.log "Unexpected error:"
          console.log e
      success: (data, text_status, xhr) ->
        scope.set('isLoggedIn', true)
        scope.set('current_user', data.user)
        scope.set('isReady', data.user.ready)

  fetchUUID: () ->
    scope = @
    uuid = localStorage.getItem('uuid')
    console.log "Fetching UUID. Current is:"
    console.log uuid
    if uuid
      scope.set('signin', "/auth/twitter?uuid=#{uuid}")
      scope.set('signout', "/signout?uuid=#{uuid}")
    else
      $.ajax
        url: "/uuid"
        error: (e, xhr, settings) ->
            console.log "Unexpected error fetching UUID:"
            console.log e
        success: (data, text_status, xhr) ->
          console.log data.uuid
          scope.set('signin', "/auth/twitter?uuid=#{data.uuid}")
          scope.set('signout', "/signout?uuid=#{data.uuid}")
          console.log 'setting brand new uuid'
          localStorage.setItem('uuid', data.uuid)
