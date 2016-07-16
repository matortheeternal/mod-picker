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
    # optional extensions can also be included as a separate extensions object
    # eg. ..Markdown.new(renderer, extensions). See redcarpet docs
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end