class CompaniesController < ApplicationController
  include FeedItemsManager
  include JobsManager
  include CompanyManager
  include CompanyInsightsHelper
  include CommonHelper


  def recommended_companies
    unless logged_in_json?
      return
    end

    companies = get_recommended_companies(current_user)
    respond_to do |format|
      format.js
      format.json{ return render json: { company_recommendations: companies }}
    end
  end

  def all_companies
    companies = get_all_companies
    respond_to do |format|
      format.js
      format.json{ return render json: { companies: companies }}
    end
  end

  def view
    if params[:id].blank?
      redirect_to '/404?url='+request.url
      return
    end
    @company = get_company_by_id(params[:id])
    if @company.blank?
      redirect_to '/404?url='+request.url
      return
    end
    @skip_banner = true
    @metadata = get_company_metadata(@company)
    @jobs = get_live_jobs_by_company_id(@company._id)
    # filter_jobs_for_viewer(@jobs)
    update_company_view_count(@company)
    @feed_items = get_feed_items_for_poster_id(current_user, @company._id)
    # @feed_items = Kaminari.paginate_array(feed_items).page(params[:page]).per($FEED_PAGE_SIZE)
    @company[:show_about] = !(@company[:description].blank? and @feed_items.blank?)
    load_company_information(@company)
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Company.View',
                                            {handle: (current_user.blank?) ? 'public' : current_user[:handle],
                                             company_id: params[:id],
                                             job_count: @jobs.count,
                                             feed_items: @feed_items.count,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('company-view', current_user[:_id].to_s, {
                                         :company_id => params[:id],
                                         :ref => {referrer: params[:referrer],
                                                       referrer_id: params[:referrer_id],
                                                       referrer_type: params[:referrer_type]}
                                     })
    end


    @feed_items.each do |feed|
      unless feed[:user].blank?
        feed_user_json = feed[:user]
        feed_user_json[:name] = "#{feed[:user][:first_name]} #{feed[:user][:last_name]}"
        feed[:user] = feed_user_json
      end
    end

    if current_user
      user_applied_job_ids = get_user_applied_job_ids(current_user.handle)
      @jobs.each{|job|
        job[:applied] = user_applied_job_ids.include?(job[:_id].to_s)
      }
    end
    respond_to do |format|
      format.js
      format.html {
        return render layout: "angular_app", template: "angular_app/index"
      }
      format.json {
        return render json: {
          company: @company,
          jobs: @jobs,
          feed_items: @feed_items,
          metadata: @metadata
        }
      }
    end
  end

  def auth_view
    unless logged_in?
      return
    end
    redirect_to get_company_url params[:id]
  end

  def follow
    unless logged_in?
      return
    end

    @company_id = params[:id]
    if @company_id.blank? or current_user.blank?
      respond_to do |format|
        format.js
        format.json{ return render json: {success: false} }
      end
    end
    follow_company(@company_id, current_user.handle)
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Company.Follow',
                                            {handle: current_user[:_id],
                                             company_id: @company_id,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('company-follow', current_user[:_id].to_s, {
                                         :company_id => @company_id,
                                         :ref => {referrer: params[:referrer],
                                                       referrer_id: params[:referrer_id],
                                                       referrer_type: params[:referrer_type]}
                                     })
    end



    respond_to do |format|
      format.js
      format.json{ return render json: {success: true} }
    end
  end

  def unfollow
    unless logged_in?
      return
    end

    @company_id = params[:id]
    if @company_id.blank? or current_user.blank?
      respond_to do |format|
        format.js
        format.json{ return render json: {success: false} }
      end
    end

    unfollow_company(@company_id, current_user.handle)
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Company.Unfollow',
                                            {handle: current_user[:_id],
                                             company_id: @company_id,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('company-unfollow', current_user[:_id].to_s, {
                                             :company_id => @company_id,
                                             :ref => {referrer: params[:referrer],
                                                           referrer_id: params[:referrer_id],
                                                           referrer_type: params[:referrer_type]}
                                         })
    end

    respond_to do |format|
      format.js
      format.json{ return render json: {success: true} }
    end

  end

  def load_company_information(company)
    unless current_user.blank?
      company[:is_viewer_following] = is_user_following_company(current_user.handle, company.id)
      school_id = get_school_handle_from_email(current_user.id)
      company_insights = InsightsForCompany.new(school_id, params[:id])
      majors = company_insights.hiring_stats_by_major.sort_by { |_major, count| -count }
      @major_data_string = nil;
      top_majors = nil;
      unless majors.blank?
        @major_data_string = '[' + majors.select { |major, count| !major.blank? }.
            map { |major, count| "['#{major}', #{count}]" }.join(',') + ']'
        # taking the top five majors
        top_majors = majors.take(5).map { |major, _count| major }
      end

      hiring_major_year = company_insights.hiring_stats_by_major_year
      @hiring_major_year_data_string = nil;
      unless hiring_major_year.blank? || top_majors.blank?
        @hiring_major_year_data_string = '[' + top_majors.map { |major|
          year_data = hiring_major_year[major]
          year_data = '[' + year_data.select { |year, count| !year.blank? }.
              map { |year, count| "[Date.UTC(#{year}, 0, 0), #{count}]" }.join(',') + ']';
          "{name: '#{major}', data: #{year_data}}"
        }.join(',') + ']';
      end

      skills = company_insights.hiring_stats_by_skills
      @skills_data_string = nil;
      unless skills.blank?
        @skills_data_string = '[' + skills.select { |skill, count| !skill.blank? }.
            map { |skill, count| "['#{skill}', #{count}]" }.join(',') + ']'
      end

      @interview_difficulty = company_insights.interview_difficulty
      @interview_experience_data_string = nil
      experience = company_insights.interview_experience
      unless experience.blank?
        @interview_experience_data_string = '[' + experience.map { |key, value| "['#{key}', #{value}]" }.join(',') + ']';
      end
      @hiring_sources_data_string = nil
      hiring_sources = company_insights.hiring_sources
      unless hiring_sources.blank?
        @hiring_sources_data_string = '[' + hiring_sources.map { |key, value| "['#{key}', #{value}]" }.join(',') + ']';
      end

      @company_ratings = company_insights.company_ratings
      @company_salaries_byJob = company_insights.salaries_by_job
      @top_benefits = company_insights.company_top_benefits
    end
  end

  def autosuggest
    companies = []
    unless params[:query].blank?
      companies = search_company_by_string(params[:query])
    end
    respond_to do |format|
      format.js
      format.json{return render json: {results: companies}}
    end
  end
end
