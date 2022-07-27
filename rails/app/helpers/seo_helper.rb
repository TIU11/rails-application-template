# frozen_string_literal: true

module SeoHelper
  # Each page should have a unique title.
  #
  # Set the title, perhaps in a show.html.erb
  #
  #    <% title "#{controller_name.titleize} - #{@my_model}" %>
  #
  # Render the title. Typically in layouts/application.html.erb
  #
  #    <title><%= title %></title>
  def title(title = nil)
    if title                    # set the title
      content_for :title, title
    elsif content_for?(:title)  # render view-provided page title
      "#{content_for(:title)} - #{I18n.t('app.title')}"
    else
      default_title
    end
  end

  # Set a view's meta description. Use *sparingly*! Consider for pages whose
  # Google-generated snippet is unsatisfactory, and when it can't be improved
  # by using more symantic markup.
  #
  #    <% meta_description "Describes the content of this page" %>
  #
  # Render the meta description tag. Typically in layouts/application.html.erb
  #
  #    <meta name="description" content="<%= meta_description %>" />
  def meta_description(description = nil)
    if description.present?
      content_for :meta_description, description
    elsif content_for? :meta_description
      content_for :meta_description
    end
  end

  # Direct search engines not to index or follow links for non-production pages.
  # https://moz.com/learn/seo/robots-meta-directives
  def meta_robots
    return if Rails.env.production?

    tag.meta name: 'robots', content: 'none'
  end

  private

    def default_title
      model = instance_variable_get "@#{controller_name.singularize}"
      if action_name.eql?('show') && model
        "#{model} - #{controller_name.titleize.singularize} - #{I18n.t('app.title')}"
      elsif action_name.in?(%w[edit update]) && model
        "Editing #{model} - #{controller_name.titleize.singularize} - #{I18n.t('app.title')}"
      elsif controller_path == 'high_voltage/pages'
        "#{request.path.tr('/', ' ').squish.titleize} - #{I18n.t('app.title')}"
      else
        "#{controller_name.titleize} - #{I18n.t('app.title')}"
      end
    end
end
