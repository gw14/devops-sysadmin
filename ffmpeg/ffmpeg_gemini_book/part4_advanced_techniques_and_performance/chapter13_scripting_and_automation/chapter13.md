# Chapter 13: Scripting and Automation

You have become a proficient wielder of FFmpeg, capable of crafting complex commands to achieve specific results. But the true power of a command-line tool is unlocked when you make it do the work for you—not just once, but hundreds or thousands of times. This is the domain of **scripting and automation**.

By wrapping your FFmpeg commands in simple scripts, you can create powerful, reusable tools for your specific needs. This chapter will introduce the basics of scripting FFmpeg using Bash (for Linux/macOS) and PowerShell (for Windows) to batch process entire folders of files.

## Why Automate?

Imagine you have a folder of 100 videos from a camera, and you need to convert all of them to a web-friendly MP4 format, scaled to 1080p. You could type out the `ffmpeg` command 100 times, changing the input and output filename each time. Or you could write a simple 3-line script that does it for you automatically while you get a coffee.

Automation helps you:
*   **Save time**: Drastically reduces manual, repetitive work.
*   **Ensure consistency**: Every file is processed with the exact same settings.
*   **Reduce errors**: Eliminates typos and mistakes from re-typing commands.
*   **Create reusable tools**: Build a library of scripts for your common tasks.

## Scripting in Bash (Linux and macOS)

Bash is the default shell for most Linux distributions and macOS. The core of batch processing is the `for` loop, which allows you to iterate over a list of files.

### Your First Batch Script: Converting Files

Let's tackle the problem of converting a folder of `.mov` files to `.mp4`.

1.  Create a new text file named `convert.sh`.
2.  Put the following code inside:

```bash
#!/bin/bash

# A simple script to convert .mov files to .mp4 using libx264

# Create an 'output' directory if it doesn't exist
mkdir -p output

# Loop through all .mov files in the current directory
for file in *.mov; do
  # The ffmpeg command
  # "$file" is the input filename (e.g., "video1.mov")
  # "output/${file%.mov}.mp4" is the new output filename (e.g., "output/video1.mp4")
  ffmpeg -i "$file" -c:v libx264 -crf 23 -c:a aac -b:a 192k "output/${file%.mov}.mp4"
done

echo "All files converted!"
```

3.  Save the file.
4.  Open your terminal, navigate to the folder containing your `.mov` files and the script.
5.  Make the script executable: `chmod +x convert.sh`
6.  Run the script: `./convert.sh`

The script will create an `output` directory and, one by one, convert every `.mov` file into an `.mp4` file inside it.

**Script Breakdown**:
*   `#!/bin/bash`: This "shebang" tells the system to execute the script using Bash.
*   `for file in *.mov; do ... done`: This is the loop. `*.mov` is a glob pattern that expands to a list of all files ending in `.mov`. The loop takes each filename and assigns it to the variable `file`.
*   `"$file"`: We use double quotes around the variable to handle filenames that might contain spaces.
*   `${file%.mov}`: This is a Bash parameter expansion trick. It takes the `file` variable and removes the `.mov` suffix from the end. We then add `.mp4` to create the new filename.

### Adding Flexibility with Arguments

You can make your scripts more flexible by accepting command-line arguments. Let's modify our script to accept a quality (CRF) setting.

```bash
#!/bin/bash

# CRF value is the first argument, default to 23 if not provided
CRF=${1:-23}

mkdir -p "output_crf${CRF}"

for file in *.mov; do
  ffmpeg -i "$file" -c:v libx264 -crf "$CRF" -c:a aac -b:a 192k "output_crf${CRF}/${file%.mov}.mp4"
done

echo "Conversion finished with CRF $CRF!"
```

Now you can run the script like this:
*   `./convert.sh`: Uses the default CRF of 23.
*   `./convert.sh 18`: Runs the conversion with a high-quality CRF of 18.

## Scripting in PowerShell (Windows)

PowerShell is the modern command-line shell for Windows. It has similar capabilities to Bash.

### Your First Batch Script: Converting Files

1.  Create a new text file named `convert.ps1`.
2.  Put the following code inside:

```powershell
# A simple script to convert .mov files to .mp4 using libx264

# Create an 'output' directory if it doesn't exist
if (-not (Test-Path -Path "output")) {
  New-Item -ItemType Directory -Path "output"
}

# Get a list of all .mov files in the current directory
$files = Get-ChildItem -Filter *.mov

# Loop through the files
foreach ($file in $files) {
  # The ffmpeg command
  # $file.Name is the input filename (e.g., "video1.mov")
  # Join-Path combines the output dir and the new filename
  $outputFile = Join-Path "output" ($file.BaseName + ".mp4")
  
  ffmpeg -i $file.Name -c:v libx264 -crf 23 -c:a aac -b:a 192k $outputFile
}

Write-Output "All files converted!"
```

3.  Save the file.
4.  Open a PowerShell terminal, navigate to your folder.
5.  **Execution Policy**: By default, PowerShell may prevent you from running scripts. You might need to change the execution policy for the current session by running: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`.
6.  Run the script: `.\convert.ps1`

**Script Breakdown**:
*   `Get-ChildItem -Filter *.mov`: This command gets a list of all files matching the filter.
*   `foreach ($file in $files) { ... }`: The PowerShell loop structure.
*   `$file.Name`: The full filename (e.g., `video1.mov`).
*   `$file.BaseName`: The filename without the extension (e.g., `video1`).

## Tips for Robust Scripting

*   **Error Handling**: What happens if an FFmpeg command fails? By default, the script might just continue. In Bash, you can add `set -e` to the top of your script, which will cause it to exit immediately if any command fails.
    ```bash
    #!/bin/bash
    set -e
    ...
    ```
*   **Logging**: You can redirect FFmpeg's output to a log file to review it later.
    ```bash
    # Append FFmpeg's standard error output to a log file
    ffmpeg -i "$file" ... "output/${file%.mov}.mp4" 2>> conversion.log
    ```
*   **Dry Runs**: Before running a script that modifies or creates many files, it's a good idea to do a "dry run." You can comment out the `ffmpeg` command and replace it with an `echo` command to simply print what the script *would* do.
    ```bash
    # echo ffmpeg -i "$file" ... "output/${file%.mov}.mp4"
    ```

## Conclusion

Scripting is the bridge from being an FFmpeg user to being an FFmpeg power user. By combining the logic of shell scripting with the power of FFmpeg, you can build automated workflows that save you vast amounts of time and effort. You can now batch process entire directories of files, create reusable tools, and ensure every file is processed with perfect consistency. In the next chapter, we will explore another advanced application of FFmpeg: preparing and delivering media for live streaming.
