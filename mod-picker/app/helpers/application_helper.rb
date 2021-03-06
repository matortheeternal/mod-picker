module ApplicationHelper
  def markdown(text)
    render_options = {
      filter_html: true,
      with_toc_data: true,
      hard_wrap: true,
      space_after_headers: true,
    }

    extensions = {
      strikethrough: true,
      tables: true,
      fenced_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(render_options)
    # instance vars used to prevent unnecessary reintiializing
    @markdown ||= Redcarpet::Markdown.new(renderer, extensions)
    @markdown.render(text).html_safe
  end

  # render toc from markdown body using header tags
  def markdown_toc(text)
    @markdown_toc ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML_TOC.new(nesting_level: 3)
    )
    
    toc_div_open = "<div class=\"help-page-toc\">".html_safe
    toc_title = "<h3 class=\"toc-title\">Contents</h3>".html_safe
    toc_body = @markdown_toc.render(text).html_safe
    toc_div_close = "</div>".html_safe

    toc_concat = toc_div_open + toc_title + toc_body + toc_div_close

    if !toc_body.empty?
      toc_concat.html_safe
    else
      nil
    end
  end

  # helper method to append active class to html element depending on the url
  def active_url(url)
    current_page?(url) ? "active" : ""
  end

  def category_image_path(category)
    jpg_path = Rails.root.join('public', 'images', category + '.jpg')
    png_path = Rails.root.join('public', 'images', category + '.png')
    return category + '.jpg' if File.exist?(jpg_path)
    return category + '.png' if File.exist?(png_path)
    'category.png'
  end
end