ProfileInternshipFactory = (StructFactory, ProfileModelPrototype) ->

  # Properties to expect coming in from the API
  props = {
    _id: String
    company: String
    company_id: String
    description: String
    end_month: String
    end_year: String
    handle: String
    kudos_count: Number
    link: String
    skills: Array
    start_month: String
    start_year: String
    title: String

    start_month_num: Number
    end_month_num: Number
  }

  init = (o) ->
    today = new Date()
    o.start_month = "January" unless o.start_month
    o.start_year = today.getFullYear().toString() unless o.start_year
    d = new Date("#{o.start_month} 1, #{o.start_year}")
    o.start_month_num = d.getMonth() + 1
    o.start_month = null

    o.end_month = "January" unless o.end_month
    o.end_year = today.getFullYear().toString() unless o.end_year
    d = new Date("#{o.end_month} 1, #{o.end_year}")
    o.end_month_num = d.getMonth() + 1
    o.end_month = null


  # Instance fields and methods go here
  instanceMethods = {
    class: () -> ProfileInternship
    saveUrl: () -> "/profiles/internship/save"
    dataForApi: () ->
      id = @_id
      id = null if @newEntry

      data = {
        internship_company: @company
        internship_company_id: @company_id
        internship_title: @title
        hidden_id: id
        date: {
          start_month: @start_month_num
          end_month: @end_month_num
          start_year: @start_year
          end_year: @end_year
        }
        internship_description:
          text: @description
        intern_skills: @skills
        link: @link
      }
      data
    startDate: () ->
      new Date("#{@start_month_num}/1/#{@start_year}")

    endDate: () ->
      new Date("#{@end_month_num}/1/#{@end_year}")
  }

  ProfileInternship = StructFactory.build(props, init)

  ProfileInternship.prototype = $.extend(
    {},
    ProfileModelPrototype.prototype,
    instanceMethods
  )

  ProfileInternship


ProfileInternshipFactory.$inject = [
  "StructFactory"
  "ProfileModelPrototype"
]

angular.module("meed").factory "ProfileInternshipFactory", ProfileInternshipFactory
