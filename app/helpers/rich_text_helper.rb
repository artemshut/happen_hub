module RichTextHelper
  YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([\w\-]+)}.freeze

  def render_rich_text_with_embeds(content)
    # Replace YouTube URLs with embedded videos
    content.to_s.gsub(YOUTUBE_REGEX) do
      video_id = Regexp.last_match(1)
      youtube_embed_tag(video_id)
    end.html_safe
  end

  private

  def youtube_embed_tag(video_id)
    <<~HTML
      <div class="youtube-embed">
        <iframe 
          width="560" 
          height="315" 
          src="https://www.youtube.com/embed/#{video_id}" 
          title="YouTube video player" 
          frameborder="0" 
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
          allowfullscreen>
        </iframe>
      </div>
    HTML
  end
end
