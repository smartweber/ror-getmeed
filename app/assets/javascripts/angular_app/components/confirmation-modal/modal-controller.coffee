angular.module("meed").controller "ModalController", ['$scope', 'close', ($scope, close) ->
  $scope.close = (result) ->
    close(result)
]
