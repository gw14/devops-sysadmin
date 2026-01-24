# Chapter 2: Installation and First Steps

Before you can unleash the full power of FFmpeg, you need to get it installed on your system. This chapter will walk you through the installation process for Windows, macOS, and Linux. Once installed, we'll verify that everything is working correctly and then dive straight into your very first practical FFmpeg commands, demonstrating its immediate utility.

## Installing FFmpeg

FFmpeg is a command-line tool, meaning it doesn't have a graphical user interface (GUI) that you install like typical applications. Instead, you'll be working with it directly from your system's terminal or command prompt.

### Installation on Linux

For most Linux distributions, FFmpeg is available through the official package manager, making installation straightforward.

**Debian/Ubuntu-based systems (e.g., Ubuntu, Mint):**

```bash
sudo apt update
sudo apt install ffmpeg
```

**Fedora/CentOS-based systems:**

```bash
sudo dnf install ffmpeg
```

**Arch Linux-based systems:**

```bash
sudo pacman -S ffmpeg
```

### Installation on macOS

On macOS, the recommended way to install FFmpeg is using Homebrew, a popular package manager.

1.  **Install Homebrew (if you haven't already):**
    Open your Terminal application and run:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
    Follow the on-screen instructions.

2.  **Install FFmpeg using Homebrew:**
    ```bash
    brew install ffmpeg
    ```

### Installation on Windows

Installing FFmpeg on Windows typically involves downloading a pre-built executable.

1.  **Download FFmpeg:**
    Go to the official FFmpeg website's download page: [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
    Under the "Windows builds" section, you'll find links to various pre-compiled binaries. A popular choice is from Gyan's builds (e.g., `ffmpeg-git-full.7z`). Download the latest stable build.

2.  **Extract the Archive:**
    FFmpeg comes as a `.7z` archive. You'll need a tool like 7-Zip (free and open-source) to extract its contents. Extract the entire folder to a location you prefer, for example, `C:\Program Files\ffmpeg`.

3.  **Add FFmpeg to your System PATH:**
    For FFmpeg to be accessible from any command prompt, you need to add its `bin` directory to your system's PATH environment variable.
    *   Search for "Environment Variables" in your Windows search bar and select "Edit the system environment variables".
    *   Click the "Environment Variables..." button.
    *   Under "System variables", find and select the `Path` variable, then click "Edit...".
    *   Click "New" and add the path to your FFmpeg `bin` folder (e.g., `C:\Program Files\ffmpeg\bin`).
    *   Click "OK" on all open windows to save the changes.
    *   You may need to restart your command prompt or even your computer for the changes to take effect.

## Verifying the Installation

After installation, it's crucial to verify that FFmpeg is correctly installed and accessible. Open a new terminal or command prompt and run the following command:

```bash
ffmpeg -version
```

You should see output similar to this (versions and build configurations will vary):

```
ffmpeg version N-105151-g22b51234b4 Copyright (c) 2000-2022 FFmpeg developers
built with gcc 11.2.0 (Ubuntu 11.2.0-15ubuntu2)
configuration: --prefix=/usr --extra-version=0ubuntu1 --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu ...
libavutil      57. 17.100 / 57. 17.100
libavcodec     59. 18.100 / 59. 18.100
libavformat    59. 16.100 / 59. 16.100
libavdevice    59.  4.100 / 59.  4.100
libavfilter     8. 24.100 /  8. 24.100
libswscale      6.  4.100 /  6.  4.100
libswresample   4.  3.100 /  4.  3.100
libpostproc    56.  3.100 / 56.  3.100
```

If you see output indicating the FFmpeg version and build configuration, congratulations! FFmpeg is ready to go. If you get a "command not found" error, double-check your installation steps, especially the PATH variable setup for Windows users.

You can also test `ffprobe` and `ffplay`:

```bash
ffprobe -version
ffplay -version
```

These should also return similar version information.

## Your First FFmpeg Commands: Immediate Gratification

Now that FFmpeg is installed, let's perform some basic, yet incredibly useful, operations. For these examples, you'll need a sample video file (e.g., `input.mp4`). If you don't have one, you can download a royalty-free video from sites like Pexels or Pixabay, or simply record a short one with your phone. Place your sample video in the directory where you are running your terminal commands.

### Example 1: Simple Format Conversion (MP4 to MOV)

One of the most common tasks for FFmpeg is converting media from one format to another. Let's convert an MP4 file to a MOV file.

```bash
ffmpeg -i input.mp4 output.mov
```

*   `ffmpeg`: Invokes the FFmpeg program.
*   `-i input.mp4`: Specifies `input.mp4` as the input file.
*   `output.mov`: Specifies `output.mov` as the output file. FFmpeg intelligently infers the output container format from the file extension.

FFmpeg will automatically choose suitable default video and audio codecs for the `.mov` container.

### Example 2: Extracting Audio from a Video

Need just the audio track from a video? FFmpeg makes it trivial.

```bash
ffmpeg -i input.mp4 -vn output.mp3
```

*   `-vn`: This option tells FFmpeg to disable video recording (i.e., don't include video streams in the output).
*   `output.mp3`: The output file. FFmpeg will extract the audio and encode it as MP3 by default.

### Example 3: Resizing a Video

Resizing videos is a frequent requirement, especially for web or mobile optimization. Let's scale a video to a width of 640 pixels, maintaining its aspect ratio.

```bash
ffmpeg -i input.mp4 -vf scale=640:-1 output_640.mp4
```

*   `-vf scale=640:-1`: This is our first encounter with a *video filter*. `-vf` specifies video filters. `scale=640:-1` tells FFmpeg to scale the video to a width of 640 pixels, and `-1` automatically calculates the height to maintain the original aspect ratio.

### Example 4: Trimming a Video (Start at 10s, for 5s Duration)

You often only need a segment of a video. Let's extract a 5-second clip starting from the 10-second mark.

```bash
ffmpeg -ss 00:00:10 -i input.mp4 -t 00:00:05 -c copy output_clip.mp4
```

*   `-ss 00:00:10`: This is an *input option* (placed before `-i`). It tells FFmpeg to seek to the 10-second mark *before* processing the input.
*   `-t 00:00:05`: This is an *output option* (placed before the output file). It tells FFmpeg to limit the output duration to 5 seconds.
*   `-c copy`: This crucial option tells FFmpeg to *copy* the video and audio streams directly without re-encoding them. This makes the operation incredibly fast and lossless.

### Example 5: Creating an Animated GIF from a Video Segment

Animated GIFs are popular for social media and quick demonstrations. Let's create a GIF from a 3-second segment of a video.

```bash
ffmpeg -ss 00:00:05 -i input.mp4 -t 00:00:03 -vf "fps=10,scale=320:-1:flags=lanczos" -loop 0 output.gif
```

This command is a bit more complex, showing a glimpse of FFmpeg's power.
*   `-ss 00:00:05 -i input.mp4 -t 00:00:03`: Extracts a 3-second segment starting from 5 seconds.
*   `-vf "fps=10,scale=320:-1:flags=lanczos"`: This filter chain does two things:
    *   `fps=10`: Sets the frame rate of the output GIF to 10 frames per second.
    *   `scale=320:-1:flags=lanczos`: Scales the video to 320 pixels wide, maintaining aspect ratio. `lanczos` is a high-quality scaling algorithm.
*   `-loop 0`: Tells FFmpeg to make the GIF loop indefinitely.

## Conclusion

You've successfully installed FFmpeg and performed several fundamental operations. You can now convert formats, extract audio, resize videos, trim clips, and even create animated GIFs. This is just the tip of the iceberg, but these foundational skills are essential for everything else we'll cover. In the next chapter, we'll delve deeper into these fundamental operations and explore more advanced manipulations of your media files.
