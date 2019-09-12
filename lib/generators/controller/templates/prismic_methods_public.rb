
  class MissingDocumentException < Exception
    def initialize(msg)
      super("Missing data from Prismic response (#{msg})")
    end
  end

  rescue_from MissingDocumentException do |e|
    missing_document(e)
  end
