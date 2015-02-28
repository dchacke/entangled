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
});
