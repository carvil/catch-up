R12Team33.ApplicationView = Ember.View.extend
  templateName: 'application'
  classNames: ['ember-view-master']
  isLoggedInBinding: 'controller.isLoggedIn'
  isReadyBinding: 'controller.isReady'
  signinBinding: 'controller.signin'
  signoutBinding: 'controller.signout'
