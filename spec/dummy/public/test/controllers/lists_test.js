'use strict';

describe('ListsCtrl', function() {
  beforeEach(module('entangledTest'));

  var ListsCtrl,
    scope,
    List;

  beforeEach(inject(function ($controller, $rootScope, $injector) {
    scope = $rootScope.$new();
    ListsCtrl = $controller('ListsCtrl', {
      $scope: scope
    }),
    List = $injector.get('List');
  }));

  it('fetches all lists', function(done) {
    List.all(function(lists) {
      expect(lists).toEqual(jasmine.any(Array));
      done();
    });
  });

  it("fetches a list's items after creating it", function(done) {
    List.create({ name: 'foo' }, function(list) {
      // Assert that list has been persisted
      expect(list.$persisted()).toBeTruthy();

      // Fetch list's items
      list.items().all(function(items) {
        expect(items).toEqual(jasmine.any(Array));
        done();
      });
    });
  });

  it("fetches a list's items after fetching it", function(done) {
    List.create({ name: 'foo' }, function(list) {
      // Fetch list
      List.find(list.id, function(list) {
        // Assert that list is persisted
        expect(list.$persisted).toBeTruthy();

        // Fetch list's items
        list.items().all(function(items) {
          expect(items).toEqual(jasmine.any(Array));
          done();
        });
      });
    });
  });

  it("fetches a list's items when fetching all lists", function(done) {
    List.all(function(lists) {
      var list = lists[0];

      // Assert that list is persisted
      expect(list.$persisted()).toBeTruthy();

      // Fetch list's items
      list.items().all(function(items) {
        expect(items).toEqual(jasmine.any(Array));
        done();
      });
    });
  });

  it("creates and finds a list's item", function(done) {
    List.create({ name: 'foo' }, function(list) {
      // Create item
      list.items().create({ name: 'foo' }, function(item) {
        // Assert that item has been persisted
        expect(item.$persisted()).toBeTruthy();

        // Assert that item's list_id is equal to the list's id
        expect(item.list_id).toBe(list.id);

        // Assert that it can find the item
        list.items().find(item.id, function(item) {
          expect(item.$persisted()).toBeTruthy();
          done();
        });
      });
    });
  });
});
