'use strict';

describe('Entangled', function() {
  beforeEach(module('entangled'));

  var $injector,
  Entangled,
  List;

  beforeEach(inject(function() {
    $injector = angular.injector(['entangled']);
    Entangled = $injector.get('Entangled');

    List = new Entangled('ws://localhost:3000/lists');
    List.hasMany('items');
  }));

  describe('.className', function() {
    it('is "Entangled"', function() {
      expect(List.className).toBe('Entangled');
    });
  });

  describe('.new', function() {
    it('instantiates a new list with given values', function() {
      var list = List.new({ name: 'foo' });
      expect(list).toBeDefined();
      expect(list.name).toBe('foo');
    });
  });

  describe('.all', function() {
    it('fetches all lists', function(done) {
      List.all(function(lists) {
        expect(lists).toEqual(jasmine.any(Array));
        done();
      });
    });
  });

  describe('.create', function() {
    it('creates a list', function(done) {
      List.create({ name: 'foo' }, function(list) {
        expect(list.id).toBeDefined();
        expect(list.created_at).toBeDefined();
        done();
      });
    });

    it('receives validation messages', function(done) {
      // Leave out name, causing model validations
      // in ActiveRecord to fail
      List.create({}, function(list) {
        expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();
        done();
      });
    });
  });

  describe('.find', function() {
    it('finds a list', function(done) {
      List.create({ name: 'foo' }, function(list) {
        List.find(list.id, function(list) {
          expect(list.id).toBeDefined();
          expect(list.created_at).toBeDefined();
          done();
        });
      });
    });
  });

  describe('#$save', function() {
    describe('new record', function() {
      it('saves a new list', function(done) {
        var list = List.new({ name: 'foo' });

        list.$save(function() {
          expect(list.id).toBeDefined();
          expect(list.created_at).toBeDefined();
          done();
        });
      });

      it('receives validation messages', function(done) {
        // Leave out name, causing model validations
        // in ActiveRecord to fail
        var list = List.new();

        list.$save(function() {
          expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();
          done();
        });
      });
    });

    describe('existing record', function() {
      it('updates an existing list', function(done) {
        List.create({ name: 'foo' }, function(list) {
          list.name = 'new name';
          var oldUpdatedAt = list.updated_at;

          list.$save(function() {
            expect(list.name).toBe('new name');
            expect(list.updated_at).not.toEqual(oldUpdatedAt);
            done();
          });
        });
      });

      it('receives validation messages', function(done) {
        List.create({ name: 'foo' }, function(list) {
          // Make invalid by setting the name to an
          // empty string, causing model validations
          // in ActiveRecord to fail
          list.name = '';
          var oldUpdatedAt = list.updated_at;

          list.$save(function() {
            // Assert that the list was not updated
            // by the server
            expect(list.updated_at).toBe(oldUpdatedAt);
            expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();
            done();
          });
        });
      });
    });
  });

  describe('#$update', function() {
    it('updates a list in place', function(done) {
      List.create({ name: 'foo' }, function(list) {
        var oldUpdatedAt = list.updated_at;

        list.$update({ name: 'new name' }, function() {
          expect(list.name).toBe('new name');
          expect(list.updated_at).not.toEqual(oldUpdatedAt);
          done();
        });
      });
    });

    it('receives validation messages', function(done) {
      List.create({ name: 'foo' }, function(list) {
        var oldUpdatedAt = list.updated_at;

        // Make invalid by setting the name to an
        // empty string, causing model validations
        // in ActiveRecord to fail
        list.$update({ name: '' }, function() {
          // Assert that the list was not updated
          // by the server
          expect(list.updated_at).toBe(oldUpdatedAt);
          expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();
          done();
        });
      });
    });
  });

  describe('#$destroy', function() {
    it('destroys a list', function(done) {
      List.create({ name: 'foo' }, function(list) {
        list.$destroy(function() {
          // If successfully destroyed, it won't be
          // included in the collection of all records
          // anymore
          List.all(function(lists) {
            expect(lists.indexOf(list)).toBe(-1);
            done();
          });
        });
      });
    });
  });

  describe('#$valid', function() {
    var list;

    beforeEach(function() {
      list = List.new();
    });

    describe('valid record', function() {
      it('is true', function() {
        list.errors = {};
        expect(list.$valid()).toBeTruthy();
      });
    });

    describe('invalid record', function() {
      it('is false', function() {
        list.errors = {
          name: ["can't be blank"]
        };

        expect(list.$valid()).not.toBeTruthy();
      });
    });
  });

  describe('#$invalid', function() {
    var list;

    beforeEach(function() {
      list = List.new();
    });

    describe('valid record', function() {
      it('is false', function() {
        list.errors = {};
        expect(list.$invalid()).not.toBeTruthy();
      });
    });

    describe('invalid record', function() {
      it('is true', function() {
        list.errors = {
          name: ["can't be blank"]
        };

        expect(list.$invalid()).toBeTruthy();
      });
    });
  });

  describe('#$persisted', function() {
    var list;

    beforeEach(function() {
      list = List.new();
    });

    describe('persisted record', function() {
      it('is true', function() {
        list.id = 1;
        expect(list.$persisted()).toBeTruthy();
      });
    });

    describe('unpersisted record', function() {
      it('is false', function() {
        expect(list.$persisted()).not.toBeTruthy();
      });
    });
  });

  describe('Associations', function() {
    it('has many items', function(done) {
      List.create({ name: 'foo' }, function(list) {
        // Assert that relationship defined
        expect(list.items).toBeDefined();

        // Assert that relationship is also
        // an instance of Entangled, meaning
        // in turn that all class and instance
        // methods are available on it
        expect(list.items().className).toBe('Entangled');
        done();
      });
    });
  });
});
