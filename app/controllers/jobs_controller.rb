class JobsController < ApplicationController
  include SchoolsManager
  include JobsManager
  include JobsHelper
  include UsersManager
  include AnswersManager
  include LinkHelper
  include MessagesHelper
  include FeedItemsManager
  include CommonHelper

  def create_jobs
    redirect_to get_recruiter_home_url
  end

  def all_jobs
    if current_user.blank?
      jobs = get_top_jobs($FEED_PAGE_SIZE, params[:school], params[:majortype], params[:year], false, params[:job_type])
    else
      jobs = get_jobs_for_user(current_user, params[:job_type])
    end
    if jobs.blank?
      respond_to do |format|
        format.js
        format.json {
          jobs_array = Array.[]
          render json: jobs_array
        }
      end
      return
    end
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-jobs', current_user[:_id].to_s, {
                                                        :jobs_count => jobs.blank? ? 0 : jobs.count,
                                                        :page_index => params[:page],
                                                        :ref => {referrer: params[:referrer],
                                                                 referrer_id: params[:referrer_id],
                                                                 referrer_type: params[:referrer_type]}
                                                    })
    end
    rparams = params.except(:page, :position)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.ViewJobs',
                                            {handle: @user.blank? ? 'public': @user[:handle],
                                             jobs_count: jobs.blank? ? 0 : jobs.count,
                                             page_index: params[:page],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })

    jobs = Kaminari.paginate_array(jobs).page(params[:page]).per($FEED_PAGE_SIZE)
    category = 'All Categories'

    if params[:alert].eql? 'invite_success'
      flash[:alert] = 'Successfully included your contacts!'
    end
    categories = [ { :id => generate_id_from_text(JobType::INTERNSHIP.downcase), :name => JobType::INTERNSHIP.to_s},
                   { :id => generate_id_from_text(JobType::MINIINTERNSHIP.downcase), :name => JobType::MINIINTERNSHIP.to_s},
                   { :id => generate_id_from_text(JobType::FULLTIME.downcase), :name => JobType::FULLTIME.to_s},
                   { :id => generate_id_from_text(JobType::APPLIED.downcase), :name => JobType::APPLIED.to_s}]

    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        render json: {
                   categories: categories,
                   jobs: jobs,
                   category: category
               }
      }
    end
  end

  def show_job
    if params[:id].blank?
      redirect_to '/404?url='+request.url
      return
    end
    unless params[:ab_id].blank?
      session[:ab_id] = params[:ab_id]
      track_email_click(params[:ab_id])
    end

    @job = get_job_by_hash(params[:id])
    if @job.blank?
      redirect_to '/404?url='+request.url
      return
    end
    reset_current_user
    @current_user = current_user

    unless @current_user.blank?
      if params[:applied].blank?
        @applied = is_applied_job_hash(current_user[:handle], params[:id])
      else
        @applied = params[:applied]
      end
      unless @job[:question].blank?
        @job[:question][:code_types] = get_all_code_types
      end
      @is_valid = is_job_valid_for_user(@job, current_user)
      @jobs = get_jobs_for_user(@current_user)
    end

    unless params[:referrer].blank? || params[:referrer_type] != 'job'
      cookies[:referrer] = params[:referrer]
      cookies[:referrer_id] = params[:referrer_id]
      cookies[:referrer_type] = params[:referrer_type]
    end

    @company = get_company_by_id(@job.company_id)
    @poster = get_poster_by_email(@job.email)

    unless @job.blank?
      page_title(@job.company)
      @metadata = get_job_metadata(@job, @company, @poster)


      handle = ''
      unless @current_user.blank?
        handle = @current_user.handle

      end
    end
    rparams = params.except(:applied)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.ViewJob',
                                            {
                                                handle: (current_user.blank?) ? 'public' : current_user[:handle],
                                                job_id: @job.id,
                                                applied: @applied,
                                                params: rparams,
                                                ref: {referrer: params[:referrer],
                                                      referrer_id: params[:referrer_id],
                                                      referrer_type: params[:referrer_type],
                                                      meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-job', current_user[:_id].to_s, {
                                                       :job_id => params[:id],
                                                       :applied => @applied,
                                                       :ref => {referrer: params[:referrer],
                                                                referrer_id: params[:referrer_id],
                                                                referrer_type: params[:referrer_type]}
                                                   })
    end

    respond_to do |format|
      format.html {
        return render layout: "angular_app", template: "angular_app/index"
      }
      format.json {

        @job[:applied] = @applied

        return render json: {
          job: @job,
          metadata: @metadata,
          company: @company,
          jobs: @jobs
        }
      }
    end

  end

  def edit_job
    redirect_to get_recruiter_login_url
  end

  def delete_job
    redirect_to get_recruiter_login_url
  end

  def user_job_app_stats
    if params[:id].blank? or params[:job_id].blank? or params[:status].blank?
      redirect_to '/404?url='+request.url
      return
    end
    success = change_job_app_status(params[:status], params[:job_id], params[:id])
    rparams = params.except(:id, :job_id, :status)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.UpdateAppStatus',
                                            {id: params[:id],
                                             job_id: params[:job_id],
                                             new_status: params[:status],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('update-job-status', current_user[:_id].to_s, {
                                                                :job_id => params[:job_id],
                                                                :new_status => params[:status],
                                                                :ref => {referrer: params[:referrer],
                                                                         referrer_id: params[:referrer_id],
                                                                         referrer_type: params[:referrer_type]}
                                                            })
    end

    response = {'success' => success}.to_json
    respond_to do |format|
      format.json {
        render :json => response
      }
    end
  end

  def show_job_status
    redirect_to get_recruiter_login_url
  end

  def apply_job
    unless public_view_session?
      return
    end

    unless logged_in_json?
      return
    end

    user = current_user
    @school_handle = get_school_handle_from_email(user[:_id])
    @school_prefix = @school_handle.upcase
    @school_prefix_handle = get_school_prefix_from_email(current_user[:_id])
    @job = get_job_by_id(params[:id])
    if @job.blank?
      return
    end

    unless @job[:question_id].blank?
      params[:question_id] = @job[:question_id]
      publish_answer
    end
    @job = apply_for_job(user, params[:id], params[:cover_description], @answer.blank? ? nil : @answer.id)
    if @job.blank?
      return
    end

    # jobs = get_jobs_for_user(user)
    rparams = params.except(:id, :cover_description)

    # @jobs = Kaminari.paginate_array(jobs).page(params[:page]).per($FEED_PAGE_SIZE)
    NotificationsLoggerWorker.perform_async('Consumer.Jobs.Apply',
                                            {handle: user[:handle],
                                             job_id: decode_id(params[:id]),
                                             params: rparams,
                                             ref: {referrer: cookies[:referrer],
                                                   referrer_id: cookies[:referrer_id],
                                                   referrer_type: cookies[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('apply-job', current_user[:_id].to_s, {
                                                        :job_id => params[:id],
                                                        :ref => {referrer: cookies[:referrer],
                                                                 referrer_id: cookies[:referrer_id],
                                                                 referrer_type: cookies[:referrer_type]}
                                                    })
    end

    # recommending only organic jobs
    @recommended_jobs = similar_jobs(@job, user, 3, true)

    unless cookies[:referrer].blank? || cookies[:referrer_type] != 'job'
      reward_for_job_application(cookies[:referrer], @job, current_user)
      # CLEAR REFERRAL
      cookies.delete :referrer
      cookies.delete :referrer_id
      cookies.delete :referrer_type
    end

    respond_to do |format|
      format.js
      format.json {
        # jobs_array = Array.[]
        # @jobs.each do |job|
        #   jobs_array << job.as_json
        # end
        # json_hash[:recommended_jobs] = jobs_array
        return render json: {success: true, recommended_jobs: @recommended_jobs}
      }
    end

  end

  def publish_answer
    unless logged_in?
      return
    end

    @user = current_user

    if params[:question_id].blank?
      redirect_to '/404?url='+request.url
      return
    end

    @question = get_question_for_id (params[:question_id])
    if @question.blank?
      redirect_to '/404?url='+request.url
      return
    end


    if params[:description][:text].blank?
      return
    end

    if @question.is_coding
      if params[:lang_type].blank?
        return
      end
      @code_type = get_code_type_by_extension (params[:lang_type])
      if @code_type.blank?
        return
      end
    end

    # Rails.logger.info "111111111111111111111111111111111111111"

    @answer = create_answer(params, @user.handle, @question)
    rparams = params.except(:description, :question_id, :code_description, :id, :lang_type, :add_to_profile)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.SubmitAnswer',
                                            {handle: @user[:handle],
                                             question_id: params[:question_id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('submit-answer', current_user[:_id].to_s, {
                                                            :question_id => params[:question_id],
                                                            :ref => {referrer: params[:referrer],
                                                                     referrer_id: params[:referrer_id],
                                                                     referrer_type: params[:referrer_type]}
                                                        })
    end

  end

  def create_job
    redirect_to get_recruiter_login_url
  end

  def job_photo_upload
    uploaded_io = params[:person][:picture]
  end

  def contact_recruiter
    user = current_user;
    @success = false;
    if user.blank?
      return
    end
    job = get_job_by_hash(params[:id])
    if job.blank?
      return
    end
    sender_user = user
    if sender_user.blank?
      return
    end
    message = get_message_string(params[:description])
    # add job reference at the end
    message += "<br/><br/>Job Reference: <a href='https://getmeed.com/job/#{params[:id]}' target='_blank'>#{job[:title]}</a>"
    (send_message_to_enterpriser(sender_user, job.email, params[:subject], message)) ?
        flash[:notice] = 'You reply has been sent!' :
        flash[:alert] = 'Something went wrong!'
    rparams = params.except(:id, :subject)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.ContactRecruiter',
                                            {handle: user[:handle],
                                             job_id: params[:id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('contact-recruiter', current_user[:_id].to_s, {
                                                                job_id: params[:id],
                                                                ref: {referrer: params[:referrer],
                                                                      referrer_id: params[:referrer_id],
                                                                      referrer_type: params[:referrer_type]}
                                                            })
    end

    @success = true;
    respond_to do |format|
      format.js { render }
      format.json { render json: {success: @success} }
    end
  end

  def share
    user = current_user;
    @success = false;
    if user.blank?
      return
    end
    @job_hash = params[:id]
    if @job_hash.blank?
      return
    end
    sender_user = user
    if (sender_user.blank?)
      return
    end

    create_feed_item(user[:handle], params[:id], UserFeedTypes::JOB, nil)
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.Share',
                                            {handle: user[:handle],
                                             job_id: @job_hash,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('share-job', current_user[:_id].to_s, {
                                                        job_id: decode_id(@job_hash),
                                                        ref: {referrer: params[:referrer],
                                                              referrer_id: params[:referrer_id],
                                                              referrer_type: params[:referrer_type]}
                                                    })
    end

    @success = true;
    respond_to do |format|
      format.js
    end
  end

  def forward
    @success = false
    user = current_user
    if user.blank?
      return
    end
    job_hash = params[:id]
    email = params[:email]
    if job_hash.blank?
      return
    end
    EmailJobForwardWorker.perform_async(user[:_id], email, job_hash)
    rparams = params.except(:id, :email)

    NotificationsLoggerWorker.perform_async('Consumer.Jobs.Forward',
                                            {handle: user[:handle],
                                             job_id: job_hash,
                                             to_email: email,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('forward-job', current_user[:_id].to_s, {
                                                          job_id: decode_id(job_hash),
                                                          to_email: email,
                                                          ref: {referrer: params[:referrer],
                                                                referrer_id: params[:referrer_id],
                                                                referrer_type: params[:referrer_type]}
                                                      })
    end

    @success = true
    respond_to do |format|
      format.js
    end
  end

  def update_user_status
    @success = false
    user = current_user
    if user.blank?
      return
    end
    job_hash = params[:id]
    label = params[:label]
    if job_hash.blank? || label.blank?
      return
    end
    job = get_job_by_hash(job_hash)
    if job.blank?
      return
    end
    status = UserJobAppStats.find("#{user[:handle]}_#{job[:_id]}")
    status[:user_status] = label.downcase;
    status.save()
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('update-user-job-status', current_user[:_id].to_s, {
                                                                     job_id: job[:_id],
                                                                     new_status: label.downcase,
                                                                     ref: {referrer: params[:referrer],
                                                                           referrer_id: params[:referrer_id],
                                                                           referrer_type: params[:referrer_type]}
                                                                 })
    end

    @success = true;
    respond_to do |format|
      format.js
    end
  end

end
