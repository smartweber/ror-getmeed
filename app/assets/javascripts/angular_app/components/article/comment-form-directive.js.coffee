# Expects user to be passed in
commentForm = (CONSTS, $timeout, CommentFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/comment-form.html"
  replace: false
  scope: {
    user: "="
    item: "="
  }
  # controller: ($scope) ->
  link: ($scope, elem, attrs) ->
    $scope.commentData = {
      description: null
    }

    $scope.submitComment = (valid) ->
      return false unless valid
      data = {
        comment_description: [$scope.commentData.description]
        feed_id: $scope.item._id
      }
      CommentFactory.submitComment(data).success (data) ->
        comment = new CommentFactory(data.comment)
        $scope.item.comments.push(comment)
        $scope.commentForm.$setPristine()
        $scope.commentForm.$setUntouched()
        $scope.commentData = {
          description: null
        }

    $timeout ->
      $("#comment-textarea").on "keyup", ->
        this.style.height = "1px"
        this.style.height = (25 + this.scrollHeight)+"px"


commentForm.$inject = [
  "CONSTS"
  "$timeout"
  "CommentFactory"
]

angular.module("meed").directive "commentForm", commentForm
