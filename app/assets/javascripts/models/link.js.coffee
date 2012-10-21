R12Team33.Link = DS.Model.extend

  primaryKey: 'id'

  title: DS.attr('string')
  summary: DS.attr('string')
  id: DS.attr('number')
  url: DS.attr('string')
  thumbnail_url: DS.attr('string')
  created_at: DS.attr('number')
  user_screen_name: DS.attr('string')

  js_created_at: (->
    jQuery.timeago(new Date(@get('created_at') * 1000))
  ).property('created_at')
