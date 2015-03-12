module ListingHelper
  def create_list_header(header, path, placeholder)
    render partial: 'listing_header',
                     locals: { header: header,
                               path: path,
                               placeholder: placeholder }
  end
end
