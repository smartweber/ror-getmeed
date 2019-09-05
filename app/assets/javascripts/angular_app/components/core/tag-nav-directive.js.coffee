tagNav = ($timeout, CONSTS, CollectionFactory, CollectionsFactory) ->

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/tag-nav.html"
  scope: {
    trendingTags: "="
  }
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->


tagNav.$inject = [
  "$timeout"
  "CONSTS"
  "CollectionFactory"
  "CollectionsFactory"
]

angular.module("meed").directive "tagNav", tagNav
