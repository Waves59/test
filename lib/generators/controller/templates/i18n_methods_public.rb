
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

