# Chapter 14: FFmpeg for Streaming

Beyond file-based conversion, FFmpeg is a dominant force in the world of video streaming. It can both generate streams to send to a server and process streams that it receives. Whether you're creating adaptive bitrate content for on-demand viewing or broadcasting a live event, FFmpeg is an essential tool.

This chapter provides an introduction to the core streaming protocols and shows you how to use FFmpeg to package content for on-demand streaming (HLS/DASH) and how to broadcast a live stream using RTMP.

## Introduction to Streaming Protocols

In a simple file download, you get the whole file from start to finish. Streaming is different. It allows the viewer to start watching almost immediately while the rest of the content is delivered in the background.

*   **Progressive Download**: This is the simplest form. The web server sends the file, and the browser starts playing it as soon as it has enough data. It's simple but not very flexible.

*   **Adaptive Bitrate Streaming (ABS)**: This is how modern streaming services like Netflix and YouTube work. The video is encoded at multiple quality levels (bitrates) and split into small chunks (typically 2-10 seconds long). A manifest file tells the player where to find these chunks. The player can then intelligently switch between quality levels based on the user's available bandwidth, providing a smooth experience with minimal buffering.

The two main ABS protocols are:

1.  **HLS (HTTP Live Streaming)**: Developed by Apple. It uses `.m3u8` manifest files and `.ts` (MPEG-TS) video chunks. It is very widely supported, especially on Apple devices and web browsers.
2.  **DASH (Dynamic Adaptive Streaming over HTTP)**: An international standard. It uses `.mpd` (Media Presentation Description) manifest files and typically `.m4s` video chunks. It is more flexible and codec-agnostic than HLS.

For live events, another protocol is often used to send the stream from the source (your computer) to the server:

*   **RTMP (Real-Time Messaging Protocol)**: A low-latency protocol originally developed by Macromedia (now Adobe). It's the de-facto standard for sending your live stream to services like Twitch, YouTube, and Facebook Live.

## Packaging Content for Adaptive Bitrate Streaming (On-Demand)

Let's say you have a finished video file (`input.mp4`) and you want to prepare it for on-demand streaming on your website. You'll need to encode it into several different quality levels and then create the manifest and segment files for HLS or DASH.

FFmpeg can do all of this in a single, powerful command.

### Example: Creating an HLS Stream

This command takes one input and creates a complete HLS stream with three quality levels (1080p, 720p, 480p).

```bash
ffmpeg -i input.mp4 \
-map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 \
-c:v libx264 -crf 22 -c:a aac -ar 48000 \
-filter:v:0 "scale=-1:1080" -maxrate:v:0 5M -bufsize:v:0 10M \
-filter:v:1 "scale=-1:720" -maxrate:v:1 3M -bufsize:v:1 6M \
-filter:v:2 "scale=-1:480" -maxrate:v:2 1.5M -bufsize:v:2 3M \
-f hls \
-hls_time 4 \
-hls_playlist_type vod \
-hls_segment_filename "stream_%v/segment%03d.ts" \
-master_pl_name master.m3u8 \
stream_%v.m3u8
```

This command looks intimidating, but it's a showcase of FFmpeg's power.
*   `-map ...`: We map the video and audio streams three times to create three output stream pairs.
*   `-c:v libx264 -crf 22 ...`: Sets the general encoding parameters.
*   `-filter:v:0 "scale=-1:1080"`: Applies a filter to the *first* output video stream (`v:0`), scaling it to 1080p.
*   `-maxrate:v:0 5M -bufsize:v:0 10M`: Sets bitrate constraints for that quality level.
*   The same is repeated for the 720p (`v:1`) and 480p (`v:2`) versions.
*   `-f hls`: Sets the output format to HLS.
*   `-hls_time 4`: Creates segments/chunks that are 4 seconds long.
*   `-hls_playlist_type vod`: Specifies this is for Video-on-Demand (as opposed to a live event).
*   `-hls_segment_filename "stream_%v/segment%03d.ts"`: A template for the output segment files. `%v` is the stream index. This will create directories `stream_0`, `stream_1`, etc.
*   `-master_pl_name master.m3u8`: The name of the main manifest file.
*   `stream_%v.m3u8`: A template for the individual quality-level manifest files.

After running this, you will have a set of directories and `.m3u8` files ready to be served by a web server.

## Live Streaming with FFmpeg (RTMP)

This is the more common use case for many creators: sending a live feed from a camera, screen capture, or existing file to a streaming service.

To do this, you need a **Stream Key** and an **RTMP URL** from your service provider (e.g., Twitch, YouTube). It will look something like this:
*   **RTMP URL**: `rtmp://a.rtmp.youtube.com/live2`
*   **Stream Key**: `xxxx-xxxx-xxxx-xxxx`

Your final destination URL is the two combined: `rtmp://a.rtmp.youtube.com/live2/xxxx-xxxx-xxxx-xxxx`

### Example: Streaming a File Live

You can take a pre-existing video file and "stream" it as if it were live. This is great for testing your connection or for broadcasting pre-recorded events.

```bash
ffmpeg -re -i my_event.mp4 -c:v libx264 -preset veryfast -b:v 4M -maxrate 4M -bufsize 8M -c:a aac -b:a 128k -f flv "rtmp://..."
```
*   `-re`: This is **CRITICAL**. It tells FFmpeg to read the input at its native frame rate. Without this, FFmpeg would try to stream the file as fast as possible, overwhelming the server.
*   `-c:v libx264 -preset veryfast ...`: You need to re-encode the video to meet the streaming service's requirements. Using a fast preset is essential for real-time performance.
*   `-b:v 4M -maxrate 4M -bufsize 8M`: Strict bitrate controls are required for streaming. You set a target bitrate, a maximum bitrate, and a buffer size.
*   `-f flv`: The RTMP protocol requires the FLV (Flash Video) container format. FFmpeg handles this automatically when you stream to an `rtmp://` URL, but it's good practice to be explicit.
*   `"rtmp://..."`: Your destination URL and stream key.

### Example: Streaming Your Screen and Microphone (Linux)

FFmpeg can capture directly from input devices, making it a powerful live production tool. Here's how to capture your screen and microphone on Linux.

```bash
ffmpeg -f x11grab -r 30 -s 1920x1080 -i :0.0 \
-f alsa -i default \
-c:v libx264 -preset veryfast -b:v 6M ... \
-c:a aac -b:a 160k ... \
-f flv "rtmp://..."
```
*   `-f x11grab -r 30 -s 1920x1080 -i :0.0`: This is the input for screen capture on Linux. It grabs the X11 display `:0.0` at 30fps with a resolution of 1920x1080.
*   `-f alsa -i default`: This is the input for the default audio device using ALSA.
*   The rest of the command is the same encoding and streaming setup as before.

*(Note: Device capture syntax varies significantly between operating systems. On Windows, you might use `-f dshow`, and on macOS, `-f avfoundation`.)*

## Conclusion

FFmpeg is a cornerstone of both on-demand and live video streaming. You've learned the fundamental difference between HLS, DASH, and RTMP. You now have a template for creating your own adaptive bitrate streams for high-quality, on-demand playback. More importantly, you have the practical knowledge to configure FFmpeg to broadcast a live stream from a file or directly from your devices to major streaming platforms. This is one of the most powerful and commercially relevant applications of FFmpeg today. In the final part of this book, we will put all your accumulated knowledge to the test by completing several real-world projects from start to finish.
