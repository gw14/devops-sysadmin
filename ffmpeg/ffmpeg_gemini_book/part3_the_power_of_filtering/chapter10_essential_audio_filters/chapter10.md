# Chapter 10: Essential Audio Filters

Just as video filters modify the visual content, audio filters (`-af`) allow you to manipulate every aspect of your sound. From simple volume adjustments to complex equalization and channel mapping, audio filters are essential for cleaning up, enhancing, and standardizing your project's sound.

This chapter covers the most important audio filters you'll need for day-to-day tasks.

## Volume and Normalization

### `volume`: Adjusting Volume

This is the most basic and common audio filter. It adjusts the volume of the audio stream.

*   **By a multiplier**:
    ```bash
    # Double the volume (increase by 100%)
    ffmpeg -i input.mp3 -af "volume=2.0" output.mp3

    # Halve the volume (decrease by 50%)
    ffmpeg -i input.mp3 -af "volume=0.5" output.mp3
    ```

*   **By decibels (dB)**:
    ```bash
    # Increase volume by 6 decibels
    ffmpeg -i input.mp3 -af "volume=6dB" output.mp3

    # Decrease volume by 10 decibels
    ffmpeg -i input.mp3 -af "volume=-10dB" output.mp3
    ```

**Warning**: Be careful when increasing volume. If the audio waveform exceeds the maximum possible value (0 dBFS), it will be "clipped," resulting in harsh distortion. To avoid this, it's often better to use audio normalization.

### `loudnorm`: Audio Normalization

Audio normalization is the process of adjusting the overall volume of a piece of audio to meet a target level, ensuring a consistent listening experience. This is far more intelligent than the simple `volume` filter. The `loudnorm` filter is a powerful, two-pass filter that adjusts the audio to meet modern EBU R128 loudness standards.

This is the recommended way to standardize volume for podcasts, streaming, and broadcast.

*   **Pass 1: Analysis**: First, `loudnorm` analyzes the audio to determine its current loudness characteristics without writing an output file.
    ```bash
    ffmpeg -i input.wav -af loudnorm=I=-16:LRA=11:tp=-1.5:print_format=json -f null -
    ```
    This command will print a JSON object with the analysis results, like `input_i`, `input_tp`, `input_lra`, etc.

*   **Pass 2: Applying the normalization**: You then use these measured values in the second pass to apply the normalization.
    ```bash
    ffmpeg -i input.wav -af "loudnorm=I=-16:LRA=11:tp=-1.5:measured_i=-24.3:measured_lra=13.8:measured_tp=-3.4:measured_thresh=-35.1:offset=0.2" output.wav
    ```
    This produces an output file that precisely matches the target loudness levels. While complex, this is the professional way to handle volume.

## Channel Manipulation

These filters allow you to control the individual audio channels within a stream (e.g., the left and right channels in a stereo track).

### `channelmap`: Reordering and Remapping Channels

This filter lets you route audio from one channel to another. For example, if you have a stereo file where the left and right channels are swapped.

```bash
# Swap left and right channels
# Map input Right to output Left, and input Left to output Right
ffmpeg -i swapped.wav -af "channelmap=map=FL-FR|FR-FL" output.wav
```
*(FL = Front Left, FR = Front Right)*

### `pan`: Advanced Panning and Mixing

The `pan` filter is a more powerful version of `channelmap`. It lets you take input channels and mix them into new output channels with specific gain levels.

```bash
# Convert a stereo input to mono by mixing Left and Right channels equally
# Syntax: pan=output_channels|c0=gain*input_c0+gain*input_c1|c1=...
ffmpeg -i stereo.wav -af "pan=mono|c0=0.5*c0+0.5*c1" mono.wav
```
Here, we define a single output channel (`mono`) named `c0`. Its content is made up of half the input left channel (`0.5*c0`) plus half the input right channel (`0.5*c1`).

## Speed and Tempo

### `atempo`: Changing Speed Without Changing Pitch

The `atempo` filter speeds up or slows down audio while preserving its original pitch. The value must be between `0.5` (half speed) and `100.0` (100x speed).

```bash
# Play audio at 1.5x speed
ffmpeg -i input.mp3 -af "atempo=1.5" output.mp3

# Play audio at 75% speed
ffmpeg -i input.mp3 -af "atempo=0.75" output.mp3
```
**Note**: If you need to go beyond 2x speed, you must chain the filter.
```bash
# Play audio at 4x speed
ffmpeg -i input.mp3 -af "atempo=2.0,atempo=2.0" output.mp3
```

### `asetrate`: Changing Speed AND Pitch

The `asetrate` filter changes the speed by resampling the audio, which also changes the pitch (like speeding up or slowing down a tape).

```bash
# Increase speed and pitch by 10%
ffmpeg -i input.mp3 -af "asetrate=44100*1.1" output.mp3

# Decrease speed and pitch by 20%
ffmpeg -i input.mp3 -af "asetrate=44100*0.8" output.mp3
```
*(Assuming a 44.1kHz source sample rate)*

## Merging and Splitting

### `amerge` and `asplit`

These filters are typically used in complex filterchains (`-filter_complex`) but are good to know.

*   `amerge`: Merges two separate audio inputs into a single multi-channel output. For example, merging two mono tracks into one stereo track.
*   `asplit`: Splits one audio input into multiple, identical outputs. This is useful if you want to process a copy of the audio in a different way and perhaps merge it back in later.

**Example Preview (`filter_complex`)**: Merge two mono files into a stereo file.

```bash
ffmpeg -i left.mp3 -i right.mp3 -filter_complex "[0:a][1:a]amerge=inputs=2[a]" -map "[a]" stereo.mp3
```
*   `[0:a][1:a]amerge=inputs=2[a]`: Takes the audio from the first input and the second input, merges them into a 2-channel stream, and labels the output `[a]`.
*   `-map "[a]"`: Maps our newly created stream `[a]` to the output file.

## Conclusion

You are now familiar with the essential toolkit for audio manipulation in FFmpeg. You can control volume with surgical precision using `loudnorm`, remap channels, change tempo, and understand how to merge and split audio streams. These filters provide the foundation for cleaning, correcting, and enhancing the sound of any media project. In the next chapter, we will combine our knowledge of video and audio filters as we dive headfirst into the powerful world of `filter_complex`, where you can build truly custom media processing workflows.
