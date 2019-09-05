# Expects item to be passed in with id, url, title
jssocials = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/jssocials.html"
  replace: false
  scope: {
    item: "="
    titleOverride: "="
    urlOverride: "="

  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      if $scope.item
        url = $scope.item.url
        title = $scope.item.title

      url = $scope.urlOverride if $scope.urlOverride
      title = $scope.titleOverride if $scope.titleOverride

      $(elem).jsSocials
        url: url
        text: title
        showCount: false
        showLabel: false
        shares: ["facebook", "twitter",  "linkedin", "email"]

jssocials.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "jssocials", jssocials
