// Register Angular module and call it 'entangled'
angular.module('entangled', [])

// Register service and call it 'Entangled'
.factory('Entangled', function() {
  // Every response coming from the server will be wrapped
  // in a Resource constructor to represent a CRUD-able
  // resource that can be saved and destroyed using the
  // methods $save() and $destroy. A Resource also
  // stores the socket's URL it was retrieved from so it
  // can be reused for other requests.
  var Resource = function(params, webSocketUrl) {
    // Assign proerties
    for (var key in params) {
      // Skip inherent object properties
      if (params.hasOwnProperty(key)) {
        this[key] = params[key];
      }
    }

    this.webSocketUrl = webSocketUrl;
  };

  // $save() will send a request to the server
  // to either create a new record or update
  // an existing, depending on whether or not
  // an id is present.
  Resource.prototype.$save = function(callback) {
    console.log('Saving...');

    var that = this;
    console.log(that);

    if (this.id) {
      // Update
      console.log('Updating...');
      var socket = new WebSocket(that.webSocketUrl + '/' + that.id + '/update');
      socket.onopen = function() {
        socket.send(JSON.stringify(that));

        if (callback) callback();

        console.log('Updated');
      };
    } else {
      // Create
      console.log('Creating...');
      var socket = new WebSocket(that.webSocketUrl + '/create');
      console.log(socket);
      socket.onopen = function() {
        socket.send(JSON.stringify(that));

        if (callback) callback();

        console.log('Created');
      };
    }
  };

  // $destroy() will send a request to the server to
  // destroy an existing record.
  Resource.prototype.$destroy = function(callback) {
    console.log('From $destroy: ', this);

    var socket = new WebSocket(this.webSocketUrl + '/' + this.id + '/destroy');
    socket.onopen = function() {
      // It's fine to send an empty message since the
      // socket's URL contains all the information
      // needed to destroy the record (the id).
      socket.send(null);

      if (callback) callback();
    };
  };

  // Resources wraps all individual Resource objects
  // in a collection.
  var Resources = function(resources, webSocketUrl) {
    this.all = [];

    for (var i = 0; i < resources.length; i++) {
      var resource = new Resource(resources[i], webSocketUrl);
      this.all.push(resource);
    }
  };

  // Entangled is the heart of this service. It contains
  // several methods to instantiate a new Resource,
  // retrieve an existing Resource from the server,
  // and retrieve a collection of existing Resources
  // from the server.
  // 
  // Entangled is a constructor that takes the URL
  // of the index action on the server where the
  // Resources can be retrieved.
  var Entangled = function(webSocketUrl) {
    // Store the root URL that sockets
    // will connect to
    this.webSocketUrl = webSocketUrl;
  };

  // Function to instantiate a new Resource, optionally
  // with given parameters
  Entangled.prototype.new = function(params) {
    return new Resource(params, this.webSocketUrl);
  };

  // Retrieve all Resources from the root of the socket's
  // URL
  Entangled.prototype.all = function(callback) {
    var socket = new WebSocket(this.webSocketUrl);

    socket.onmessage = function(event) {
      // If the message from the server isn't empty
      if (event.data.length) {
        // Convert message to JSON
        var data = JSON.parse(event.data);

        // If the collection of Resources was sent
        if (data.resources) {
          console.log('Index');

          // Store retrieved Resources in property
          this.resources = new Resources(data.resources, socket.url);
        } else if (data.action) {
          if (data.action === 'create') {
            // If new Resource was created, add it to the
            // collection
            console.log('Created');
            console.log(this.resources);

            this.resources.all.push(new Resource(data.resource, socket.url));
          } else if (data.action === 'update') {
            // If an existing Resource was updated,
            // update it in the collection as well
            console.log('Updated');
            var index;

            for (var i = 0; i < this.resources.all.length; i++) {
              if (this.resources.all[i].id === data.resource.id) {
                index = i;
              }
            }

            this.resources.all[index] = new Resource(data.resource, socket.url);
          } else if (data.action === 'destroy') {
            // If a Resource was destroyed, remove it
            // from Resources as well
            console.log('Destroyed');
            var index;

            for (var i = 0; i < this.resources.all.length; i++) {
              if (this.resources.all[i].id === data.resource.id) {
                index = i;
              }
            }

            this.resources.all.splice(index, 1);
          } else {
            console.log('Something else happened...');
            console.log(data);
          }
        }
      }

      // Run the callback and pass in the
      // resulting collection
      callback(this.resources.all);
    };
  };

  // Find an individual Resource on the server
  Entangled.prototype.find = function(id, callback) {
    var webSocketUrl = this.webSocketUrl;
    var socket = new WebSocket(webSocketUrl + '/' + id);

    socket.onmessage = function(event) {
      // If the message from the server isn't empty
      if (event.data.length) {
        // Parse message and convert to JSON
        var data = JSON.parse(event.data);
        console.log('Show');

        if (data.resource && !data.action) {
          // If the Resource was sent from the server,
          // store it
          this.resource = new Resource(data.resource, webSocketUrl);
        } else if (data.action) {
          if (data.action === 'update') {
            // If the stored Resource was updated,
            // update it here as well
            console.log('updated!');

            this.resource = new Resource(data.resource, webSocketUrl);
          } else if (data.action === 'destroy') {
            // If the stored Resource was destroyed,
            // remove it from here as well
            console.log('destroyed!');

            this.resource = undefined;
          }
        } else {
          console.log('something else happened...');
          console.log(data);
        }
      }

      // Run callback with retrieved Resource
      callback(this.resource);
    };
  };

  return Entangled;
});
