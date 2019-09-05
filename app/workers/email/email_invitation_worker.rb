class EmailInvitationWorker
  include Sidekiq::Worker
  include UsersManager
  include UsersHelper
  include FeedItemsManager
  include ProfilesManager
  include CrmManager
  include CrmHelper

  sidekiq_options retry: true, :queue => :critical

  #current active variations email_invitation_5, email_invitation_0
  #email_invitaiton_0 = job

  def perform(email, invitor_id, variation_id, with_media)
    if get_uninterested_emails.include? email
      return
    end
    email_invitations = EmailInvitation.where(:email => email)
    email_invitation = nil
    email_invitations.each do |invitation|
      unless invitation[:invitor_handle].blank?
        email_invitation = invitation
      end
    end

    if !email_invitations.blank? and email_invitation.blank?
      email_invitation = email_invitations[0]
    end


    user = get_user_by_email(email)
    if user.blank?
      user = create_passive_user(email)
    elsif user[:active]
      logger.info('USER is active returning from not sending invitation')
      return
    end
    email_variation = get_email_invitation_variation
    email_variation_id = "user_invitation_#{email_variation}"
    school_handle = get_school_handle_from_email(user.id).upcase
    subject = get_subject_for_variation(email_variation, school_handle)
    if school_handle.blank?
      return
    end

    if email_invitation.blank?
      email_invitation = create_email_invitation_for_email(email, invitor_id)
      email_invitation.last_variation_used = email_variation_id
      email_invitation.time = Time.now
      email_invitation.save
      track_email_send(email_variation_id)
    elsif !email_invitation.last_variation_used.blank? and email_invitation.last_variation_used.eql? 'reminder_1'
      email_invitation.last_variation_used = 'reminder_2'
      email_invitation.save
    else
      email_invitation.last_variation_used = 'reminder_1'
      email_invitation.save
    end
    filtered_feed_items = Array.[]
    if with_media
      feed_items = get_feed_items_for_school(school_handle, 50)
      user_ids = Hash.new
      feed_items.each do |feed_item|
        if user_ids[feed_item[:user].handle] == nil
          user_ids[feed_item[:user].handle] = feed_item[:user].handle
          filtered_feed_items << feed_item
        end
      end
      if filtered_feed_items.length > 5
        filtered_feed_items  = filtered_feed_items.each_slice(3).to_a[0]
      end
    end

    schools = admin_all_schools
    Notifier.email_user_invitation(user, email_invitation[:_id], subject, email_variation_id, email_variation, with_media, filtered_feed_items.shuffle!, schools).deliver
  end

end