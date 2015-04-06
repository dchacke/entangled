# Entangled

[![Codeship Status for dchacke/entangled](https://codeship.com/projects/9fe9a790-9df7-0132-5fb8-6e77ea26735b/status?branch=master)](https://codeship.com/projects/64679)

Real time is important. Users have come to expect real time behavior from every website, because they want to see the latest data without having to reload the page. Real time increases their engagement, provides better context for the data they're seeing, and makes collaboration easier.

Entangled stores and syncs data from ActiveRecord instantly across every device. It is a layer behind your models and controllers that pushes updates to all connected clients in real time. It is cross-browser compatible and offers real time validations.

Currently, Entangled runs on Rails 4.2 and Ruby 2.0. In the front end, libraries are available in [plain JavaScript](https://github.com/dchacke/entangled-js) and for [Angular](https://github.com/dchacke/entangled-angular).

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

```shell
         Prefix Verb URI Pattern                      Controller#Action
       messages GET  /messages(.:format)              messages#index
        message GET  /messages/:id(.:format)          messages#show
create_messages GET  /messages/create(.:format)       messages#create
 update_message GET  /messages/:id/update(.:format)   messages#update
destroy_message GET  /messages/:id/destroy(.:format)  messages#destroy
```

Note that websockets don't speak HTTP, so only GET requests are available. That's why these routes deviate slightly from restful routes. Also note that there are no `edit` and `new` actions, since an Entangled controller is only concerned with rendering data, not views.

You can use `sockets_for` just like `resources`, including the following features:

```ruby
# Inclusion/exclusion
sockets_for :messages, only: :index
sockets_for :messages, only: [:index, :show]

sockets_for :messages, except: :index
sockets_for :messages, except: [:index, :show]

# Nesting
sockets_for :parents do
  sockets_for :children
end

# Multiple routes at once
sockets_for :foos, :bars

# ...etc
```

### Models
Add the following to the top of your model (e.g., a `Message` model):

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
entangle only: :create
entangle only: [:create, :update]
```

Calling `entangled` creates the following channels (sticking with the example of a `Message` model):

```ruby
# For the collection
"/messages"

# For a member, e.g. /messages/1
"/messages/:id"
```

`:id` being the record's id, just as with routes.

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
      @message = Message.create(message_params)
    end
  end

  def update
    broadcast do
      @message = Message.find(params[:id])
      @message.update(message_params)
    end
  end

  def destroy
    broadcast do
      @message = Message.find(params[:id]).destroy
    end
  end

private
  def message_params
    # params logic here
  end
end
```

Note the following:

- All methods are wrapped in a new `broadcast` block needed to receive and send data to connected clients
- The `index` action will expect an instance variable with the same name as your controller in the plural form (e.g. `@messages` in a `MessagesController`)
- The `show`, `create`, `update`, and `destroy` actions will expect an instance variable with the singular name of your controller (e.g. `@message` in a `MessagesController`)
- The instance variables are sent to clients as stringified JSON
- Strong parameters are expected
- The path to your controllers' index action has to match the model's channel for the collection, and the path to your controller's show action has to match the model's channel for a single member (which it will automatically if you stay RESTful)

### Server

Remember to run Redis whenever you run your server:

```shell
$ redis-server
```

Redis is needed to subscribe and publish to the channels that are created by Entangled internally to communicate over websockets.

If you store your Redis instance in `$redis` or `REDIS` (e.g. in an initializer), Entangled will use that assigned instance so that you can configure Redis just like you're used to. Otherwise, Entangled will instantiate Redis itself and use its default settings.

### Associations
What if you want to only fetch and subscribe to children that belong to a specific parent? Or maybe you want to create a child in your front end and assign it to a specific parent?

Imagine the following Parent > Children relationship in your models:

```ruby
class Parent < ActiveRecord::Base
  include Entangled::Model
  entangle

  has_many :children
end

class Child < ActiveRecord::Base
  include Entangled::Model
  entangle

  belongs_to :parent
end
```

Entangled takes note of every `belongs_to` association and creates two additional channels for each `belongs_to` association in the child model:

```ruby
"/parents/:parent_id/children"
"/parents/:parent_id/children/:id"
```

So in total, the `Child` model will have all of the following channels:

```ruby
"/children"
"/children/:id"
"/parents/:parent_id/children"
"/parents/:parent_id/children/:id"
```

Channels are deeply nested for child/parent/grandparent etc associations. There is no limit. To get a list of all available channels on a record, you can call the method `channels` on any entangled instance.

To reflect associations in your front end, you just need to add three things to your app:

- Nest your routes so that they resemble the parent/child relationship:

```ruby
sockets_for :parents do
  sockets_for :children
end
```

- Adjust the `index` and `create` actions in your `ChildrenController` so that they look like this:

```ruby
class ChildrenController < ApplicationController
  include Entangled::Controller

  # Fetch children of specific parent
  def index
    broadcast do
      @children = Child.where(parent_id: params[:parent_id])
    end
  end

  # Create child of specific parent
  def create
    broadcast do
      @child = Child.new(child_params)
      @child.parent_id = params[:parent_id]
      @child.save
    end
  end

  # show, update and destroy don't need to be nested
end
```

Check out the JavaScript guides to implement associations on the client.

## The Client
Pick if you want to use Entangled with plain JavaScript or with Angular:

- [entangled-js](https://github.com/dchacke/entangled-js)
- [entangled-angular](https://github.com/dchacke/entangled-angular)

## Planning Your Infrastructure
This gem is best used for Rails apps that serve as APIs only and are not concerned with rendering views, since Entangled controllers cannot render views. A front end separate from your Rails app is recommended, either in your Rails app's public directory, or a separate front end app altogether.

## Limitations
The gem relies heavily on convention over configuration and currently only works with restful style controllers as shown above. More features will be available soon. See the list of development priorities below.

## Development Priorities
The following features are to be implemented next:

- Make prefix of create path `create_message` instead of `create_messages`
- Add something like `spec.required_ruby_version = '>= 2.0.0'` to gemspec, see http://guides.rubygems.org/specification-reference/#required_ruby_version=, and then try downloading gem
- Support `belongsTo` in front end
- Support `has_one` association in back end and front end
- Add offline capabilities
- Add authentication - with JWT?
- On Heroku, tasks are always in different order depending on which ones are checked off and not
- Add `$onChange` function to objects - or could a simple $watch and $watchCollection suffice?
- Add diagram on how it works to Readme
- Check if Rails 4.0.0 supported too
- GNU instead of MIT? Or something else? How to switch?
- Contact Jessy to tweet about it!
- Handle errors gracefully (e.g. finding a non-existent id, etc, authorization error in the back end, timeouts, etc)
- Test controllers (see https://github.com/ngauthier/tubesock/issues/41)
- Freeze destroyed object
- Set `$persisted()` to false on a destroyed object
- Add `.destroyAll()` function to `Resources`
- Add support for plain JavaScript usage (without Angular) and add section about that to Readme

## Contributing
1. [Fork it](https://github.com/dchacke/entangled/fork) - you will notice that the repo comes with a back end and a front end part to test both parts of the gem
2. Run `$ bundle install` in the root of the repo
3. Run `$ bower install` and `$ npm install` in spec/dummy/public
4. The back end example app resides in spec/dummy. You can run `rails` and `rake` commands in there if you prefix them with `bin/`, i.e. `$ bin/rails s` or `$ bin/rake db:schema:load`. Run your Rails tests in the root of the repo by running `$ rspec`
5. The front end example app resides in spec/dummy/public. To look at it in your browser, cd into spec/dummy/public and run `$ bin/rails s`. Tests for this part of the app can be located under spec/dummy/public/test and are written with Jasmine. To run the tests, first run `$ bin/rails -e test` to start up the server in test mode, and then run `$ grunt test` in a new terminal tab. It's important to remember that changes you make to the server will not take effect until you restart the server since you're running it in the test environment. Also remember to prepare the test database by running `$ bin/rake db:test:prepare`
6. The Entangled Angular service resides in spec/dummy/public/app/entangled/entangled.js. This is where you can make changes to the service. A copy of it, living in /entangled.js at the root of the repo, should be kept in sync for it to be available with Bower. Once you're done editing spec/dummy/public/app/entangled/entangled.js, copy it over to /entangled.js
7. Write your tests. Test coverage is required
8. Write your feature to make the tests pass
9. Stage and commit your changes
10. Push to a new feature branch in your repo
11. Send me a pull request!

## Credits
Thanks to [Ilias Tsangaris](https://github.com/iliastsangaris) for inspiring the name "Entanglement" based on [Quantum Entanglement](http://en.wikipedia.org/wiki/Quantum_entanglement) where pairs or groups of particles always react to changes as a whole, i.e. changes to one particle will result in immediate change of all particles in the group.
