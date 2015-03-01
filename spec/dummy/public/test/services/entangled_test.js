describe('Entangled', function() {
  // Prepare variable for service
  var Entangled;

  // Prepare websocket url
  var webSocketUrl = 'ws://localhost:3000/messages';

  // Load module that contains the service
  beforeEach(module('entangled'));

  // Inject the service
  beforeEach(inject(function($injector) {
    Entangled = $injector.get('Entangled');
  }));

  describe('Functions', function() {
    describe('constructor', function() {
      it('assigns a websocket url', function() {
        var entangled = new Entangled(webSocketUrl);
        expect(entangled.webSocketUrl).toBe(webSocketUrl);
      });
    });

    describe('#new', function() {
      it('assigns the entangled websocket', function() {
        var entangled = new Entangled(webSocketUrl);
        var instance = entangled.new();
        expect(instance.webSocketUrl).toBe(webSocketUrl);
      });

      it('assigns optional parameters when given', function() {
        var entangled = new Entangled(webSocketUrl);
        var instance = entangled.new({ foo: 'bar', bar: 'foo' });
        expect(instance.foo).toBe('bar');
        expect(instance.bar).toBe('foo');
      });
    });

    describe('#$save', function() {
      it('is a function', function() {
        var entangled = new Entangled(webSocketUrl);
        var instance = entangled.new();
        expect(instance.$save).toBeDefined();
      });
    });

    describe('#$destroy', function() {
      it('is a function', function() {
        var entangled = new Entangled(webSocketUrl);
        var instance = entangled.new();
        expect(instance.$destroy).toBeDefined();
      });
    });

    describe('#find', function() {
      it('is a function', function() {
        var entangled = new Entangled(webSocketUrl);
        expect(entangled.find).toBeDefined();
      });
    });

    describe('#all', function() {
      it('is a function', function() {
        var entangled = new Entangled(webSocketUrl);
        expect(entangled.all).toBeDefined();
      });
    });
  });

  describe('create', function() {
    it('creates a resource', function(done) {
      var entangled = new Entangled(webSocketUrl);
      var resource = entangled.new({ body: 'test body' });

      resource.$save(function() {
        setTimeout(function() {
          entangled.all(function(resources) {
            // For some reason, this callback
            // is run more than once. It seems
            // that the second time it runs is
            // after the destruction of the
            // resource in another test. Therefore,
            // it should only be run if the resource
            // still exists, i.e. resources[0] is defined.
            // The test runs at least once because
            // done() is called within, otherwise
            // a corresponding error message would
            // show up
            if(resources[0]) {
              expect(resources.length).toBe(1);
              done();
            }
          });
        }, 100);
      });
    });
  });

  describe('destroy', function() {
    it('destroys a resource', function(done) {
      var entangled = new Entangled(webSocketUrl);
      var resource = entangled.new({ body: 'test body' });

      // Prepare resource to be destroyed
      resource.$save(function() {
        setTimeout(function() {
          // Fetch resource back again
          entangled.all(function(resources) {
            // For some reason, this callback
            // seems to be run more than once.
            // The second time it runs, the
            // resource will already be deleted,
            // so resources[0] will evaluate to undefined.
            // Therefore, this test should only
            // be run if resources[0] is defined, i.e.
            // the first time the test runs.
            // The test runs at least once because
            // done() is called within, otherwise
            // a corresponding error message would
            // show up
            if (resources[0]) {
              // Destroy resource
              resources[0].$destroy(function() {
                setTimeout(function() {
                  // Assert that resource is gone
                  entangled.all(function(resources) {
                    expect(resources.length).toBe(0);
                    done();
                  });
                }, 100);
              });
            }
          });
        }, 100);
      });
    });
  });

  it('updates a resource');
  // describe('update', function() {
  //   it('updates a resource', function(done) {
  //     var entangled = new Entangled(webSocketUrl);
  //     var resource = entangled.new({ body: 'test body' });

  //     // Save resource
  //     resource.$save(function() {
  //       setTimeout(function() {
  //         // Fetch it again
  //         entangled.all(function(resources) {
  //           if (resources[0]) {
  //             resource = resources[0];

  //             // Update it
  //             resource.body = 'new body';
  //             resource.$save(function() {
  //               setTimeout(function() {
  //                 // Fetch it again
  //                 entangled.all(function(resources) {
  //                   if (resources[0]) {
  //                     resource = resources[0];
  //                     expect(resource.body).toBe('new body');
  //                     done();
  //                   }
  //                 });
  //               }, 100);
  //             });
  //           }
  //         });
  //       }, 100);
  //     });
  //   });
  // });

  it('cannot find() after destroy');
});
