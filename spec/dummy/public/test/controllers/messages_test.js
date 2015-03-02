'use strict';

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

      scope.message.$save(function() {
        setTimeout(function() {
          expect(scope.messages.length).toBe(oldLength + 1);
          done();
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

      // Update it
      message.body = 'new body';
      message.$save(function() {
        setTimeout(function() {
          // Assert that message was updated across collection
          expect(scope.messages[0].body).toEqual('new body');
          done();
        }, 100);
      });
    }, 100);
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
});
