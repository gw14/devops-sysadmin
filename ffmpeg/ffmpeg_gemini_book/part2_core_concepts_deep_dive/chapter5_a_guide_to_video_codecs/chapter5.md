# Chapter 5: A Guide to Video Codecs

If containers are the box, **codecs** are the magic that makes the contents fit inside. A video codec (short for **co**der-**dec**oder) is an algorithm used to compress raw, uncompressed video data into a manageable size and then decompress it for playback. Without codecs, a single minute of high-definition video could take up gigabytes of space, making streaming and storage impossible.

This chapter explores the theory of video compression, explains the difference between lossy and lossless codecs, and dives deep into the most common codecs you'll encounter and use with FFmpeg.

## The Theory of Video Compression

Video is essentially a sequence of still images (frames) played back quickly. Uncompressed video is enormous. The goal of a video codec is to reduce this size by cleverly removing redundant information. It does this in two main ways:

1.  **Intra-frame Compression (Spatial Redundancy)**: This is similar to how a JPEG image is compressed. Within a single frame, the codec looks for large areas of similar color or pattern and stores that information more efficiently instead of describing every single pixel.

2.  **Inter-frame Compression (Temporal Redundancy)**: This is where the real magic happens. Video often doesn't change much from one frame to the next. Instead of storing each frame as a complete, new image, the codec can store one full frame (called an **I-frame** or keyframe) and then, for the subsequent frames (**P-frames** and **B-frames**), it only stores the *differences* from the previous or upcoming frames. For example, in a scene of a person talking, most of the background remains static. The codec only needs to encode the movement of their lips and face, saving a massive amount of data.

## Lossy vs. Lossless Compression

Codecs can be categorized into two main types:

*   **Lossless**: These codecs compress video data without discarding any information. When the video is decompressed, it is a perfect, bit-for-bit identical copy of the original. This is ideal for archiving or for intermediate files in a professional workflow where you need to perform multiple edits and re-encodes without degrading quality. However, the file sizes are still very large. Examples: **FFV1**, **HuffYUV**.

*   **Lossy**: These codecs achieve much higher compression ratios by permanently discarding information that the human eye is less likely to notice. Virtually all video you watch online or on TV uses lossy compression. The goal is to find the perfect balance between file size and perceptual quality. At high enough quality settings, the difference from the original can be virtually indistinguishable. Examples: **H.264**, **H.265**, **VP9**, **AV1**.

## A Deep Dive into Common Codecs

Let's explore the codecs you will use most often in FFmpeg.

### H.264 (libx264) - The Workhorse

H.264, also known as AVC (Advanced Video Coding), is the undisputed king of video codecs. It has been the dominant standard for over a decade, used for everything from Blu-ray Discs to YouTube streaming.

*   **FFmpeg Encoder**: `libx264`
*   **Pros**: Universal compatibility, excellent quality-to-size ratio, fast encoding on modern hardware.
*   **Cons**: Less efficient than newer codecs at the same quality level.
*   **Key Option: `-crf` (Constant Rate Factor)**: This is the most important setting for `libx264`. It controls the quality, where a lower number means higher quality and a larger file size.
    *   `~18`: Visually lossless. Use for high-quality masters.
    *   `~23`: The default. An excellent balance for general use.
    *   `~28`: Lower quality, but smaller file size.
*   **Example**:
    ```bash
    ffmpeg -i input.mp4 -c:v libx264 -crf 23 -c:a aac -b:a 128k output_h264.mp4
    ```

### H.265 / HEVC (libx265) - The Successor

H.265, or HEVC (High Efficiency Video Coding), is the successor to H.264. It offers significantly better compression, meaning it can deliver the same quality as H.264 at roughly half the file size. This makes it ideal for 4K and HDR content.

*   **FFmpeg Encoder**: `libx265`
*   **Pros**: High efficiency, great for 4K/UHD and HDR content.
*   **Cons**: Slower to encode than `libx264`, not as universally compatible with older devices.
*   **Key Option: `-crf`**: Similar to `libx264`, but the scale is slightly different. A `libx265` CRF of `28` is roughly equivalent to a `libx264` CRF of `23`.
*   **Example**:
    ```bash
    ffmpeg -i input.mp4 -c:v libx265 -crf 28 -c:a aac -b:a 128k output_h265.mp4
    ```

### VP9 (libvpx-vp9) - The Open Standard

VP9 is an open and royalty-free codec developed by Google. It's the primary codec used by YouTube for high-resolution video. It's a direct competitor to H.265, offering similar compression efficiency.

*   **FFmpeg Encoder**: `libvpx-vp9`
*   **Pros**: Royalty-free, excellent compression comparable to H.265, well-supported in web browsers.
*   **Cons**: Can be slower to encode than `libx265`.
*   **Key Option: `-crf`**: Just like the others, but the value is on a different scale (0-63).
    *   `~31`: Recommended for 1080p HD video.
*   **Example** (for a WebM container):
    ```bash
    ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 31 -b:v 0 -c:a libopus -b:a 128k output.webm
    ```
    *Note: For VP9, `-b:v 0` is often recommended when using CRF mode to allow the encoder to better manage bitrate.*

### AV1 (libaom-av1) - The Future

AV1 is the next-generation, royalty-free codec developed by the Alliance for Open Media (AOMedia), which includes Google, Netflix, Amazon, and others. It aims to be 20-30% more efficient than H.265 and VP9.

*   **FFmpeg Encoder**: `libaom-av1`
*   **Pros**: The best compression efficiency available today, royalty-free.
*   **Cons**: Extremely slow to encode, requiring significant computational power. Hardware support is still emerging.
*   **Key Option: `-crf`**: Range is 0-63.
    *   `~35`: A good starting point for 1080p.
*   **Example**:
    ```bash
    ffmpeg -i input.mp4 -c:v libaom-av1 -crf 35 -b:v 0 -c:a libopus output_av1.mkv
    ```
    *AV1 is currently best suited for MKV or WebM containers.*

### Professional / Intermediate Codecs (ProRes, DNxHD)

When you're in the middle of an editing project, you want to avoid repeated lossy compression. This is where intermediate codecs shine. They are "visually lossless" or have very light compression, designed to withstand multiple re-encodes with minimal quality degradation.

*   **ProRes**: Apple's popular intermediate codec. Very common in editing workflows.
    *   **FFmpeg Encoder**: `prores_ks`
    *   **Key Option: `-profile:v`**: Controls the flavor of ProRes.
        *   `0`: Proxy, `1`: LT, `2`: Standard, `3`: HQ.
    *   **Example**:
        ```bash
        ffmpeg -i input.mp4 -c:v prores_ks -profile:v 3 output.mov
        ```
*   **DNxHD/DNxHR**: Avid's competing intermediate codec, often used in PC-based workflows.
    *   **FFmpeg Encoder**: `dnxhd` (for HD) or `dnxhr` (for >HD resolutions).
    *   **Key Option: `-b:v`**: Profile is selected by setting a specific bitrate (e.g., `dnxhr_hq` for high quality).
    *   **Example**:
        ```bash
        ffmpeg -i input.mp4 -c:v dnxhd -b:v 110M output.mov
        ```

## Bitrate vs. CRF: Which to Use?

FFmpeg gives you two main ways to control quality and file size:

1.  **Constant Rate Factor (`-crf`)**: This is the **recommended method** for most use cases. You tell the encoder to maintain a certain *quality level* throughout the video. The encoder will use more bits for complex, high-motion scenes and fewer bits for simple, static scenes. You get consistent quality with an unpredictable file size.

2.  **Average Bitrate (`-b:v`)**: You specify a target file size (e.g., 2 Megabits per second). The encoder tries to meet this average, which can result in quality fluctuations. Complex scenes might look worse (starved for bits), while simple scenes might waste bits. This is useful when you have a strict file size requirement (e.g., for streaming with a bandwidth limit). For best results with bitrate, use two-pass encoding.

**General Rule**: Use CRF unless you have a specific reason to target a certain file size.

## Conclusion

You've now unlocked the secrets of video codecs. You understand how compression works, the trade-offs between lossy and lossless, and you have a practical guide to the most important codecs in the FFmpeg universe. You can now make informed decisions about which codec to use for delivery, editing, and archiving, and you know how to control the quality and file size of your output. Next, we'll give the same treatment to the other half of your media file: the audio codecs.
