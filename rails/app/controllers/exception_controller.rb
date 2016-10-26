# Provides dynamic exception pages
#
# TODO:
# * for reliability, compile templated pages to static html served by nginx
#
# A little reading:
# @see (http://geekmonkey.org/articles/29-exception-applications-in-rails-3-2) (Oct 2012)
# @see (https://wearestac.com/blog/dynamic-error-pages-in-rails) (March 2013)
# @see (https://medium.com/@tair/custom-error-pages-in-rails-you-re-doing-it-wrong-ba1d20ec31c0#.lr3k50xcs) (Sep 2015)
# @see (https://mattbrictson.com/dynamic-rails-error-pages) (Feb 2015)
# @see (http://stackoverflow.com/questions/19569033/rails-4-would-like-to-do-custom-error-pages-in-public-folder-using-i18n)
#
class ExceptionController < ApplicationController
  skip_authorization_check
  before_action :set_exception
  layout 'application'

  def not_found
    respond_to do |format|
      format.html { render :not_found, status: @status_code, layout: !request.xhr? }
      format.xml  { render xml: details, root: "error", status: @status_code }
      format.json { render json: {error: details}, status: @status_code }
      format.all  { render plain: text_details, status: @status_code }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render :internal_server_error, status: @status_code, layout: !request.xhr? }
      format.xml  { render xml: details, root: "error", status: @status_code }
      format.json { render json: {error: details}, status: @status_code }
      format.all  { render plain: text_details, status: @status_code }
    end
  end

  protected

  def details
    @rescue_response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
    @details ||= I18n.with_options( scope: [:exception, @rescue_response] ) do |i18n|
      {
        name: @rescue_response,
        code: @status_code,
        title: i18n.t(:title),
        header: i18n.t(:header),
        message: i18n.t(:message)
      }
    end
  end
  helper_method :details

  def text_details
    details.slice(:title, :header, :message).values.join("\n")
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_exception
      @exception = request.env['action_dispatch.exception']
      if @exception.present?
        @status_code = ActionDispatch::ExceptionWrapper.new(Rails.backtrace_cleaner, @exception).status_code
      else
        @status_code = 500
      end
    end

end
