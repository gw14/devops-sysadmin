# Chapter 7: Mastering Media Streams with `-map`

You've learned about containers, video codecs, and audio codecs. Now it's time to bring it all together. A media file isn't just one monolithic block of data; it's a container holding multiple, distinct **streams**. The most common are video and audio streams, but there can also be subtitle streams, data streams, and even multiple streams of the same type (e.g., audio tracks in different languages).

The `-map` option in FFmpeg is your key to controlling these streams. It is one of the most powerful and essential options you will learn. It allows you to explicitly select which streams from your inputs should be included in your output, giving you complete control over the final file.

## The Concept of Streams

First, let's understand how FFmpeg identifies streams. Every stream in every input file is given an identifier. The format is `input_index:stream_specifier`.

*   **`input_index`**: This refers to the order of the input files (`-i`) you provide in your command, starting from `0`. The first `-i` is input `0`, the second is input `1`, and so on.
*   **`stream_specifier`**: This identifies a specific stream within that input file. It can be:
    *   `stream_index`: The index of the stream within that file, starting from `0`.
    *   `stream_type`: `v` for video, `a` for audio, `s` for subtitle.
    *   `stream_type:stream_index_of_that_type`: e.g., `a:0` for the first audio stream, `a:1` for the second audio stream.

## Using `ffprobe` to Identify Streams

Before you can use `-map`, you must know what streams are in your input files. `ffprobe` is the tool for this job.

```bash
ffprobe input.mp4
```

You'll get a detailed output. The important part is the `Stream` listing at the end:

```
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'input.mp4':
  Metadata:
    ...
  Duration: 00:02:30.50, start: 0.000000, bitrate: 2217 kb/s
    Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 1920x1080, 1917 kb/s, 29.97 fps, 29.97 tbr, 30k tbn, 60k tbc (default)
    Stream #0:1(eng): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 317 kb/s (default)
```

From this, we can identify:
*   `Stream #0:0`: This is the first stream of the first input (`input.mp4`). It's a video stream (`Video: h264`).
*   `Stream #0:1`: This is the second stream of the first input. It's an audio stream (`Audio: aac`) and it's in English (`(eng)`).

## The `-map` Option in Action

By default, for a single input file, FFmpeg automatically selects one stream of each type (the "best" video, "best" audio, etc.). The `-map` option overrides this default behavior and lets you build the output file stream by stream.

### Example 1: Selecting a Specific Stream

Imagine you want to create a new file containing *only the video* from `input.mp4`, discarding the audio.

```bash
# Map only the video stream (stream 0 of input 0)
ffmpeg -i input.mp4 -map 0:0 -c copy video_only.mp4
```
Here, `-map 0:0` tells FFmpeg to take stream `0` from input `0` and put it in the output. Since we didn't map the audio stream (`0:1`), it's discarded.

You can also use the stream type specifier:
```bash
# Map only the video stream (equivalent to -map 0:0 in this case)
ffmpeg -i input.mp4 -map 0:v -c copy video_only.mp4
```

### Example 2: Reordering Streams

Let's say you have a file where the audio stream comes before the video stream. This is unusual but possible. You want to create a new file with the standard video-then-audio order.

```bash
# Assuming input.mp4 has audio as stream 0:0 and video as stream 0:1
# Map video first, then audio
ffmpeg -i input.mp4 -map 0:1 -map 0:0 -c copy reordered.mp4
```
The order in which you use `-map` determines the order of the streams in the output file.

### Example 3: Adding an Audio Track from Another File

This is a very common and powerful use case: replacing or adding audio. Let's say you have `video.mp4` (with silent or bad audio) and `audio.mp3` (the correct soundtrack).

```bash
# Input 0: video.mp4, Input 1: audio.mp3
ffmpeg -i video.mp4 -i audio.mp3 -map 0:v -map 1:a -c copy output_with_new_audio.mp4
```
Let's break this down:
*   `-i video.mp4`: This is input `0`.
*   `-i audio.mp3`: This is input `1`.
*   `-map 0:v`: Select all video streams from the first input (`video.mp4`).
*   `-map 1:a`: Select all audio streams from the second input (`audio.mp3`).
*   `-c copy`: Remux everything, which is fast and lossless.

### Example 4: Handling Multi-Track Audio

Let's say you have a file `movie.mkv` with one video stream and two audio streams (English and Spanish).
`ffprobe movie.mkv` might show:
*   `Stream #0:0`: Video
*   `Stream #0:1`: Audio (English)
*   `Stream #0:2`: Audio (Spanish)

You want to create an MP4 with the video and *only* the English audio.
```bash
ffmpeg -i movie.mkv -map 0:0 -map 0:1 -c copy movie_english.mp4
```

What if you want to keep both audio tracks? Just map them both!
```bash
ffmpeg -i movie.mkv -map 0:0 -map 0:1 -map 0:2 -c copy movie_multilingual.mp4
```
The resulting `movie_multilingual.mp4` will have two audio tracks, and you can switch between them in a compatible media player.

### Example 5: Adding Subtitles

Let's add a subtitle file (`subtitles.srt`) to our video.

```bash
# Input 0: movie.mp4, Input 1: subtitles.srt
ffmpeg -i movie.mp4 -i subtitles.srt -map 0 -map 1 -c copy -c:s mov_text movie_with_subs.mp4
```
*   `-map 0`: This is a shortcut. It maps *all* streams from the first input (video and audio).
*   `-map 1`: Maps *all* streams from the second input (the subtitle stream).
*   `-c copy`: Copies the video and audio streams without re-encoding.
*   `-c:s mov_text`: This is important. We can't just `copy` the SRT subtitles into an MP4 container, as the format is different. We need to transcode the subtitle stream (`-c:s`) into a format compatible with MP4, like `mov_text`. For an MKV container, you could use `-c:s srt` or `-c:s ass`.

### Negative Mappings

You can also use `-map` to *exclude* streams. A negative mapping, `-map -0:s`, means "map all streams from input 0 *except* for the subtitle streams."

```bash
# Create a copy of a file with the subtitles removed
ffmpeg -i input_with_subs.mkv -map 0 -map -0:s -c copy output_no_subs.mkv
```

## Conclusion

Mastering the `-map` option transforms you from a casual FFmpeg user to a power user. It elevates FFmpeg from a simple converter to a precise surgical tool for media manipulation. You now have the ability to deconstruct media files and rebuild them exactly as you see fit—selecting video, adding or removing audio tracks, incorporating subtitles, and more. This skill is foundational for the advanced filtering and complex workflows we will explore in the next part of this book.
