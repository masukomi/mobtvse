MObtvse
================
A clean and simple markdown blog.  Inspired by [Svbtle](http://svbtle.com) and bootstrapped by [Obtvse](https://github.com/NateW/obtvse). 

## Notable differences from Obvtse
### Current

* MObvtse uses [MongoDB](www.mongodb.org) via [MongoID](mongoid.org)
* Taggable posts ( users can view all posts with the same tag and admin can limit view to just posts with a specific tag )
* [Disqus](http://disqus.com) integration for great comment functionality.
* [Haml](http://haml-lang.com/) (partially implemented)
* Svbtle-style Kudos

### Planned
The goal is to add support for:

* Generation of static html files for fast serving, or tools for making that easily implementable.
* [Mixpanel](http://mixpanel.com/)
* Static File generation
* Image Uploads
* Great features that HTML based blogging platforms like Wordpress have had for years.

See [the major ToDo items here](https://github.com/masukomi/mobtvse/blob/master/ToDo.mkdn).

Because of the significance of these infrastructural changes and a number of planned UI changes that are beyond the scope of what Nate wants to do with Obtvse, MObvtuse has been created as an entirely separate project. With that said, MObtvse plans to continue pulling in updates from Obtvse whenever possible, and sharing changes back whenever appropriate. 

## The New Hotness
Want the *latest* tweaks, the *bleeding edge* functionality? Check out the "experimental" branch. New changes are pushed to experimental where they are allowed to percolate for a little while to increase stability, and catch any wayward bugs before they're pushed to the "master" branch. This also helps to minimize the churn in the master codebase. 

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
    cd obtvse
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
