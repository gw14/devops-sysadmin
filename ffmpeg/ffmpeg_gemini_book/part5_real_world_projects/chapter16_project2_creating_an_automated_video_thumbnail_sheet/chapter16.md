# Chapter 16: Project 2: Creating an Automated Video Thumbnail Sheet

A common requirement for video archives and hosting platforms is to have a single image that summarizes the content of a video—a "contact sheet" or "thumbnail sheet." This image typically consists of a grid of frames captured from various points in the video, often with metadata like the filename and duration printed on it.

This project will guide you through creating a script that uses some of FFmpeg's more advanced filters to generate a professional-looking thumbnail sheet from any video file.

## The Goal

We will create a script that automates the following process:

1.  Takes a video file as input.
2.  Uses the `select` and `tile` filters to create a grid of thumbnails.
3.  Overlays text with the filename, resolution, and duration of the video.
4.  Saves the result as a JPEG image.

## The FFmpeg Command Explained

Before we build the script, let's deconstruct the core FFmpeg command. Generating the tile grid and overlaying text requires a complex filtergraph.

```bash
ffmpeg -i input.mp4 -vf "select='gt(scene,0.003)',tile=8x8,drawtext=... ,drawtext=..." -an -frames:v 1 output.jpg
```

This looks simple, but the magic is in the `-vf` filterchain.

*   **`select='gt(scene,0.003)'`**: This is the frame selection filter.
    *   `scene`: This is a value from 0 to 1 that represents how different the current frame is from the previous one. A value of `0` means identical, `1` means completely different.
    *   `gt(scene,0.003)`: The `gt` function means "greater than". So, this expression selects any frame that has a "scene change" score greater than `0.003`. This is a clever way to select frames that are visually interesting and distinct, rather than just picking frames at a fixed time interval.
*   **`tile=8x8`**: This filter takes the stream of selected frames and arranges them into a grid.
    *   `8x8`: We're creating a grid that is 8 thumbnails wide by 8 thumbnails high. FFmpeg will automatically space out the selected frames to fill this grid.
*   **`drawtext=...`**: After the grid is created, we use `drawtext` filters to write metadata on top of the final image.
*   **`-an -frames:v 1`**:
    *   `-an`: We don't need any audio.
    *   `-frames:v 1`: Since the `tile` filter outputs a single, large image frame once it has enough thumbnails, we only need to process and save one video frame to our output JPEG.

## The Script

Now, let's wrap this logic in a reusable Bash script. Create a file named `create_thumbsheet.sh` and make it executable.

```bash
#!/bin/bash

# --- Video Thumbnail Sheet Generator ---
# Creates a grid of thumbnails from a video file with metadata overlay.
#
# Usage: ./create_thumbsheet.sh <input_file>
# ------------------------------------------

set -e

# --- Configuration ---
GRID_COLS=6
GRID_ROWS=5
SCENE_THRESHOLD=0.004 # Lower value = more sensitive to changes
HEADER_FONT_SIZE=32
META_FONT_SIZE=24
FONT_FILE="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" #<-- CHANGE THIS if needed
FONT_COLOR="white"
SHADOW_COLOR="black@0.7"
SHADOW_X=2
SHADOW_Y=2

# --- Input Validation ---
INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
  echo "Error: No input file specified."
  echo "Usage: $0 <input_file>"
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file '$INPUT_FILE' not found."
  exit 1
fi

# Check for font file
if [ ! -f "$FONT_FILE" ]; then
  echo "Error: Font file not found at '$FONT_FILE'."
  echo "Please edit the FONT_FILE variable in the script."
  exit 1
fi

# --- File Naming ---
BASENAME=$(basename "$INPUT_FILE")
OUTPUT_FILE="${BASENAME%.*}_thumbs.jpg"

# --- Get Video Metadata using ffprobe ---
# ffprobe is perfect for extracting specific information.
# -v quiet: Suppress verbose output
# -print_format json: Output in machine-readable JSON format
# -show_format -show_streams: Tell ffprobe which info we want
PROBE_DATA=$(ffprobe -v quiet -print_format json -show_format -show_streams "$INPUT_FILE")

# Parse JSON with 'jq' (a command-line JSON processor). You may need to install it: sudo apt install jq
# If you don't have jq, you'd need to use more complex text processing with grep/awk.
DURATION_S=$(echo "$PROBE_DATA" | jq '.format.duration | tonumber')
WIDTH=$(echo "$PROBE_DATA" | jq '.streams[] | select(.codec_type=="video") | .width')
HEIGHT=$(echo "$PROBE_DATA" | jq '.streams[] | select(.codec_type=="video") | .height')

# Format duration into HH:MM:SS
DURATION_FORMATTED=$(printf "%02d:%02d:%02d" $(($DURATION_S/3600)) $(($DURATION_S%3600/60)) $(($DURATION_S%60)))

# --- Build the FFmpeg Command ---
TILE_FILTER="tile=${GRID_COLS}x${GRID_ROWS}"
SELECT_FILTER="select='gt(scene,${SCENE_THRESHOLD})'"

# Info text to display
HEADER_TEXT="File: ${BASENAME}"
META_TEXT="Resolution: ${WIDTH}x${HEIGHT}   Duration: ${DURATION_FORMATTED}"

# We create two drawtext filters. One for the header, one for the metadata.
# We add a shadow effect by drawing the text twice, once with a shadow color and a slight offset.
DRAWTEXT_HEADER_SHADOW="drawtext=fontfile='${FONT_FILE}':text='${HEADER_TEXT}':x=10+${SHADOW_X}:y=10+${SHADOW_Y}:fontsize=${HEADER_FONT_SIZE}:fontcolor='${SHADOW_COLOR}'"
DRAWTEXT_HEADER="drawtext=fontfile='${FONT_FILE}':text='${HEADER_TEXT}':x=10:y=10:fontsize=${HEADER_FONT_SIZE}:fontcolor='${FONT_COLOR}'"

DRAWTEXT_META_SHADOW="drawtext=fontfile='${FONT_FILE}':text='${META_TEXT}':x=10+${SHADOW_X}:y=(${HEADER_FONT_SIZE}+20)+${SHADOW_Y}:fontsize=${META_FONT_SIZE}:fontcolor='${SHADOW_COLOR}'"
DRAWTEXT_META="drawtext=fontfile='${FONT_FILE}':text='${META_TEXT}':x=10:y=(${HEADER_FONT_SIZE}+20):fontsize=${META_FONT_SIZE}:fontcolor='${FONT_COLOR}'"

# Combine all filters
VIDEO_FILTERS="$SELECT_FILTER,$TILE_FILTER,$DRAWTEXT_HEADER_SHADOW,$DRAWTEXT_HEADER,$DRAWTEXT_META_SHADOW,$DRAWTEXT_META"

# --- Execute the Command ---
echo "Generating thumbnail sheet for '$BASENAME'..."

ffmpeg -i "$INPUT_FILE" -vf "$VIDEO_FILTERS" -an -frames:v 1 -y "$OUTPUT_FILE"

echo "Thumbnail sheet saved as '$OUTPUT_FILE'."
```

## How It Works

1.  **Configuration**: We define the grid size, scene detection sensitivity, and all the styling for the text overlay. **Crucially, you must provide a valid path to a `.ttf` font file.**
2.  **Metadata Extraction**: This script introduces a key best practice: using `ffprobe` to get information *before* running `ffmpeg`.
    *   We run `ffprobe` with `-print_format json` to get a clean, machine-readable output.
    *   We use the amazing command-line tool `jq` to easily parse the JSON and extract the exact duration, width, and height values. This is far more reliable than trying to parse FFprobe's standard text output.
    *   The duration (in seconds) is then formatted into a more human-readable `HH:MM:SS` string.
3.  **Dynamic Filter Building**:
    *   The `select` and `tile` filters are defined based on the configuration variables.
    *   The text for the header and metadata lines is constructed using the data we got from `ffprobe`.
    *   A professional-looking shadow effect is created by layering two `drawtext` filters for each line of text. The first one draws the black "shadow" text at a slight offset, and the second one draws the white "foreground" text on top of it.
    *   All filter strings are concatenated into the final `-vf` argument.
4.  **Execution**: The script then runs the single, powerful `ffmpeg` command, which does all the work in one process: selecting frames, tiling them into a grid, drawing the shadowed text, and outputting a single JPEG image.

## How to Use the Script

1.  **Install `jq`**: On Debian/Ubuntu, run `sudo apt-get install jq`. On macOS with Homebrew, run `brew install jq`.
2.  Save the script as `create_thumbsheet.sh` and make it executable.
3.  **Edit the `FONT_FILE` path** in the script to point to a valid font on your system.
4.  Run it against any video file:
    ```bash
    ./create_thumbsheet.sh "My Vacation Video.mp4"
    ```
The script will produce a file named `My Vacation Video_thumbs.jpg` in the same directory.

## Conclusion

This project demonstrates some of FFmpeg's more advanced filtering capabilities. You've learned how to intelligently select frames using scene detection, how to tile them into a composite image, and how to combine this with `ffprobe` and `jq` to create richly informative, automated media summaries. This is a practical tool that can be used to generate previews for a personal media server, a video archive, or any content management system.
