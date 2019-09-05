angular.module("meed").directive 'hideHtmlTags', ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, element, attr, ngModel) ->
    ngModel.$formatters.push (value) ->
      value.replace(/<br\ ?\/?>/g, "\n").replace /<\/?(a|A).*?>/g, "\n"
    ngModel.$parsers.push (value) ->
      value.replace /\n\r?/g, '<br />'
