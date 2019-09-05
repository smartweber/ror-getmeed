# Expects user and (optional) helper-text to be passed in
posterInfoUser = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/poster-info-user.html"
  replace: false
  scope: {
    user: "="
    feedType: "@"
    helperText: "@"
    collection:"="
    event: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->


posterInfoUser.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "posterInfoUser", posterInfoUser
