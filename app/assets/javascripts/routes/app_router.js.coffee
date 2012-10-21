R12Team33.Router = Em.Router.extend
  enableLogging: true

  root: Ember.Route.extend

    index: Ember.Route.extend
      route: '/'
      redirectsTo: 'links'

    links: Ember.Route.extend
      route: '/links'
      initialState: 'index'

      connectOutlets: (router) ->
        appController = router.get('applicationController')
        appController.fetchUUID()
        appController.fetchCurrentUser()
        appController.connectOutlet('links', R12Team33.Link.find
          uuid: localStorage.getItem('uuid')
        )

R12Team33.router = R12Team33.Router.create(location: 'hash')
