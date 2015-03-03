module SanitizedMarkdownRenderer
  def contain_rendered_content(input)
    html = Kramdown::Document.new(input).to_html.html_safe
    sanitized = Sanitize.clean(html)
    have_content(sanitized)
  end
end
