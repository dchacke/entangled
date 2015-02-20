# Entangled
Services like Firebase are great because they provide real time data binding between client and server. But they come at a price: You give up control over your backend. Wouldn't it be great to have real time functionality but still keep your beloved Rails backend? That's where Entangled comes in.

Entangled is a layer behind your controllers and models that pushes updates to clients subscribed to certain channels in real time. For example, if you display a list of five messages on a page, if anyone adds a sixth message, everyone who is currently looking at that page will instantly see that sixth message being added to the list.

The idea is that real time data binding should be the default, not an add-on. Entangled aims at making real time features as easy to implement as possible, while at the same time making your restful controllers thinner.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'entangled'
```

Note that Redis and Puma are required as well. Redis is needed to build the channels clients subscribe to, Puma is needed to handle websockets concurrently.

```ruby
gem 'redis'
gem 'puma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install entangled

## Usage
Entangled is needed in three parts of your app. Given the example of a `MessagesController` and a `Message` model for a chat app, you will need:

### Routes
Add the following to your routes file:

```ruby
sockets_for :messages
```

Replace `messages` with your resource name.

Under the hood, this creates the following routes:

```ruby
get '/messages', to: 'messages#index', as: :messages
get '/messages/create', to: 'messages#create', as: :create_message
get '/messages/:id', to: 'messages#show', as: :message
get '/messages/:id/destroy', to: 'messages#destroy', as: :destroy_message
get '/messages/:id/update', to: 'messages#update', as: :update_message
```

Note that Websockets don't speak HTTP, so only GET requests are available. That's why these routes deviate slightly from restful routes. Also note that there are no `edit` and `new` actions, since an Entangled controller is only concerned with rendering data, not views.

### Model
Add the following to the top inside your model (e.g., a `Message` model):

```ruby
class Message < ActiveRecord::Base
  include Entangled::Model
  entangle
end
```

This will create the callbacks needed to push changes to data to all clients who are subscribed. This is essentially where the data binding is set up.

### Controller
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

## Server
Remember to run Redis whenever you run your server:

```shell
$ redis-server
```

Otherwise the channels won't work.

### Database
Depending on your app's settings, you might have to increase the pool size in your database.yml configuration file, since every new socket will open a new connection to your database.

### The Client
You will need to configure your client to create Websockets and understand incoming requests on those sockets. If you use Angular for your frontend, you can use [this library](https://github.com/so-entangled/angular). The use of Angular as counterpart of this gem is highly recommended, since its inherent two way data binding complements the real time functionality of this gem nicely.

## Planning Your Infrastructure
This gem is best used for Rails apps that serve as APIs only and are not concerned with rendering views. A frontend separate from your Rails app, such as Angular with Grunt, is recommended.

## Limitations
The gem rely's heavily on convention over configuration and currently only works with restful style controllers as shown above. More customization will be available soon.

## Contributing
1. Fork it ( https://github.com/so-entangled/rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits
Thanks to [Ilias Tsangaris](https://github.com/iliastsangaris) for inspiring the name "Entanglement" based on [Quantum Entanglement](http://en.wikipedia.org/wiki/Quantum_entanglement) where pairs or groups of particles always react to changes as a whole, i.e. changes to one particle will result in immediate change of all particles in the group.
