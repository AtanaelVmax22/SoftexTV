class Broadcast < ApplicationRecord
  has_one_attached :video
  has_many :schedules, dependent: :destroy
  # Define a URL do vídeo após o upload
  def video_url
    Rails.application.routes.url_helpers.rails_blob_path(video, only_path: true) if video.attached?
  end

  # Gera o comando FFmpeg com o arquivo de vídeo
def generate_command(show_widgets = false)
  video_path = ActiveStorage::Blob.service.path_for(video.key)
  
  if orientation == "landscape"
    scale_filter = "scale=1366:768,setdar=16/9"
  else # portrait
    scale_filter = "scale=768:1366,setdar=9/16,transpose=1"
  end

  base_command = "ffmpeg -stream_loop -1 -re -i #{video_path} -vf \"#{scale_filter},setsar=1\" \
-c:v libx264 -preset fast -c:a aac -b:a 192k -f hls \
-hls_time 8 -hls_list_size 0 \
-hls_segment_filename \"C:/nginx/temp/hls/segment_#{Broadcast.count}_%03d.ts\" \
\"C:/nginx/temp/hls/stream#{Broadcast.count}.m3u8\""

  if show_widgets
    overlay_filter = "[1:v]scale=768:300,format=yuva420p,colorchannelmixer=aa=0.9[overlay]; \
[bg][overlay]overlay=x=0:y=0"
    base_command = "ffmpeg -stream_loop -1 -re -i #{video_path} -i http://localhost:8080/hls/widgets.m3u8 \
-filter_complex \"[0:v]#{scale_filter},setsar=1[bg];#{overlay_filter}\" \
-c:v libx264 -preset fast -c:a aac -b:a 192k -f hls \
-hls_time 8 -hls_list_size 0 \
-hls_segment_filename \"C:/nginx/temp/hls/segment_#{Broadcast.count}_%03d.ts\" \
\"C:/nginx/temp/hls/stream#{Broadcast.count}.m3u8\""
  end

  base_command
end

end
