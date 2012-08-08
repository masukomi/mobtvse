MObtvse
================
MObtvse is an easy to use blogging platform for people 
who love Markdown and want a clean web based interface 
for creating those posts without sacrificing functionality.

It is my firm belief that lovers of Markdown should no longer 
have to live as second class citizens. We deserve awesome features, 
and easy to use blogging tools without having to use crudely 
implemented Markdown add-ons to other people's bloatware.

Inspired by [Svbtle](http://svbtle.com) and bootstrapped by 
[Obtvse](https://github.com/NateW/obtvse).  MObtvse has 
come a long way, allowing for easy image uploads to Amazon's S3, 
or simply managing images uploaded elsewhere, but used in 
your posts. MObtvse has support for static pages (like an "About" 
page), taggable posts, comments via [Disqus](http://disqus.com) 
(excellent spam prevention), and Svbtle-style Kudos, and a dynamic 
Archives page that integrates favorite posts (via Kudos), breaks your 
posts down by month and allows for easy filtering via tags. 

Geeks will be happy to know about its  [Haml](http://haml-lang.com/) 
based markup (partially implemented) and [MongoDB](www.mongodb.org) 

Everyone will be happy to know that there are screenshots available at 
the bottom of this document, and a demo server is set up for you to kick 
the tires on before you try your own installation. Just scroll down to the 
"Test Drive" section below. 

## Before you download...
WordPress has had years to make its installation process almost 
completely painless. Being a relatively new platform MObtvse 
still requires a little bit of geekness, and familiarity with 
installing Rails apps to get installed. But, the basics are all documented 
and a step-by-step installation walk-through is in the works. 

### Planned
The goal is to add support for:

* Generation of static html files for fast serving, or tools 
  for making that easily implementable.
* [Mixpanel](http://mixpanel.com/)
* The MetaWeblog API
* Great features that HTML based blogging platforms like Wordpress 
  have had for years.

See [the major ToDo items here](https://github.com/masukomi/mobtvse/blob/experimental/ToDo.mkdn).

## The New Hotness
Want the *latest* tweaks, the *bleeding edge* functionality? Check out the "experimental" branch. New changes are pushed to experimental where they are allowed to percolate for a little while to increase stability, and catch any wayward bugs before they're pushed to the "master" branch. This also helps to minimize the churn in the "master" branch. 

## Take it for a test drive!
You can try out the recent changes from the "experimental" branch on our demo box, but **Please Note:** The demo is running on a free Heroku instance and may take a few seconds to boot up. For real-world performance you can see [the author's blog](http://weblog.masukomi.org).  

The home page is [here](http://blazing-rain-3059.herokuapp.com/) and the admin page is [here](http://blazing-rain-3059.herokuapp.com/admin)

* username: username
* password: password 

## Take it for a test drive!
You can try out the recent changes from the "experimental" branch on our demo box. 

The home page is [here](http://blazing-rain-3059.herokuapp.com/) and the admin page is [here](http://blazing-rain-3059.herokuapp.com/admin)

* username: username
* password: password 

Free MongoDB hosts
==================
If you want to run this on Heroku you're going to need somewhere to put your MongoDB install. Fortunately [MongoLab](https://mongolab.com/home) and [MongoHQ](https://mongohq.com/home) both have free plans. We'd recommend going with MongoHQ simply because they offer fifteen times more free storage than MongoLab (240Mb vs 16Mb). MObtvse can, of course, point to your own MongoDB install if you have one. 


Installation
============

## Requirements
* Ruby 1.9.x (it's time to upgrade folks)
* Ruby Gems and Bundler 
* A MongoDB install to point it at (install locally or use one of the free/paid hosting options). 

If you are new to Rails development, check out guides for getting your development environment set up for [Mac](http://astonj.com/tech/setting-up-a-ruby-dev-enviroment-on-lion/) and [Windows](http://jelaniharris.com/2011/installing-ruby-on-rails-3-in-windows/).

    git clone git://github.com/masukomi/mobtvse.git
    cd mobtvse
    bundle install

Edit `config/config.yml` to set up your site information.  To set up your admin username and password you will need to set your environment variables (see below) or store them in the config.yml. 

Edit `config/mongoid.yml` to point to your mongodb installation (more details below).

Start the local server:

    bundle exec rails server thin

Go to [0.0.0.0:3000](http://0.0.0.0:3000/), to administrate you go to [/admin](http://0.0.0.0:3000/admin)

For production, you will want to set your password in config.yml or with environment variables (preferred).  If you are deploying to Heroku you can edit and run `script/heroku_env.sh` shell script to set up your environment variables and push them to Heroku. Do this *after* deploying the app to Heroku the first time. Heroku is a "production" environment, and for your security MObtvse only uses environment variables to configure the database and the admin login. 


Or in your shell (~/.bashrc or ~/.zshrc for example)

    export MOBTVSE_LOGIN=<LOGIN>
    export MOBTVSE_PASSWORD=<PASSWORD>

## MongoDB configuration
When getting things set up in development it is configured by default ( in `mongoid.yml`) to run against a db named `mobtvse_development` on `localhost`

In production you will want to set the following environment variables: 

* `MONGOID_HOST`
* `MONGOID_PORT`
* `MONGOID_USERNAME`
* `MONGOID_PASSWORD`
* `MONGOID_DATABASE`

You can set these up in your `.bashrc` file or just copy, and edit, the relevant section of `script/heroku_env.sh`

Importing from Octopress or Jekyll
==================================
MObtvse can import your posts from Octopress and Jekyll. If you've configured S3 
support it can also upload all of your images to it, and rewrite the image urls in 
your posts when appropriate. See [the migration doc](https://github.com/masukomi/mobtvse/blob/experimental/migrating.mkdn) for details. 

Support:
==========================
* Twitter: [MObtvse](http://twitter.com/#!/MObtvse)  
* File an issue on Github. 


SCREENSHOTS
===========
### Admin Screen
![](http://mobtvse.com/images/mobtvse_admin_screen_500.jpg)

### Creating and Editing a Post
![](http://mobtvse.com/images/mobtvse_editing_a_post_500.jpg)

### Viewing a Single Post

![](http://mobtvse.com/images/mobtvse_single_post_500.jpg)

Credit:
==========
MObtvse was written by Kay Rhodes. It's origin lies in Nate Wienert's excellent [Obtvse](https://github.com/NateW/obtvse). 
