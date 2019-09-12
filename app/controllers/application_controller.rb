class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :set_raven_context


  class MissingDocumentException < Exception
    def initialize(msg)
      super("Missing data from Prismic response (#{msg})")
    end
  end

  rescue_from MissingDocumentException do |e|
    missing_document(e)
  end

  LOCALES = {
    fr: 'fr-fr',
    en: 'en-us',
  }

  # redirect to the localized root according to preferred languages
  def root
    # request.headers.fetch('HTTP_ACCEPT_LANGUAGE') is formatted like "en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7"
    locales = request.headers.fetch('HTTP_ACCEPT_LANGUAGE').scan(/(\w{2})(-\w{2})?/).map(&:first).uniq.map(&:to_sym)
    # locales is formatted like [:en, :fr]

    locale = (locales & I18n.available_locales).first || I18n.default_local
    redirect_to index_path(locale: locale)
  end

  private

  
  def api
    @api ||= PrismicService.init_api
  end

  def ref
    @ref ||= preview_ref || experiment_ref || api.master_ref.ref
  end

  def preview_ref
    if request.cookies.has_key?(Prismic::PREVIEW_COOKIE)
      request.cookies[Prismic::PREVIEW_COOKIE]
    else
      nil
    end
  end

  def experiment_ref
    api.experiments.ref_from_cookie(request.cookies[Prismic::EXPERIMENTS_COOKIE])
  end
  
  def missing_document(error)
    # TODO: send context on missing document to Sentry
    redirect_to controller: 'errors', action: 'not_found'
  end

  def shared_content
    @shared_content = i18n_api_query(
      Prismic::Predicates.at('document.type', 'header')
    )
    raise MissingDocumentException.new('header') if @shared_content.nil?
  end

  def render_menu_footer
    @menu_footer = i18n_api_query(
      Prismic::Predicates.at('document.type', 'menu-footer')
    )

    raise MissingDocumentException.new('menu-footer') if @menu_footer.nil?
  end
  
  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def set_locale
    I18n.locale = params[:locale]

    @locale = LOCALES[I18n.locale]
  end

  def i18n_api_query(predicate, options={})
    localized_query(predicate, @locale, options) ||
    # fallback to fr-fr
    localized_query(predicate, 'fr-fr', options)
  end

  def i18n_api_uid(page, uid, options={})
    response = api.getByUID(page, uid,
      { lang: @locale, ref: ref }.merge(options)
    )

    # handle_single_response(responses, locales, @locale)
    response
  end

  def localized_query(predicate, locale, options={})
    responses = api.query(predicate,
      { lang: locale, ref: ref }.merge(options)
    )

    # handle_single_response(responses, locales, locale)
    responses.results.first
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end
end
