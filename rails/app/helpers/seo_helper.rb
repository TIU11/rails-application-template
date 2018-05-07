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
    else                        # render default page title
      "#{controller_name.titleize} - #{I18n.t('app.title')}"
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
end
