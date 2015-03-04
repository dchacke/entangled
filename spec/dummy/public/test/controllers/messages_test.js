'use strict';

// Consider making heavy use of mocks instead;
// the tests currently run asynchronously and
// heavily influence each other, making them
// hard to maintain. As suggested on this page
// (https://docs.angularjs.org/guide/unit-testing),
// it seems that using mocks enables you to extend
// other modules so they are synchronous. Not
// sure if that would isolate the tests, but
// something is definitely needed to isolate them

describe('MessagesCtrl', function () {
  beforeEach(module('entangledTest'));

  var MessagesCtrl,
    scope,
    Message;

  beforeEach(inject(function ($controller, $rootScope, $injector) {
    scope = $rootScope.$new();
    MessagesCtrl = $controller('MessagesCtrl', {
      $scope: scope
    }),
    Message = $injector.get('Message');
  }));

  it('assigns a blank message', function() {
    expect(scope.message).toBeDefined();
  });

  it('assigns all messages', function(done) {
    Message.all(function(messages) {
      expect(messages).toEqual(jasmine.any(Array));
      done();
    });
  });

  it('can find a message', function(done) {
    setTimeout(function() {
      Message.find(scope.messages[0].id, function(message) {
        expect(message).toBeDefined();
        done();
      })
    }, 100);
  });

  it('can save the blank message', function(done) {
    setTimeout(function() {
      var oldLength = scope.messages.length;

      // Assert it's a new message
      expect(scope.message.id).not.toBeDefined();

      // Be sure to pass validations in the back end
      scope.message.body = 'foo';

      // Save it
      scope.message.$save(function() {
        setTimeout(function() {
          // Make sure that the message was added to the collection
          expect(scope.messages.length).toBe(oldLength + 1);

          // Make sure that it has been persisted and new attributes
          // were sent over from the back end and updated here
          setTimeout(function() {
            expect(scope.message.id).toBeDefined();
            expect(scope.message.created_at).toBeDefined();
            expect(scope.message.updated_at).toBeDefined();
            done();
          }, 100);
        }, 100);
      });      
    }, 100);
  });

  it('can update an existing message', function(done) {
    setTimeout(function() {
      // Pick first message
      var message = scope.messages[0];

      // Assert that message has been persisted before
      expect(message.id).toBeDefined();

      // Remember old updated_at
      var oldUpdatedAt = message.updated_at;

      // Update it
      message.body = 'new body';
      message.$save(function() {
        setTimeout(function() {
          // Assert that message was updated across collection
          expect(scope.messages[0].body).toBe('new body');

          // Assert that message was actually updated in back end
          // and attributes have been updated here
          expect(scope.message.updated_at).not.toBe(oldUpdatedAt);
          done();
        }, 100);
      });
    }, 100);
  });

  it('gets validation errors', function(done) {
    setTimeout(function() {
      // Pick first message
      var message = scope.messages[0];

      // Assert that message has been persisted before
      expect(message.id).toBeDefined();

      // Update it so it won't pass validations in the back end
      message.body = '';

      // Remember old updated_at
      var oldUpdatedAt = message.updated_at;

      // Save it
      message.$save(function() {
        // Assert that message was not updated on server
        expect(message.updated_at).toBe(oldUpdatedAt);

        // Assert that the message has error messages attached
        // to it
        expect(message.errors.body).toEqual(["can't be blank"])

        done();
      });
    }, 100);
  });

  it('checks for validity with $valid()', function() {
    var message = Message.new();

    // Message should be valid without erros
    expect(message.$valid()).toBeTruthy();

    message.errors = {
      body: ["can't be blank"]
    };

    // Message should not be valid because errors
    // are attached
    expect(message.$valid()).not.toBeTruthy();

    // Message should be valid if errors property
    // present but not filled
    message.errors = {};
    expect(message.$valid()).toBeTruthy();
  });

  it('checks for validity with $invalid()', function() {
    var message = Message.new();

    // Message should not be invalid without errors
    expect(message.$invalid()).not.toBeTruthy();

    message.errors = {
      body: ["can't be blank"]
    };

    // Message should be invalid because errors
    // are attached
    expect(message.$invalid()).toBeTruthy();

    // Message should not be invalid if errors property
    // present but not filled
    message.errors = {};
    expect(message.$invalid()).not.toBeTruthy();
  });

  it('can destroy an existing message', function(done) {
    setTimeout(function() {
      // Pick first message
      var message = scope.messages[0];

      // Assert that message has been persisted before
      expect(message.id).toBeDefined();

      var oldLength = scope.messages.length;

      message.$destroy(function() {
        setTimeout(function() {
          expect(scope.messages.length).toBe(oldLength - 1);
          done();
        }, 100);
      });
      done();
    }, 100);
  });

  it('can check for persistence', function() {
    // Instantiate record and mimic persistence
    var message = Message.new({ id: 1 });

    expect(message.$persisted()).toBeTruthy();
  });

  it('can check for lack of persistence', function() {
    // Instantiate record and mimic lack of persistence
    var message = Message.new({ id: undefined });

    expect(message.$persisted()).not.toBeTruthy();
  });
});
