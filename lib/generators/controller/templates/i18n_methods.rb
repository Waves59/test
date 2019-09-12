
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
