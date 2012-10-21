# Catchup

## Idea

Summary view of your twitter timeline, which will show only metadata (title, image if any, small description, etc) about urls shared on twitter with you (home timeline).

The idea is that you won't miss the interesting stuff shared on your timeline if you don't read twitter for a couple of days. Besides, it will be faster to go through your timeline because you won't have to click on the links that don't look interesting, based on the preview.

If you like 404 pages, check out http://catchup.r12.railsrumble.com/wat featuring my 'soon to be' iPhone sleeve...

## Technologies

The technology stack used in this project is devided in sections and described below.

### Configuration management

In order to setup the server and install the necessary software, I used [Opscode's chef](http://www.opscode.com/chef/).

### Web infrastructure

The Rails applications runs behind [nginx](http://nginx.org/en/) and [unicorn](https://github.com/defunkt/unicorn)

### Database

The database behind the application is [riak](https://github.com/basho/riak), a distributed, decentralized data storage system.

### Authentication

The authentication is done using twitter and the [twitter omniauth's gem](https://github.com/arunagw/omniauth-twitter).

### Front-end javascript frameworks

The front-end javascript is using mostly [ember.js](http://emberjs.com), which is an amazing framework for building web applications. I am also using [jQuery](http://jquery.com).

### Front-end markup/css

I used [twitter bootstrap's](http://twitter.github.com/bootstrap/) libraries.

### APIs

There are a number of APIs/gems being used:

- The [twitter](https://dev.twitter.com/docs) API and the [gem](https://github.com/sferik/twitter);
- [Pismo's](https://github.com/peterc/pismo) gem, which allows content extraction from webpages;
- [Diffbot's](http://www.diffbot.com) API (Free tier).

Check the `Gemfile` for more information about which gems are being used.


### Background job processing

[Resque](https://github.com/defunkt/resque) is being used to fetch tweets and metadata per url.

## Dependencies

Make sure you have the following installed in your system:

- standard ruby stack (rbenv, ruby 1.9.3 etc)
- riak 1.2
- redis

## Running locally

If you already installed the dependencies, run:

    bundle install

And then:

    foreman start -f Procfile.dev

This will start the localhost server on port 5000 and the resque workers.

## Deployment

This project uses capistrano for deployemt:

    bundle exec cap deploy:cold

and then:

    bundle exec cap deploy

Make sure you have twitter.yml and diffbot.yml in your project (and in gitignore). Capistrano
will copy those files to the production location.
