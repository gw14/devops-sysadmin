# Chapter 15: Project 1: The Ultimate Media Converter

This project brings together everything you've learned about scripting, codecs, and filters to create a practical and powerful tool: a Bash script that intelligently converts any media file into a web-optimized MP4.

## The Goal

We will create a shell script named `convert_for_web.sh` that does the following:

1.  Accepts an input file as an argument.
2.  Encodes the video to H.264 (`libx264`) for maximum compatibility.
3.  Encodes the audio to AAC (`aac`).
4.  If the video is wider than 1080p, it scales it down to 1080p, maintaining aspect ratio.
5.  If the video's aspect ratio isn't the standard 16:9, it adds black bars (letterboxes/pillarboxes) to make it 16:9.
6.  (Optional) Adds a watermark image to the top-right corner.
7.  Saves the output with a `_web.mp4` suffix.

## The Script

Create a new file named `convert_for_web.sh` and make it executable (`chmod +x convert_for_web.sh`).

```bash
#!/bin/bash

# --- The Ultimate Media Converter ---
# Converts any video file to a web-optimized H.264/AAC MP4.
#
# Usage: ./convert_for_web.sh <input_file> [watermark_image]
# ------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
TARGET_WIDTH=1920
TARGET_HEIGHT=1080
VIDEO_CRF=23
AUDIO_BITRATE="192k"
WATERMARK_PADDING=20

# --- Input Validation ---
INPUT_FILE="$1"
WATERMARK_FILE="$2"

if [ -z "$INPUT_FILE" ]; then
  echo "Error: No input file specified."
  echo "Usage: $0 <input_file> [watermark_image]"
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file '$INPUT_FILE' not found."
  exit 1
fi

if [ -n "$WATERMARK_FILE" ] && [ ! -f "$WATERMARK_FILE" ]; then
  echo "Error: Watermark file '$WATERMARK_FILE' not found."
  exit 1
fi

# --- File Naming ---
BASENAME=$(basename "$INPUT_FILE")
OUTPUT_FILE="${BASENAME%.*}_web.mp4"

# --- Build the FFmpeg Command ---

# Start with the basic command
CMD="ffmpeg -i \"$INPUT_FILE\""

# Add watermark input if provided
if [ -n "$WATERMARK_FILE" ]; then
  CMD="$CMD -i \"$WATERMARK_FILE\""
fi

# Start the filter complex chain
FILTER_COMPLEX=""

# Video filters: scale and pad to 16:9
# 1. scale: Downscale if source is larger than target, but maintain aspect ratio.
# 'force_original_aspect_ratio=decrease' ensures it only shrinks.
# 'iw*min(1,${TARGET_WIDTH}/iw)':'ih*min(1,${TARGET_HEIGHT}/ih)' is a robust way to do this.
VIDEO_FILTERS="scale='iw*min(1,${TARGET_WIDTH}/iw)':'ih*min(1,${TARGET_HEIGHT}/ih)':force_original_aspect_ratio=decrease"
# 2. pad: Add black bars to fit the scaled video into the target resolution.
VIDEO_FILTERS="$VIDEO_FILTERS,pad=${TARGET_WIDTH}:${TARGET_HEIGHT}:(ow-iw)/2:(oh-ih)/2"

# Watermark filter
if [ -n "$WATERMARK_FILE" ]; then
  # If watermarking, we must use filter_complex
  # The main video stream is [0:v], watermark is [1:v]
  # We label the output of the pad filter as [mainvideo]
  FILTER_COMPLEX="[0:v]${VIDEO_FILTERS}[mainvideo];[mainvideo][1:v]overlay=W-w-${WATERMARK_PADDING}:H-h-${WATERMARK_PADDING}"
else
  # No watermark, so we can use a simple -vf filter
  CMD="$CMD -vf \"$VIDEO_FILTERS\""
fi

# If we built a filter_complex chain, add it to the command
if [ -n "$FILTER_COMPLEX" ]; then
  CMD="$CMD -filter_complex \"$FILTER_COMPLEX\""
fi

# Add audio and video encoding parameters
CMD="$CMD -c:v libx264 -crf $VIDEO_CRF -preset medium -c:a aac -b:a $AUDIO_BITRATE -movflags +faststart"

# Add the output file
CMD="$CMD \"$OUTPUT_FILE\""

# --- Execute the Command ---
echo "---"
echo "Input: $INPUT_FILE"
if [ -n "$WATERMARK_FILE" ]; then
  echo "Watermark: $WATERMARK_FILE"
fi
echo "Output: $OUTPUT_FILE"
echo "Executing FFmpeg command:"
echo "$CMD"
echo "---"

# Run the command
eval "$CMD"

echo "---"
echo "Conversion complete: $OUTPUT_FILE"
echo "---"

```

## How It Works

1.  **Configuration**: At the top of the script, we define key variables like target resolution and quality settings. This makes them easy to change later.
2.  **Input Validation**: The script checks if an input file was provided and if it actually exists. It does the same for the optional watermark file. This prevents errors down the line.
3.  **File Naming**: It intelligently creates an output filename based on the input filename (e.g., `my_video.mov` -> `my_video_web.mp4`).
4.  **Dynamic Command Building**: This is the core of the script. It builds the `ffmpeg` command string piece by piece.
    *   It starts with the basic `ffmpeg -i <input>`.
    *   If a watermark is provided, it adds a second `-i <watermark>`.
    *   It defines the `scale` and `pad` filters needed to correctly size the video.
    *   **Conditional Logic**:
        *   If a watermark is present, it *must* use `-filter_complex`. It constructs a graph that scales and pads the main video, then overlays the watermark.
        *   If no watermark is present, it uses the simpler and more efficient `-vf` option.
    *   It adds the video (`libx264`) and audio (`aac`) encoding parameters. `-movflags +faststart` is added, which is important for web video as it moves metadata to the beginning of the file, allowing it to start playing before it's fully downloaded.
    *   Finally, it adds the output filename.
5.  **Execution**:
    *   The script prints the final command it's about to run. This is excellent for debugging.
    *   The `eval` command executes the string as if it were typed directly into the terminal. `eval` is needed here to correctly handle all the quotes within our command string.

## How to Use the Script

1.  Save the script as `convert_for_web.sh`.
2.  Make it executable: `chmod +x convert_for_web.sh`.
3.  Place it in a directory with your video files.
4.  (Optional) Place a `watermark.png` file in the same directory.

**To convert a video without a watermark:**
```bash
./convert_for_web.sh my_video.mov
```

**To convert a video WITH a watermark:**
```bash
./convert_for_web.sh my_video.mov watermark.png
```

## Conclusion

This project is a perfect example of FFmpeg's synergy with scripting. By wrapping complex logic in a simple script, you've created a powerful, reusable, and intelligent tool. You've combined scaling, padding, conditional watermarking, and web-optimization flags into a single command. This script can be the foundation for your own custom media processing pipeline, and you can easily extend it with more features, such as subtitle handling or creating multiple output qualities at once.
