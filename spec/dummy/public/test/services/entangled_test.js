'use strict';

describe('Entangled', function() {
  beforeEach(module('entangled'));

  var $injector,
  Entangled,
  List,
  Item;

  beforeEach(inject(function() {
    $injector = angular.injector(['entangled']);
    Entangled = $injector.get('Entangled');

    List = new Entangled('ws://localhost:3000/lists');
    List.hasMany('items');

    Item = new Entangled('ws://localhost:3000/lists/:listId/items');
    Item.belongsTo('list');
  }));

  describe('constructor', function() {
    it('is "Entangled"', function() {
      expect(List.constructor.name).toBe('Entangled');
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
      List.all(function(err, lists) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Assert that lists are set
        expect(lists).toEqual(jasmine.any(Array));

        done();
      });
    });
  });

  describe('.create', function() {
    it('creates a list', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Assert that list was created successfully
        expect(list.id).toBeDefined();
        expect(list.createdAt).toBeDefined();

        done();
      });
    });

    it('receives validation messages', function(done) {
      // Leave out name, causing model validations
      // in ActiveRecord to fail
      List.create({}, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Assert that validation errors are attached
        expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();

        done();
      });
    });
  });

  describe('.find', function() {
    it('finds a list', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        List.find(list.id, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that list was found
          expect(list.id).toBeDefined();
          expect(list.createdAt).toBeDefined();

          done();
        });
      });
    });

    it('receives an error when looking for a list that does not exist', function(done) {
      List.find('not an id', function(err, list) {
        // Assert that error is set
        expect(err).toEqual(jasmine.any(Error));
        expect(err.message).toEqual("Couldn't find List with 'id'=not an id");

        // Assert that no second parameter was passed to callback
        expect(list).not.toBeDefined();

        done();
      })
    });
  });

  describe('#$save', function() {
    describe('new record', function() {
      it('saves a new list', function(done) {
        var list = List.new({ name: 'foo' });

        list.$save(function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that list was persisted
          expect(list.id).toBeDefined();
          expect(list.createdAt).toBeDefined();

          done();
        });
      });

      it('receives validation messages', function(done) {
        // Leave out name, causing model validations
        // in ActiveRecord to fail
        var list = List.new();

        list.$save(function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that validation errors are attached
          expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();

          done();
        });
      });
    });

    describe('existing record', function() {
      it('updates an existing list', function(done) {
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Prepare for update
          list.name = 'new name';

          // Remember old updatedAt to compare once saved
          var oldUpdatedAt = list.updatedAt;

          // Save
          list.$save(function(err, list) {
            // Assert that err is null
            expect(err).toEqual(null);

            // Assert that list was updated successfully
            expect(list.name).toBe('new name');
            expect(list.updatedAt).not.toEqual(oldUpdatedAt);

            done();
          });
        });
      });

      it('receives validation messages', function(done) {
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Make invalid by setting the name to an
          // empty string, causing model validations
          // in ActiveRecord to fail
          list.name = '';
          var oldUpdatedAt = list.updatedAt;

          list.$save(function(err, list) {
            // Assert that err is null
            expect(err).toEqual(null);

            // Assert that the list was not updated
            // by the server
            expect(list.updatedAt).toBe(oldUpdatedAt);
            expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();

            done();
          });
        });
      });

      it('receives an error when trying to save a record without being able to find it', function(done) {
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Prepare for update
          list.id = 'not an id';

          // Save
          list.$save(function(err, list) {
            // Assert that error is set
            expect(err).toEqual(jasmine.any(Error));
            expect(err.message).toEqual("Couldn't find List with 'id'=not an id");

            // Assert that no second parameter was passed to callback
            expect(list).not.toBeDefined();

            done();
          });
        });
      });
    });
  });

  describe('#$update', function() {
    it('updates a list in place', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Remember old updatedAt to compare once updated
        var oldUpdatedAt = list.updatedAt;

        // Update
        list.$update({ name: 'new name' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that list was updated successfully
          expect(list.name).toBe('new name');
          expect(list.updatedAt).not.toEqual(oldUpdatedAt);

          done();
        });
      });
    });

    it('receives validation messages', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Remember old updatedAt to compare once updated
        var oldUpdatedAt = list.updatedAt;

        // Make invalid by setting the name to an
        // empty string, causing model validations
        // in ActiveRecord to fail
        list.$update({ name: '' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that the list was not updated
          // by the server
          expect(list.updatedAt).toBe(oldUpdatedAt);
          expect(list.errors.name.indexOf("can't be blank") > -1).toBeTruthy();

          done();
        });
      });
    });

    it('receives an error when trying to save a record without being able to find it', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        // Prepare for update
        // list.id = 'not an id';

        // Save
        list.$update({ id: 'not an id' }, function(err, list) {
          // Assert that error is set
          expect(err).toEqual(jasmine.any(Error));
          expect(err.message).toEqual("Couldn't find List with 'id'=not an id");

          // Assert that no second parameter was passed to callback
          expect(list).not.toBeDefined();

          done();
        });
      });
    });
  });

  describe('#$destroy', function() {
    it('destroys a list', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        list.$destroy(function(err, list) {
          // Assert that no error happened
          expect(err).toEqual(null);

          // If successfully destroyed, it won't be
          // included in the collection of all records
          // anymore
          List.all(function(err, lists) {
            // Assert that no error happened
            expect(err).toEqual(null);

            // Assert that list not included in lists
            // anymore
            expect(lists.indexOf(list)).toBe(-1);

            done();
          });
        });
      });
    });

    it('marks the record as destroyed', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        list.$destroy(function(err, list) {
          // Assert that no error happened
          expect(err).toEqual(null);

          // Asser that list is destroyed
          expect(list.destroyed).toBeTruthy();

          done();
        });
      });
    });

    it('freezes the record', function(done) {
      List.create({ name: 'foo' }, function(err, list) {
        // Assert that err is null
        expect(err).toEqual(null);

        list.$destroy(function(err, list) {
          // Assert that no error happened
          expect(err).toEqual(null);

          // Assert that list is frozen
          expect(Object.isFrozen(list)).toBeTruthy();

          done();
        });
      });
    });

    it('has an error when an exception happens in the back end', function(done) {
      // Try to destroy list that's not in the database,
      // thereby triggering an exception in the back end,
      // which should trigger an exception in the front end
      var list = List.new({ id: 1234 });

      list.$destroy(function(err, noList) {
        // Assert that error is defined and has the right message
        expect(err).toEqual(jasmine.any(Error));
        expect(err.message).toEqual("Couldn't find List with 'id'=1234");

        // Assert that list was not frozen
        expect(Object.isFrozen(list)).not.toBeTruthy();

        // Assert that no second parameter was sent to callback
        expect(noList).not.toBeDefined();

        done();
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

    describe('destroyed record', function() {
      it('is false', function() {
        list.id = 1;
        list.destroyed = true;
        expect(list.$persisted()).not.toBeTruthy();
      });
    });
  });

  describe('#$newRecord', function() {
    var list;

    beforeEach(function() {
      list = List.new();
    });

    describe('new record', function() {
      it('is true', function() {
        expect(list.$newRecord()).toBeTruthy();
      });
    });

    describe('persisted record', function() {
      it('is false', function() {
        list.id = 1;
        expect(list.$newRecord()).not.toBeTruthy();
      });
    });
  });

  describe('#$destroyed', function() {
    var list;

    beforeEach(function() {
      list = List.new();
    });

    describe('destroyed record', function() {
      it('is true', function() {
        list.destroyed = true;
        expect(list.$destroyed()).toBeTruthy();
      });
    });

    describe('non-destroyed record', function() {
      it('is false', function() {
        expect(list.$destroyed()).not.toBeTruthy();
      });
    });
  });

  describe('#asSnakeJSON', function() {
    it('returns the resource as JSON with snake case keys', function() {
      var list = List.new();
      list.fooBar = 'bar';
      expect(JSON.parse(list.asSnakeJSON()).foo_bar).toEqual('bar');
    });
  });

  describe('Associations', function() {
    describe('List', function() {
      it('has many items', function(done) {
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Assert that relationship defined
          expect(list.items).toBeDefined();

          // Assert that relationship is also
          // an instance of Entangled, meaning
          // in turn that all class and instance
          // methods are available on it
          expect(list.items().constructor.name).toBe('Entangled');

          done();
        });
      });
    });

    describe('Item', function() {
      it('belongs to a list', function(done) {
        // Create parent list
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Create child item
          Item.create({ name: 'foo', listId: list.id }, function(err, item) {
            // Assert that err is null
            expect(err).toEqual(null);

            // Assert that creation successful
            expect(item.$persisted()).toBeTruthy();

            // Assert parent relationship
            // expect(item.list).toBe(list);
            var originalList = list;

            item.list(function(err, list) {
              // Assert that err is null
              expect(err).toEqual(null);

              // Assert that the original list and the parent
              // are the same
              expect(originalList.id).toBe(list.id);

              done();
            });
          });
        });
      });

      it('receives an error when trying to find a parent that does not exist', function(done) {
        // Create parent list
        List.create({ name: 'foo' }, function(err, list) {
          // Assert that err is null
          expect(err).toEqual(null);

          // Create child item
          Item.create({ name: 'foo', listId: list.id }, function(err, item) {
            // Assert that err is null
            expect(err).toEqual(null);

            // Assert that creation successful
            expect(item.$persisted()).toBeTruthy();

            // Change parent id to a non-existent id
            item.listId = 'not an id';

            item.list(function(err, list) {
              // Assert that err is set
              expect(err).toEqual(jasmine.any(Error));
              expect(err.message).toEqual("Couldn't find List with 'id'=not an id");

              // Assert that no second parameter was passed
              // to the callback
              expect(list).not.toBeDefined();

              done();
            });
          });
        });
      });
    });
  });
});
