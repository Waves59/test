
  
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
