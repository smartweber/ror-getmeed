leaderboardModal = ($timeout,
                    $routeParams,
                    CONSTS,
                    UTILS,
                    CollectionsFactory,
                    ProfileFactory,
                    CollectionFactory,
                    FacebookFactory,
                    CompanyFactory,
                    RedirectFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/leaderboard/leaderboard-modal.html"
  replace: true
  scope: {
    leaderboardUsers: "="
    currentUser: "="
    prizes: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.loading = true
    $scope.testInvitations = false

    $timeout ->
      if $routeParams.lb
        CollectionsFactory.getRecommendedCollections().success (data) ->
          $scope.loading = false
          $scope.showNew = false
          if data.recommended_collections
            $scope.recommendedCollections = data.recommended_collections.slice(0, 6).map (e) ->
              new CollectionFactory(e)

            $scope.joinedCollections = data.following_collections.map (e) ->
              new CollectionFactory(e)


            waitForSomeTime = $timeout((->
              $.modal.resize()
            ), 250)
            $(".show-influencer-steps").removeAttr('disabled')
          if $scope.currentUser
            if $scope.currentUser.show_invite
              $scope.testInvitations = true

            if $scope.currentUser.badge == 'influencer'
              $scope.influencerSignUp = true

            ProfileFactory.getUserRecommendations().success (data) ->
              if data.recommended_users
                $scope.recommendedUsers = data.recommended_users.slice(0, 9)
                $(".show-social-steps").removeAttr('disabled')

            ProfileFactory.getLeadUserRecommendations().success (data) ->
              if data.lead_users
                $scope.leadUsers = data.lead_users.slice(0, 9)


      numberOfFollows = 2
      numberOfInfluencerFollows = 2
      $('.facebook-import').click ->
        $scope.loading = true
        $('.facebook-import').hide()
        FacebookFactory.saveFacebookFriends(RedirectFactory.getRedirectUrl())

      $(".show-influencer-steps").click ->
        $scope.loading = false
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".influencer-steps").show()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      $(".show-meed-points").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".company-steps").hide()
        $(".influencer-steps").hide()
        $(".meed-badges").hide()
        $(".meed-points").show()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      $(".show-meed-badges").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".influencer-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".meed-badges").show()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      $(".show-leaderboard").click ->
        $(".leaderboard").show()
        $(".meed-points").hide()
        $(".company-steps").hide()
        $(".influencer-steps").hide()
        $(".welcome-steps").hide()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      $(".close-leaderboard-modal").click ->
        $.modal.close()

      $(".show-social-steps").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".influencer-steps").hide()
        if $scope.testInvitations
          $(".invite-steps").show()
          $(".social-steps").hide()
        else
          $(".social-steps").show()

        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      $(".show-end-steps").click ->
        $.modal.close()

      $(".show-continue-steps").click ->
        if RedirectFactory.hasRedirect
          RedirectFactory.followRedirectUrl()
        else
          UTILS.redirect('/')
#
#      $('#regRecommendedCollections').on 'click', '.button-red', ->
#        numberOfFollows = numberOfFollows - 1
#        if numberOfFollows == 0
#          $(".show-influencer-steps").removeAttr('disabled')
#
#      $('#regRecommendedCollections').on 'click', '.button-red-inverse', ->
#        numberOfFollows = numberOfFollows + 1
#        if numberOfFollows != 0
#          $(".show-influencer-steps").prop('disabled', true)
#
#      $('#regRecommendedUsers').on 'click', '.button-red', ->
#        numberOfInfluencerFollows = numberOfInfluencerFollows - 1
#        if numberOfInfluencerFollows == 0
#          $(".show-social-steps").removeAttr('disabled')
#
#      $('#regRecommendedUsers').on 'click', '.button-red-inverse', ->
#        numberOfInfluencerFollows = numberOfInfluencerFollows + 1
#        if numberOfInfluencerFollows != 0
#          $(".show-social-steps").prop('disabled', true)


leaderboardModal.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "UTILS"
  "CollectionsFactory"
  "ProfileFactory"
  "CollectionFactory"
  "FacebookFactory"
  "CompanyFactory"
  "RedirectFactory"
]

angular.module("meed").directive "leaderboardModal", leaderboardModal
