// Register Angular module and call it 'entangled'
angular.module('entangled', [])

// Register service and call it 'Entangled'
.factory('Entangled', function() {
  // Every response coming from the server will be wrapped
  // in a Resource constructor to represent a CRUD-able
  // resource that can be saved and destroyed using the
  // methods $save(), $destroy, and others. A Resource also
  // stores the socket's URL it was retrieved from so it
  // can be reused for other requests.
  var Resource = function(params, webSocketUrl, hasMany) {
    // Assign proerties
    for (var key in params) {
      // Skip inherent object properties
      if (params.hasOwnProperty(key)) {
        this[key] = params[key];
      }
    }

    // Assign socket URL
    this.webSocketUrl = webSocketUrl;

    // Assign has many relationship
    if (hasMany) {
      this[hasMany] = function() {
        return new Entangled(this.webSocketUrl + '/' + this.id + '/' + hasMany);
      };
    }
  };

  // $save() will send a request to the server
  // to either create a new record or update
  // an existing, depending on whether or not
  // an id is present.
  Resource.prototype.$save = function(callback) {
    if (this.id) {
      // Update
      var socket = new WebSocket(this.webSocketUrl + '/' + this.id + '/update');
      socket.onopen = function() {
        socket.send(JSON.stringify(this));
      }.bind(this);

      // Receive updated resource from server
      socket.onmessage = function(event) {
        if (event.data) {
          var data = JSON.parse(event.data);

          // Assign/override new data (such as updated_at, etc)
          if (data.resource) {
            for (key in data.resource) {
              this[key] = data.resource[key];
            }
          }
        }

        // Assign has many association. The association
        // can only be available to a persisted record
        this[this.hasMany] = new Entangled(this.webSocketUrl + '/' + this.id + '/' + this.hasMany);

        // Pass 'this' to callback for create
        // function so this the create function
        // can pass the created resource to its
        // own callback; not needed for $save per se
        if (callback) callback(this);
      }.bind(this);
    } else {
      // Create
      var socket = new WebSocket(this.webSocketUrl + '/create');

      // Send attributes to server
      socket.onopen = function() {
        socket.send(JSON.stringify(this));
      }.bind(this);

      // Receive saved resource from server
      socket.onmessage = function(event) {
        if (event.data) {
          var data = JSON.parse(event.data);

          // Assign/override new data (such as id, created_at,
          // updated_at, etc)
          if (data.resource) {
            for (key in data.resource) {
              this[key] = data.resource[key];
            }
          }
        }

        // Pass 'this' to callback for create
        // function so this the create function
        // can pass the created resource to its
        // own callback; not needed for $save per se
        if (callback) callback(this);
      }.bind(this);
    }
  };

  // $update() updates a record in place
  Resource.prototype.$update = function(params, callback) {
    // Update object in memory
    for (var key in params) {
      // Skip inherent object properties
      if (params.hasOwnProperty(key)) {
        this[key] = params[key];
      }
    }

    // Save object
    this.$save(callback);
  };

  // $destroy() will send a request to the server to
  // destroy an existing record.
  Resource.prototype.$destroy = function(callback) {
    var socket = new WebSocket(this.webSocketUrl + '/' + this.id + '/destroy');

    socket.onopen = function() {
      // It's fine to send an empty message since the
      // socket's URL contains all the information
      // needed to destroy the record (the id).
      socket.send(null);
    };

    socket.onmessage = function(event) {
      if (event.data) {
        var data = JSON.parse(event.data);

        // Assign/override new data
        if (data.resource) {
          for (key in data.resource) {
            this[key] = data.resource[key];
          }
        }
      }

      if (callback) callback(this);
    }.bind(this);
  };

  // $valid() checks if any errors are attached to the object
  // and return false if so, false otherwise. This doesn't actually
  // invoke server side validations, so it should only be used
  // after calling $save() to check if the record was successfully
  // stored in the database
  Resource.prototype.$valid = function() {
    return !(this.errors && Object.keys(this.errors).length);
  };

  // $invalid() returns the opposite of $valid()
  Resource.prototype.$invalid = function() {
    return !this.$valid();
  };

  // $persisted() checks if the record was successfully stored
  // in the back end's database
  Resource.prototype.$persisted = function() {
    return !!this.id;
  };

  // Resources wraps all individual Resource objects
  // in a collection.
  var Resources = function(resources, webSocketUrl, hasMany) {
    this.all = [];

    for (var i = 0; i < resources.length; i++) {
      var resource = new Resource(resources[i], webSocketUrl, hasMany);
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
    this.className = 'Entangled';

    // Store the root URL that sockets
    // will connect to
    this.webSocketUrl = webSocketUrl;
  };

  // hasMany() adds the appropriate association and
  // sets up websockets accordingly
  Entangled.prototype.hasMany = function(resources) {
    this.hasMany = resources;
  };

  // Function to instantiate a new Resource, optionally
  // with given parameters
  Entangled.prototype.new = function(params) {
    return new Resource(params, this.webSocketUrl, this.hasMany);
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
          // Store retrieved Resources in property
          this.resources = new Resources(data.resources, socket.url, this.hasMany);
        } else if (data.action) {
          if (data.action === 'create') {
            // If new Resource was created, add it to the
            // collection
            this.resources.all.push(new Resource(data.resource, socket.url, this.hasMany));
          } else if (data.action === 'update') {
            // If an existing Resource was updated,
            // update it in the collection as well
            var index;

            for (var i = 0; i < this.resources.all.length; i++) {
              if (this.resources.all[i].id === data.resource.id) {
                index = i;
              }
            }

            this.resources.all[index] = new Resource(data.resource, socket.url, this.hasMany);
          } else if (data.action === 'destroy') {
            // If a Resource was destroyed, remove it
            // from Resources as well
            var index;

            for (var i = 0; i < this.resources.all.length; i++) {
              if (this.resources.all[i].id === data.resource.id) {
                index = i;
              }
            }

            this.resources.all.splice(index, 1);
          } else {
            console.log('Something else other than CRUD happened...');
            console.log(data);
          }
        }
      }

      // Run the callback and pass in the
      // resulting collection
      callback(this.resources.all);
    }.bind(this);
  };

  // Instantiate and persist a record in one go
  Entangled.prototype.create = function(params, callback) {
    var resource = this.new(params);
    resource.$save(callback);
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

        if (data.resource && !data.action) {
          // If the Resource was sent from the server,
          // store it
          this.resource = new Resource(data.resource, webSocketUrl, this.hasMany);
        } else if (data.action) {
          if (data.action === 'update') {
            // If the stored Resource was updated,
            // update it here as well
            this.resource = new Resource(data.resource, webSocketUrl, this.hasMany);
          } else if (data.action === 'destroy') {
            // If the stored Resource was destroyed,
            // remove it from here as well
            this.resource = undefined;
          }
        } else {
          console.log('Something else other than CRUD happened...');
          console.log(data);
        }
      }

      // Run callback with retrieved Resource
      callback(this.resource);
    }.bind(this);
  };

  return Entangled;
});
