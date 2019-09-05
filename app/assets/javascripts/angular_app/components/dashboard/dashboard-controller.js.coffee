DashboardController = ($scope,
                       $routeParams,
                       UTILS,
                       CollectionFactory,
                       CollectionsFactory,
                       CurrentUserFactory,
                       ActivityFeedFactory,
                       ActivityFeedItemFactory) ->
  $scope.activityFeedLoaded = false
  $scope.regFlow = false
  if $routeParams.lb or $routeParams.oauth_token
    $scope.regFlow = true
  else
    $scope.regFlow = false

  UTILS.setPageTitle("Home")
  $scope.page = 1
  $scope.pageSize = 5
  $scope.hasFeedItems = false
  if CurrentUserFactory.serverSideLoggedIn()
    $scope.loggedIn = true

  ActivityFeedFactory.getFeedForPage($scope.page++, $scope.pageSize).success (data) ->
    $scope.feedItems = data.feed.map((e) ->
      new ActivityFeedItemFactory(e)
    )
    $scope.allFeedActions = data.actions
    $scope.hasFeedItems = $scope.feedItems.length > 0
    $scope.loading = false



DashboardController.$inject = [
  "$scope"
  "$routeParams"
  "UTILS"
  "CollectionFactory"
  "CollectionsFactory"
  "CurrentUserFactory"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").controller "DashboardController", DashboardController
