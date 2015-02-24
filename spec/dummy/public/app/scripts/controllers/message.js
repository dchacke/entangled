'use strict';

app.controller('MessageCtrl', function($scope, $routeParams, Message) {
	$scope.update = function() {
		$scope.message.$save();
	};

	Message.find($routeParams.id, function(message) {
		$scope.$apply(function() {
			$scope.message = message;
			console.log('Show callback called!');
		});
	});
});
