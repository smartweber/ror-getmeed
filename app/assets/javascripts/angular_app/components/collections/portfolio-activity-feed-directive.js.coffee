portfolioActivityFeed = ($timeout, CONSTS, HorizontalFeedUiFactory) ->

  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      outerWrapSelector = "#category-collections-feed .horizontal-feed-outer-wrap"
      HorizontalFeedUiFactory.initScrollOnHover(outerWrapSelector)


  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/portfolio-activity-feed.html"
  replace: false
  scope: {
    feedItems: "="
    category: "="
    titleOverride: "@"
    noFeedItems: "="
    profile: "="
  }
  link: linkFn
  }

portfolioActivityFeed.$inject = [
  "$timeout"
  "CONSTS"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "portfolioActivityFeed", portfolioActivityFeed
