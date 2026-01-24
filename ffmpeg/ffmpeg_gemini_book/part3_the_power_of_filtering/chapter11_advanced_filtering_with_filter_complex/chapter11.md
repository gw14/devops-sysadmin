# Chapter 11: Advanced Filtering with `filter_complex`

You've mastered simple filterchains. You can scale, crop, rotate, and adjust volume with ease. But what happens when a task requires more than one input, like overlaying a watermark, or creates more than one output, like making a preview version alongside a full-quality one? For this, you must graduate to `-filter_complex`.

`filter_complex` is the engine that drives FFmpeg's most advanced capabilities. It allows you to create arbitrarily complex graphs of filters, with multiple inputs and outputs, enabling you to perform tasks that are impossible with simple `-vf` or `-af` chains.

## Why and When to Use `filter_complex`

You **must** use `filter_complex` when your filtering graph has any of the following characteristics:

1.  **More than one video or audio input**: For example, taking video from `input1.mp4` and overlaying an image from `input2.png`.
2.  **More than one video or audio output**: For example, taking one video input and creating two different scaled versions of it.
3.  **An input stream type that doesn't match the output stream type**: For example, using a video stream to generate an audio waveform (`showwavesrc`).

## The `filter_complex` Syntax: Understanding Pads and Labels

The syntax of `filter_complex` is more verbose than a simple filterchain because you have to manually define the data flow. This is done by labeling the inputs and outputs of your filters. These connection points are called **pads**.

Let's look at the syntax for a single filter within a `-filter_complex` chain:

`[in_pad_1][in_pad_2]... filter_name=parameters [out_pad_1][out_pad_2]...`

*   **`[in_pad_1]`**: This is a label that points to a stream. It can be a stream from an input file (e.g., `[0:v]` for the video from the first input) or the output of a previous filter in the chain.
*   **`filter_name=parameters`**: The filter you are applying.
*   **`[out_pad_1]`**: A new label you create to identify the output of this filter. You can then use this label as the input for another filter.

Filters are separated by semicolons `;

If an output pad is not labeled, it is considered a "final" output and can be mapped using the `-map` option.

## `filter_complex` in Action: Practical Examples

### Example 1: The Watermark (Overlay)

This is the classic `filter_complex` example. We want to overlay `logo.png` on top of `input.mp4`. This requires two video inputs.

```bash
ffmpeg -i input.mp4 -i logo.png \
-filter_complex "[0:v][1:v] overlay=10:10" \
-c:a copy \
output.mp4
```
Let's break it down:
1.  `-i input.mp4 -i logo.png`: We have two inputs, `input.mp4` (index `0`) and `logo.png` (index `1`).
2.  `-filter_complex "..."`: Begins the complex filtergraph.
3.  `[0:v]`: Selects the first available video stream from the first input (`input.mp4`).
4.  `[1:v]`: Selects the first available video stream from the second input (`logo.png`).
5.  `overlay=10:10`: The `overlay` filter takes two inputs. We have provided `[0:v]` as the first ("main") and `[1:v]` as the second ("overlay"). It places the logo at `x=10, y=10`.
6.  The `overlay` filter produces one video output. Since we didn't label it (e.g., `[v_out]`), FFmpeg makes it available to be mapped to the final output file.
7.  `-c:a copy`: Since we didn't touch the audio, we can copy it directly from the input, which is much faster. FFmpeg is smart enough to know this audio comes from `input.mp4`.

### Example 2: Picture-in-Picture (Two Videos)

This is similar to the watermark, but both inputs are videos. We'll scale the second video down before overlaying it.

```bash
ffmpeg -i main.mp4 -i pip_video.mp4 \
-filter_complex "[1:v] scale=320:-1 [pip]; [0:v][pip] overlay=W-w-10:10" \
output.mp4
```
This graph is more advanced and contains two filters chained together:
1.  `[1:v] scale=320:-1 [pip]`: 
    *   `[1:v]`: Takes the video from the second input (`pip_video.mp4`).
    *   `scale=320:-1`: Scales it to 320 pixels wide.
    *   `[pip]`: **Labels** the output of the scale filter as `[pip]`. This is a temporary name we can use later.
2.  `;`: A semicolon separates the filters in the graph.
3.  `[0:v][pip] overlay=W-w-10:10`:
    *   `[0:v]`: Takes the video from the first input (`main.mp4`).
    *   `[pip]`: Takes our newly created, scaled-down video stream as the second input.
    *   `overlay=W-w-10:10`: Overlays the `[pip]` stream on the `[0:v]` stream in the top-right corner.

### Example 3: Splitting a Stream for Multiple Outputs (`split`)

The `split` filter is used to take one input and create multiple identical copies. This is perfect for creating different versions of a video in one command.

Let's create a full-size 1080p version and a smaller 480p preview version of a video.

```bash
ffmpeg -i input.mp4 \
-filter_complex "[0:v] split=2 [full][preview]; [preview] scale=-1:480 [preview_scaled]" \
-map "[full]" -c:v libx264 -crf 22 output_1080.mp4 \
-map "[preview_scaled]" -c:v libx264 -crf 28 output_480.mp4
```
This is our most complex example yet.
1.  `[0:v] split=2 [full][preview]`: 
    *   Takes the input video.
    *   `split=2`: Creates two identical copies of it.
    *   `[full][preview]`: Labels the two copies so we can refer to them.
2.  `;`: Separates the filters.
3.  `[preview] scale=-1:480 [preview_scaled]`: 
    *   Takes the stream we labeled `[preview]`.
    *   Scales it down to 480p.
    *   Labels the final scaled output as `[preview_scaled]`.
4.  `-map "[full]" ... output_1080.mp4`:
    *   Maps our `[full]` stream to the first output file.
    *   Encodes it with a high-quality CRF of 22.
5.  `-map "[preview_scaled]" ... output_480.mp4`:
    *   Maps our `[preview_scaled]` stream to the second output file.
    *   Encodes it with a lower-quality CRF of 28 to save space.

### Example 4: Visualizing Audio (`showwaves`)

Here's an example where the input and output stream types don't match. We'll take an audio file and generate a video of its waveform.

```bash
ffmpeg -i audio.mp3 \
-filter_complex "[0:a] showwaves=s=1280x200:colors=White:mode=line,format=yuv420p [v]" \
-map "[v]" -map 0:a \
waveform_video.mp4
```
1.  `[0:a] showwaves=... [v]`: 
    *   Takes the audio stream (`[0:a]`) as input.
    *   The `showwaves` filter generates a video representation of it, with a size of 1280x200.
    *   The output of this filter is a video stream, which we label `[v]`.
2.  `format=yuv420p`: The `showwaves` filter might output a pixel format that isn't compatible with the standard MP4 encoder. This extra filter ensures the pixel format is `yuv420p`, which is the most compatible for `libx264`.
3.  `-map "[v]"`: Maps our newly generated video stream to the output file.
4.  `-map 0:a`: Maps the original audio from the input file to the output file, so the video has sound.

## Conclusion

`filter_complex` is the pinnacle of FFmpeg's filtering system. It requires a more deliberate and structured way of thinking, but it unlocks a universe of possibilities. You can now build sophisticated, multi-input, multi-output media processing pipelines. You can watermark videos, create picture-in-picture effects, generate multiple versions of a file simultaneously, and even create video from audio.

With this knowledge, you have completed your journey through the core concepts and filtering capabilities of FFmpeg. You are no longer just a user; you are an architect of media workflows. In the final parts of this book, we will look at more advanced topics like performance optimization and streaming, and then apply everything you've learned to complete real-world projects from start to finish.
