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
      tables: true
    }

    renderer = Redcarpet::Render::HTML.new(render_options)
    # instance vars used to prevent unnecessary reintiializing
    @markdown ||= Redcarpet::Markdown.new(renderer, extensions)
    # generate table of contents as well
    @markdown_toc ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML_TOC.new(nesting_level: 3)
    )
    
    # render table of contents then page content
    @markdown_toc.render(text).html_safe + @markdown.render(text).html_safe
  end
end