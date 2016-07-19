# smarty pants mixin for code syntax highlighting
class HTMLWithPants < Redcarpet::Render::HTML
  include Redcarpet::Render::SmartyPants
end

module ApplicationHelper
  def markdown(text)
    render_options = {
      filter_html: true,
      with_toc_data: true,
      hard_wrap: true,
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      strikethrough: true,
      tables: true
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
end