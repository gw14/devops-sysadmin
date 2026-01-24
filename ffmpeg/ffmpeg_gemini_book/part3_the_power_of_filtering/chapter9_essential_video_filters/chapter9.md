# Chapter 9: Essential Video Filters

Now that you understand what filters are, let's get our hands dirty with the most practical and frequently used video filters. This chapter will be a recipe book of commands that you'll return to again and again. We will focus on simple filterchains (`-vf`) for now.

## Geometric Transforms

These filters alter the shape, size, and position of the video frame.

### `scale`: Resizing Video

We've used this before, but it has more tricks.

*   **Scale to a fixed size**:
    ```bash
    ffmpeg -i input.mp4 -vf "scale=1280:720" output.mp4
    ```
*   **Scale while maintaining aspect ratio**:
    ```bash
    # Set width to 640, height is auto-scaled
    ffmpeg -i input.mp4 -vf "scale=640:-1" output.mp4
    ```
*   **Set a limit to avoid upscaling**:
    ```bash
    # Scale to 1280 width only if the original is wider than 1280
    ffmpeg -i input.mp4 -vf "scale='min(1280,iw)':'min(720,ih)'" output.mp4
    ```
    *(Here `iw` and `ih` are the input width and height)*

### `crop`: Cutting Out a Section

The `crop` filter extracts a rectangular region from the video. The syntax is `crop=out_w:out_h:x:y`.

*   `out_w`: Output width
*   `out_h`: Output height
*   `x`, `y`: Top-left corner of the crop rectangle

```bash
# Crop a 640x480 rectangle starting at position (300, 150)
ffmpeg -i input.mp4 -vf "crop=640:480:300:150" output.mp4
```

You can use input dimensions (`iw`, `ih`) to calculate values.

```bash
# Crop the center third of the video
ffmpeg -i input.mp4 -vf "crop=iw/3:ih:iw/3:0" output.mp4
```

### `pad`: Adding Borders (Letterboxing/Pillarboxing)

The `pad` filter adds extra space around the video, which is useful for forcing a specific aspect ratio. The syntax is `pad=out_w:out_h:x:y:color`.

```bash
# Add black bars to a 1280x720 video to make it 1920x1080 (letterboxing)
ffmpeg -i input_1280x720.mp4 -vf "pad=1920:1080:(ow-iw)/2:(oh-ih)/2:black" output_1920x1080.mp4
```
*   `(ow-iw)/2`: Centers the video horizontally. (`ow`=output width, `iw`=input width)
*   `(oh-ih)/2`: Centers the video vertically.

### `rotate` and `flip`

These are straightforward filters for re-orienting the video.

*   **Rotate 90 degrees clockwise**:
    ```bash
    ffmpeg -i input.mp4 -vf "rotate=PI/2" output.mp4
    ```
    *(Rotation is in radians. `PI/2`=90°, `PI`=180°, `3*PI/2`=270°)*

*   **Flip horizontally**:
    ```bash
    ffmpeg -i input.mp4 -vf "hflip" output.mp4
    ```

*   **Flip vertically**:
    ```bash
    ffmpeg -i input.mp4 -vf "vflip" output.mp4
    ```

## Overlays and Text

### `overlay`: Placing One Video on Another

This filter requires a complex filterchain because it has two inputs, but we'll show the syntax here as it's so essential. The `overlay` filter is the foundation of watermarking and picture-in-picture effects.

```bash
# Place logo.png 10 pixels from the top-right corner
ffmpeg -i input.mp4 -i logo.png -filter_complex "[0:v][1:v] overlay=W-w-10:10" output.mp4
```
*   `W-w-10`: Main video width (`W`) minus logo width (`w`) minus 10 pixels.
*   `10`: 10 pixels from the top.

### `drawtext`: Writing Text on Video

The `drawtext` filter is incredibly powerful but can have complex syntax. It allows you to burn text directly into the video frames. You'll often need to specify the font file path.

**Prerequisites**: You need to know the path to a TrueType Font file (`.ttf`) on your system.
*   **Linux**: Often in `/usr/share/fonts/truetype/`
*   **macOS**: In `/System/Library/Fonts/` or `/Library/Fonts/`
*   **Windows**: In `C:\Windows\Fonts\` (you may need to escape the path)

```bash
# Draw "Hello World" in the center of the screen
ffmpeg -i input.mp4 -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Hello World':x=(w-text_w)/2:y=(h-text_h)/2:fontsize=48:fontcolor=white" output.mp4
```

*   `fontfile`: Path to your `.ttf` file.
*   `text`: The text string to draw.
*   `x`, `y`: Position of the text. `(w-text_w)/2` is a common expression for centering.
*   `fontsize`, `fontcolor`: Self-explanatory styling options.

**Dynamic Text**: You can even display dynamic information like the current timestamp.

```bash
# Draw a timestamp in the top-left corner
ffmpeg -i input.mp4 -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='%{pts\:gmtime\:0\:%H\:%M\:%S}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" output.mp4
```
*   `%{pts\:gmtime\:...}`: This is a special expression that converts the frame's presentation timestamp (PTS) into a human-readable timecode.
*   `box=1:boxcolor=black@0.5`: Draws a semi-transparent black box behind the text for better readability.

## Basic Color Correction

These filters allow you to make simple adjustments to the look of your video.

### `eq` (Equalizer)

The `eq` filter lets you adjust contrast, brightness, saturation, and gamma.

```bash
# Increase contrast and saturation
ffmpeg -i input.mp4 -vf "eq=contrast=1.2:saturation=1.5" output.mp4
```
*   `contrast`: Default is `1`. >1 increases, <1 decreases.
*   `brightness`: Default is `0`. Positive values brighten, negative values darken.
*   `saturation`: Default is `1`. >1 increases color, `0` is grayscale.

### `lutyuv` and `lutrgb`

These filters apply a Look-Up Table (LUT) to adjust colors. This is more advanced and is used for tasks like converting between color spaces (e.g., SDR to HDR) or applying creative color grades.

A common use is to convert a video to grayscale.

```bash
# Convert to grayscale using lutyuv
ffmpeg -i input.mp4 -vf "lutyuv=y=val:u=128:v=128" output.mp4
```

## Generating Video from Scratch (Source Filters)

These filters don't take an input; they create a video stream. You must specify a duration (`-t`) and size (`-s`).

### `color`

Generates a solid-colored video.

```bash
# Create a 10-second, 1920x1080 blue video
ffmpeg -f lavfi -i color=c=blue:s=1920x1080:d=10 blue_video.mp4
```
*   `-f lavfi`: Tells FFmpeg the input is a "libavfilter" source.

### `mandelbrot`

Generates the famous Mandelbrot set fractal. Fun for testing!

```bash
# Create a 15-second Mandelbrot zoom
ffmpeg -f lavfi -i mandelbrot=s=1280x720:r=30 -t 15 mandelbrot.mp4
```

## Conclusion

You now have a powerful arsenal of video filters at your command. You can resize, crop, rotate, overlay text, and perform basic color adjustments. These filters are the building blocks of nearly all video editing tasks. Practice combining them in different orders within the `-vf` filterchain to see how they interact. In the next chapter, we'll explore the equivalent toolkit for manipulating audio streams.
