class UpvoteCommentsWorker
  include Sidekiq::Worker
  include MeedPointsTransactionManager
  include CommentsManager
  include FeedItemsManager

  sidekiq_options retry: true, :queue => :default
  def perform(comment_id, handle)
    comment = get_comments(nil, [comment_id])[0]
    if comment.blank?
      return
    end
    update_feed_update_date(comment.feed_id)
    create_notification(comment.poster_id, handle, comment.feed_id, MeedNotificationType::UPVOTE_COMMENT)
    unless comment.blank?
      reward_for_comment_received(comment.poster_id, comment.id, handle)
    end

  end

end