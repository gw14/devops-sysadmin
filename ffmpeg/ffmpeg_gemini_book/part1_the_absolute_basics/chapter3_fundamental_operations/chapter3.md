# Chapter 3: Fundamental Operations

In Chapter 2, you got your feet wet with some basic FFmpeg commands. Now, we're going to dive deeper into these fundamental operations, exploring the nuances and expanding your toolkit for manipulating media files. Understanding these core capabilities is essential before we tackle more advanced topics like filtering and streaming.

## Trimming Video and Audio Precisely (`-ss`, `-t`, `-to`)

One of the most frequent tasks is extracting a specific segment of a video or audio file. FFmpeg offers powerful and flexible options for this: `-ss` (start seek), `-t` (duration), and `-to` (end time). The placement of `-ss` is critical as it affects performance and accuracy.

### Input Seek (`-ss` before `-i`) - Fast but Potentially Inaccurate

When `-ss` is placed *before* the `-i` (input) option, FFmpeg seeks to the closest keyframe before the specified time and starts processing from there. This is very fast but can result in the actual start time being slightly earlier than what you requested, especially if you then re-encode.

```bash
# Extract 10 seconds from input.mp4, starting at 00:01:00
ffmpeg -ss 00:01:00 -i input.mp4 -t 00:00:10 -c copy output_fast.mp4
```

### Output Seek (`-ss` after `-i`) - Accurate but Slower

When `-ss` is placed *after* the `-i` option, FFmpeg reads from the beginning of the input and processes frames until it reaches the specified start time. This is more accurate for precise cuts but is slower as it has to decode (and discard) the frames before your desired start point.

```bash
# Extract 10 seconds from input.mp4, starting precisely at 00:01:00
ffmpeg -i input.mp4 -ss 00:01:00 -t 00:00:10 -c copy output_accurate.mp4
```

**Recommendation:** For speed and approximate cuts, use `-ss` before `-i`. For frame-accurate cuts where re-encoding is acceptable (or if you combine with `-c copy` and accept the slight delay), use `-ss` after `-i`.

### Specifying Duration with `-t` and End Time with `-to`

*   **`-t duration`**: Specifies the *duration* of the output.
    ```bash
    # Extract 30 seconds from input.mp4, starting from the beginning
    ffmpeg -i input.mp4 -t 00:00:30 -c copy clip_30s.mp4
    ```

*   **`-to timestamp`**: Specifies the *end time* of the output. This is often more intuitive than calculating durations.
    ```bash
    # Extract from the beginning of input.mp4 until 00:01:45
    ffmpeg -i input.mp4 -to 00:01:45 -c copy until_1m45s.mp4
    ```
    You can combine `-ss` and `-to` for precise ranges:
    ```bash
    # Extract from 00:00:30 to 00:01:00 (30 seconds duration)
    ffmpeg -ss 00:00:30 -i input.mp4 -to 00:01:00 -c copy segment_30s_to_1m.mp4
    ```

## Changing Codecs: Transcoding vs. Remuxing (`-c:v`, `-c:a`, `-c copy`)

Understanding the difference between transcoding and remuxing is fundamental to efficient FFmpeg usage.

*   **Remuxing (`-c copy`)**: This means copying the raw compressed video and audio data from the input container to a new output container *without re-encoding*. It's incredibly fast, lossless, and consumes very little CPU. It works only if the codecs are compatible with the target container format.
    ```bash
    # Remux MP4 to MKV (if codecs are compatible)
    ffmpeg -i input.mp4 -c copy output.mkv
    ```
    Use this whenever possible to avoid quality loss and save time.

*   **Transcoding**: This involves *re-encoding* the video or audio streams into a different codec or with different parameters for the same codec. This is CPU-intensive, takes time, and is lossy (unless converting to a truly lossless format). You use this when you need to change the codec, resolution, bitrate, or apply filters.
    ```bash
    # Transcode video to H.265 (libx265) and audio to AAC
    ffmpeg -i input.mp4 -c:v libx265 -crf 28 -c:a aac -b:a 128k output_h265.mp4
    ```
    Here, `-c:v libx265` specifies the video codec, and `-c:a aac` specifies the audio codec. `-crf 28` is a quality setting for H.265 (more on this in Chapter 5).

## Resizing Video (`-vf scale`)

The `scale` video filter is one of the most frequently used. It allows you to change the resolution of your video.

### Scaling to a Specific Resolution

```bash
# Scale to 1280x720 pixels
ffmpeg -i input.mp4 -vf scale=1280:720 output_720p.mp4
```

### Scaling while Maintaining Aspect Ratio

This is very common. Use `-1` for either width or height to automatically calculate the other dimension, ensuring the aspect ratio is preserved.

```bash
# Scale to a width of 640 pixels, auto-calculating height
ffmpeg -i input.mp4 -vf scale=640:-1 output_640w.mp4

# Scale to a height of 480 pixels, auto-calculating width
ffmpeg -i input.mp4 -vf scale=-1:480 output_480h.mp4
```

### Downscaling Only (Prevent Upscaling)

To ensure you only downscale and never upscale a video (which can lead to pixelation), you can add a conditional expression:

```bash
# If original width > 1920, scale to 1920:-1; otherwise, keep original resolution
ffmpeg -i input.mp4 -vf "scale='min(iw,1920)':-1" output_max1920w.mp4
```
`iw` refers to the input width. `min(iw,1920)` ensures the output width is never greater than 1920, but not less than the input width if the input is already smaller.

## Extracting Audio from a Video File

As seen in Chapter 2, `-vn` disables video, giving you just the audio.

```bash
# Extract audio and save as MP3
ffmpeg -i input.mp4 -vn output.mp3

# Extract audio and save as AAC
ffmpeg -i input.mp4 -vn -c:a aac -b:a 192k output.aac
```

## Creating an Animated GIF

Creating GIFs from video segments is a popular use case. To get a high-quality GIF, it's often best to use a palettegen/paletteuse filter chain.

### Basic GIF Creation (simpler, lower quality)

```bash
ffmpeg -i input.mp4 -ss 00:00:10 -t 5 -vf "fps=10,scale=320:-1:flags=lanczos" -loop 0 output_basic.gif
```
This is a quick way but can suffer from dithering and limited colors.

### High-Quality GIF Creation (recommended)

This method involves two passes: one to generate a color palette optimized for your video segment, and a second pass to apply that palette during GIF encoding.

```bash
# Pass 1: Generate a palette
ffmpeg -ss 00:00:10 -t 5 -i input.mp4 -vf "fps=10,scale=320:-1:flags=lanczos,palettegen" palette.png

# Pass 2: Create the GIF using the generated palette
ffmpeg -ss 00:00:10 -t 5 -i input.mp4 -i palette.png -filter_complex "fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" -loop 0 output_hq.gif
```

*   `palettegen`: This filter generates an optimal 256-color palette from the input video frames.
*   `[x];[x][1:v]paletteuse`: This is a basic `filter_complex` example. `[x]` labels the output of the first filter chain, and `[1:v]` refers to the second input (our `palette.png`). `paletteuse` then applies this palette to the video frames. We'll delve deeper into `filter_complex` in Part 3.

## Conclusion

You've now solidified your understanding of FFmpeg's fundamental operations. You can precisely trim media, decide when to remux for speed or transcode for compatibility, accurately resize video, extract audio, and create high-quality animated GIFs. These are the building blocks for more complex media manipulations. In Part 2, we will go into the deep details of the different components that make up a media file: containers, video codecs, audio codecs, and streams.
