dashboard = (CONSTS, $timeout,$routeParams) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/dashboard.html"
  replace: true
  controller: "DashboardController"
  link: ($scope, elem, attrs) ->
    $timeout ->

dashboard.$inject = [
  "CONSTS"
  "$timeout"
  "$routeParams"
]

angular.module("meed").directive "dashboard", dashboard
