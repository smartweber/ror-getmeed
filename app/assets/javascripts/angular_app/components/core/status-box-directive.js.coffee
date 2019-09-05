# Expects user to be passed in
statusBox = (CONSTS,
             VENDOR,
             $timeout,
             MeedpostFactory,
             CollectionsFactory,
             CollectionFactory,
             ActivityFeedItemFactory) ->

  validateURL = (textval) ->
    urlRegex = /(https?:\/\/[^\s]+)/g
    urlFinal = ''
    textval.replace urlRegex, (url) ->
      urlFinal = url
    return urlFinal

  ctrl = ($scope) ->
    $scope.filepickerApiKey = CONSTS.filepicker_api_key
    $scope.formData = {}
    $scope.publishFormData = {
      major_types: []
      topics: []
      collection_ids: []
      type: ''
      event_id: ''
      tag_ids: []
    }

    prepareSubmitForm = () ->
      $("#topics-select").selectize(maxItems: 2)
      $("#topics-select").bind "chosen:maxselected", -> UTILS.alert("Max two topics allowed")
      $("#tutorial-text").hide()
      $("#tutorial-rules").slideUp "slow"

    scrapeCallback = (data) ->
      $scope.item = data
      $scope.publishFormData.scrape_id = $scope.item._id
      $scope.scrapeLoading = false
      $timeout ->
        prepareSubmitForm()

    $scope.submitScrape = (url) ->
      $scope.scrapeLoading = true
      MeedpostFactory.scrape(url).success scrapeCallback

    $scope.askQuestion = () ->
      prepareSubmitForm()


    $scope.submitUploadImage = () ->
      $scope.scrapeLoading = true
      MeedpostFactory.uploadImage($scope.formData.imageUrl).success scrapeCallback

  ctrl.$inject = [
    "$scope"
  ]

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/core/status-box.html"
    replace: false
    scope: {
      user: "="
      event: "="
      feedItems: "="
      allCollections: "="
      tags: "="
      defaultTagId: "@"
      placeholderText: "@"
      showAttachments: "@"

    }
    controller: ctrl
    link: ($scope, elem, attrs) ->
      $scope.button_loading = false

      $scope.submitPublish = (isValid = true) ->
        return unless isValid
        $scope.button_loading = true
        $scope.publishFormData.type = 'question'
        if $scope.event
          $scope.publishFormData.event_id = $scope.event.id

        if $scope.defaultTagId
          $scope.publishFormData.tag_ids.push($scope.defaultTagId)

        MeedpostFactory.publish($scope.publishFormData).success (data) ->
          feedItem = new ActivityFeedItemFactory(data.data)
          $scope.feedItems.unshift(feedItem)
          txt_input = $('#status-textarea')
          txt_input.val('')
          txt_input.attr('style', 'height:8rem')
          $('#tag_audience_options').slideUp "slow"
          $scope.item = undefined
          if !$scope.collectionId
            $input = $(elem).find(".search-collections-input")
            control = $input[0].selectize
            control.clear()

            $input = $(elem).find(".search-tags-input")
            control = $input[0].selectize
            control.clear()
            $scope.button_loading = false


      $timeout ->
        $("#status-box").on "mouseenter", ->
          $('#tag_audience_options').slideDown "slow"

#        $(window).scroll ->
#          $('#tag_audience_options').slideUp "slow"

        $("#status-textarea").on "blur keyup change paste", ->
          if this.value != ''
            this.style.height = "1px"
            this.style.height = (25 + this.scrollHeight)+"px"

          text = $('#status-textarea').val()
          url = validateURL(text)
          caption = text.replace(url, '')
          $scope.publishFormData.caption = caption
          if url
            $scope.submitScrape(url)

        $("#feed-item-file").change ->
          $scope.submitUploadImage()

        VENDOR.loadFilepicker(VENDOR.createFilepickerWidgets)
    }

statusBox.$inject = [
  "CONSTS"
  "VENDOR"
  "$timeout"
  "MeedpostFactory"
  "CollectionsFactory"
  "CollectionFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").directive "statusBox", statusBox
