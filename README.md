# Entangled

[![Codeship Status for dchacke/entangled](https://codeship.com/projects/9fe9a790-9df7-0132-5fb8-6e77ea26735b/status?branch=master)](https://codeship.com/projects/64679)

Services like Firebase are great because they provide real time data binding between client and server. But they come at a price: You give up control over your backend. Wouldn't it be great to have real time functionality but still keep your beloved Rails backend? That's where Entangled comes in.

Entangled is a layer behind your controllers and models that pushes updates to clients subscribed to certain channels in real time. For example, if you display a list of five messages on a page, if anyone adds a sixth message, everyone who is currently looking at that page will instantly see that sixth message being added to the list.

The idea is that real time data binding should be the default, not an add-on. Entangled aims at making real time features as easy to implement as possible, while at the same time making your restful controllers thinner.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'entangled'
```

Note that Redis and Puma are required as well. Redis is needed to build the channels clients subscribe to, Puma is needed to handle websockets concurrently.

Entangled comes with Redis, but you need to add Puma to your Gemfile:

```ruby
gem 'puma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install entangled

## Usage
Entangled is needed in three parts of your app: Routes, models, and controllers. Given the example of a `MessagesController` and a `Message` model for a chat app, you will need:

### Routes
Add the following to your routes file:

```ruby
sockets_for :messages
```

Under the hood, this creates the following routes:

```ruby
get '/messages', to: 'messages#index', as: :messages
get '/messages/create', to: 'messages#create', as: :create_message
get '/messages/:id', to: 'messages#show', as: :message
get '/messages/:id/destroy', to: 'messages#destroy', as: :destroy_message
get '/messages/:id/update', to: 'messages#update', as: :update_message
```

The options `:only` and `:except` are available just like when using `resources`, so you can say something like:

```ruby
sockets_for :messages, only: :index # or use an array
```

Note that Websockets don't speak HTTP, so only GET requests are available. That's why these routes deviate slightly from restful routes. Also note that there are no `edit` and `new` actions, since an Entangled controller is only concerned with rendering data, not views.

### Models
Add the following to the top inside your model (e.g., a `Message` model):

```ruby
class Message < ActiveRecord::Base
  include Entangled::Model
  entangle
end
```

This will create the callbacks needed to push changes to data to all clients who are subscribed. This is essentially where the data binding is set up.

By default, the following callbacks will be added:

- `after_create`
- `after_update`
- `after_destroy`

You can limit this behavior by specifying `:only` or `:except` options. For example, if you don't want to propagate the destruction or update of an object to all connected clients, you can do the following:

```ruby
entangle only: :create # or use an array
```

### Controllers
Your controllers will be a little more lightweight than in a standard restful Rails app. A restful-style controller is expected and should look like this:

```ruby
class MessagesController < ApplicationController
  include Entangled::Controller

  def index
    broadcast do
      @messages = Message.all
    end
  end

  def show
    broadcast do
      @message = Message.find(params[:id])
    end
  end

  def create
    broadcast do
      Message.create(message_params)
    end
  end

  def update
    broadcast do
      Message.find(params[:id]).update(message_params)
    end
  end

  def destroy
    broadcast do
      Message.find(params[:id]).destroy
    end
  end

private
  def message_params
    # params logic here
  end
end
```

Note the following:

- All methods are wrapped in a new `broadcast` block needed to send messages to connected clients
- The `index` method will expect an instance variable with the same name as your controller in the plural form (e.g. `@messages` in a `MessagesController`)
- The `show` method will expect an instance variable with the singular name of your controller (e.g. `@message` in a `MessagesController`)
- Instance variables only need to be assigned in `index` and `show` since these are the only methods that should be concerned with sending data to clients. All other methods only publish updates to the data clients are subscribed to through the callbacks added to the model, so no instance variables are needed
- Data sent to clients arrives as stringified JSON
- Strong parameters are expected

### Server

Remember to run Redis whenever you run your server:

```shell
$ redis-server
```

Otherwise the channels won't work.

If you store your Redis instance in `$redis` or `REDIS` (e.g. in an initializer), Entangled will use that assigned instance so that you can configure Redis just like you're used to. Otherwise, Entangled will instantiate Redis itself and use its standard settings.

### Database
Depending on your app's settings, you might have to increase the pool size in your database.yml configuration file, since every new socket will open a new connection to your database.

## The Client
You will need to configure your client to create Websockets and understand incoming requests on those sockets. If you use Angular for your frontend, you can use the Angular library from this repository. The use of Angular as counterpart of this gem is highly recommended, since its inherent two way data binding complements the real time functionality of this gem nicely.

### Installation
You can either download or reference the file `entangled.js` from this repository, or simply install it with Bower:

```shell
$ bower install entangled
```

Then include it in your HTML.

Lastly, add the Entangled module as a dependency to your Angular app:

```javascript
angular.module('appName', ['entangled']);
```

### Usage
Entangled is best used within Angular services. For example, consider a `Message` service for a chat app:

```javascript
app.factory('Message', function(Entangled) {
  var entangled = new Entangled('ws://localhost:3000/messages');

  var Message = {
    new: function(params) {
      return entangled.new(params);
    },
    all: function(callback) {
      return entangled.all(callback);
    },
    find: function(id, callback) {
      return entangled.find(id, callback);
    }
  };

  return Message;
});
```

In the above example, first we inject Entangled into our service, then instantiate a new Entangled object. The Entangled object takes one argument when instantiated: the URL of your resource's index route (in this case, `/messages`). Then we add helper methods to our service. Note that the socket URL looks just like a standard restful URL with http, except that the protocol part has been switched with `ws` to use the websocket protocol. Also note that you need to use `wss` instead if you want to use SSL.

In your controller, you could then inject that `Message` service and use it like so:

```javascript
// To instantiate a blank message, e.g. for a form;
// You can optionally pass in an object to new() to
// set some default values
$scope.message = Message.new();

// To retrieve a specific message from the server
// with id 1 and subscribe to its channel
Message.find(1, function() {
  $scope.$apply(function() {
    $scope.message = message;
  });
});

// To create a new or update an existing message
$scope.message.$save();

// To destroy a message
$scope.message.$destroy();

// To retrieve all messages from the server and
// subscribe to the collection's channel
Message.all(function(messages) {
  $scope.$apply(function() {
    $scope.messages = messages;
  });
});
```

`$save()`, `$destroy()`, `find()` and `all()` will interact with your server's controllers in real time.

If data in your server's database changes, so will your scope variables - in real time, for all connected clients.

## Planning Your Infrastructure
This gem is best used for Rails apps that serve as APIs only and are not concerned with rendering views. A frontend separate from your Rails app, such as Angular with Grunt, is recommended.

## Limitations
The gem rely's heavily on convention over configuration and currently only works with restful style controllers as shown above. More customization will be available soon.

## Contributing
1. [Fork it](https://github.com/dchacke/entangled/fork) - you will notice that the repo comes with a back end and a front end part to test both parts of the gem
2. Run `$ bundle install` in the root of the repo
3. Run `$ bower install` and `$ npm install` in spec/dummy/public
4. The back end example app resides in spec/dummy; you can run `rails` and `rake` commands in there if you prefix them with `bin/`, i.e. `$ bin/rails s` or `$ bin/rake db:schema:load`; run your tests in the root of the repo by running `$ rspec`
5. The front end example app resides in spec/dummy/public. To look at it in your browser, cd into spec/dummy/public and run `$ bin/rails s`. Tests for this part of the app can be located under spec/dummy/public/test and are written with Jasmine. To run the tests, first run `$ bin/rails -e test` to start up the server in test mode, and then run `$ grunt test` in a new terminal tab. It's important to remember that changes you make to the server will not take effect until you restart the server since you're running it in the test environment!
6. Write your tests
7. Write your feature to make the tests pass
8. Stage and commit your changes
9. Push to a new feature branch in your repo
10. Send me a pull request!

## Credits
Thanks to [Ilias Tsangaris](https://github.com/iliastsangaris) for inspiring the name "Entanglement" based on [Quantum Entanglement](http://en.wikipedia.org/wiki/Quantum_entanglement) where pairs or groups of particles always react to changes as a whole, i.e. changes to one particle will result in immediate change of all particles in the group.
