module ApplicationHelper

  # Render link to previous page, especially for cancelling on a form.
  # When previous page is this page or this isn't a GET request, then link to
  # stored session[:return_to].
  #
  # To set session[:return_to], you will usually add `store_location request.referer` to the edit action.
  def link_back(name, html_options = {})
    get_new_page = request.get? and (request.url != request.referer)
    url = get_new_page ? :back : session[:return_to]
    link_to name, url, html_options
  end

end
