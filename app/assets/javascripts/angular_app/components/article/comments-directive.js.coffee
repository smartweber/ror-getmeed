# Expects item to be passed in with id, comments
comments = (CONSTS, UTILS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/comments.html"
  replace: true
  scope: {
    item: "="
    currentUser: "="
    showWriteComment: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.$on "editComment", (event, comment) ->
      comment.editing = !comment.editing

    $scope.$on "confirmDeletion", (event, callback) ->
      $scope.confirmed = ->
        callback()
        $.modal.close()
      $scope.closeModal = ->
        $.modal.close()
      angular.element('#confirmation-modal').modal()

comments.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
]

angular.module("meed").directive "comments", comments
