function yt1080() {
  yt-dlp -f "bv*[height=1080]+ba/b[height=1080]" --merge-output-format mp4 "$@"
}

ytmp3() {
  if [ $# -eq 0 ]; then
    echo "Usage: ytmp3 <url>"
    return 1
  fi

  yt-dlp \
    --ignore-errors \
    -x \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --convert-thumbnails jpg \
    --add-metadata \
    "$@"
}
