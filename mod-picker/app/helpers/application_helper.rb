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

    @markdown.render(text).html_safe
  end
end