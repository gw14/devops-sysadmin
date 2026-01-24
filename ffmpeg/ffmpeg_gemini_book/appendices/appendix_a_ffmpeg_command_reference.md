# Appendix A: FFmpeg Command Reference

This appendix provides a quick reference for some of the most common and useful FFmpeg commands and options covered in this book.

## Basic Syntax

```bash
ffmpeg [global_options] [input_options] -i input_file [output_options] output_file
```

---

## Global Options

*   `-y`: Overwrite output file without asking.
*   `-n`: Do not overwrite output file, exit if it exists.
*   `-v [level]`: Set log level (`quiet`, `panic`, `fatal`, `error`, `warning`, `info`, `verbose`, `debug`, `trace`).
*   `-hide_banner`: Suppress printing the FFmpeg banner.

---

## Main Options

### Input/Output

*   `-i [filename]`: Input file.
*   `-ss [time]`: Seek to a specific time. (Input option for speed, output option for accuracy).
*   `-t [duration]`: Limit the duration.
*   `-to [time]`: Stop at a specific time.
*   `-f [format]`: Force input or output format (e.g., `-f flv`).
*   `-re`: Read input at native frame rate (essential for live streaming from a file).

### Video Options

*   `-c:v [codec]`: Set video codec (e.g., `libx264`, `libx265`, `prores_ks`, `copy`).
*   `-b:v [bitrate]`: Set target video bitrate (e.g., `2M`, `500k`).
*   `-maxrate [bitrate]`: Set max video bitrate.
*   `-bufsize [size]`: Set decoder buffer size.
*   `-crf [value]`: Set Constant Rate Factor (quality). Lower is higher quality. (e.g., `23` for `libx264`).
*   `-preset [preset]`: Set encoding speed/compression ratio (`ultrafast`, `veryfast`, `fast`, `medium`, `slow`, `veryslow`).
*   `-r [fps]`: Set frame rate.
*   `-s [WxH]`: Set frame size (resolution), e.g., `1920x1080`.
*   `-aspect [ratio]`: Set aspect ratio, e.g., `16:9`.
*   `-vn`: Disable video (video null).

### Audio Options

*   `-c:a [codec]`: Set audio codec (e.g., `aac`, `libopus`, `mp3`, `flac`, `copy`).
*   `-b:a [bitrate]`: Set target audio bitrate (e.g., `192k`).
*   `-ar [rate]`: Set audio sample rate (e.g., `44100`, `48000`).
*   `-ac [channels]`: Set number of audio channels (e.g., `1` for mono, `2` for stereo).
*   `-an`: Disable audio (audio null).

### Subtitle Options

*   `-c:s [codec]`: Set subtitle codec (e.g., `mov_text`, `srt`, `ass`, `copy`).
*   `-sn`: Disable subtitles (subtitle null).

---

## Filter Options

*   `-vf "[chain]"`: Set video filterchain (e.g., `-vf "scale=1280:-1,hflip"`).
*   `-af "[chain]"`: Set audio filterchain (e.g., `-af "volume=1.5,atempo=1.1"`).
*   `-filter_complex "[graph]"`: Use a complex filtergraph for multiple inputs/outputs.

---

## Common `ffprobe` Commands

*   **Show all information about a file**:
    ```bash
    ffprobe my_video.mp4
    ```
*   **Show only stream information**:
    ```bash
    ffprobe -show_streams my_video.mp4
    ```
*   **Show information in JSON format**:
    ```bash
    ffprobe -v quiet -print_format json -show_format -show_streams my_video.mp4
    ```
*   **Count the number of frames**:
    ```bash
    ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 my_video.mp4
    ```

---

## Common Recipes

*   **Convert MOV to MP4 (Remux)**:
    ```bash
    ffmpeg -i input.mov -c copy output.mp4
    ```
*   **Convert to H.264 / AAC (Transcode)**:
    ```bash
    ffmpeg -i input.avi -c:v libx264 -crf 23 -c:a aac -b:a 192k output.mp4
    ```
*   **Extract a 10-second clip starting at 1 minute (fast seek)**:
    ```bash
    ffmpeg -ss 00:01:00 -i input.mp4 -t 10 -c copy clip.mp4
    ```
*   **Scale video to 720p width**:
    ```bash
    ffmpeg -i input.mp4 -vf "scale=1280:-1" output.mp4
    ```
*   **Extract audio as MP3**:
    ```bash
    ffmpeg -i input.mp4 -vn -c:a libmp3lame -b:a 320k audio.mp3
    ```
*   **Create a high-quality GIF from a video segment**:
    ```bash
    ffmpeg -ss 30 -t 5 -i input.mp4 -vf "fps=15,scale=500:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif
    ```
*   **Add a watermark to the bottom-right corner**:
    ```bash
    ffmpeg -i input.mp4 -i logo.png -filter_complex "[0:v][1:v] overlay=W-w-10:H-h-10" output.mp4
    ```
*   **Stream a file to an RTMP server**:
    ```bash
    ffmpeg -re -i input.mp4 -c:v libx264 -preset veryfast -b:v 4M -c:a aac -f flv "rtmp://..."
    ```
