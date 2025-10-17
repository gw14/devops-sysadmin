Installing Windows using the Command Line Interface (CLI) is an advanced process primarily using the **DiskPart** and **DISM (Deployment Image Servicing and Management)** tools. This method is often performed from the Command Prompt in the Windows Preinstallation Environment (WinPE), which you access by booting from a Windows installation USB/DVD and pressing **Shift+F10**.

***

## Windows CLI Installation Process (UEFI/GPT)

The following steps outline the general process for installing Windows onto a **GPT-partitioned** disk for **UEFI**-based systems. **Use caution, as the `clean` command will wipe all data on the selected disk.**

### Step 1: Access Command Prompt

1.  Boot your computer from the Windows installation media (USB or DVD).
2.  On the initial setup screen, press **Shift + F10** to open the Command Prompt.

### Step 2: Prepare the Disk and Partitions (DiskPart)

Use the **DiskPart** utility to clean the disk and create the necessary partitions (EFI, MSR, and Primary).

| Command | Purpose |
| :--- | :--- |
| `diskpart` | Starts the DiskPart utility. |
| `list disk` | Displays all physical disks. Note the number of the target disk (e.g., Disk 0). |
| `select disk 0` | Selects the target disk (replace `0` with your disk number). |
| `clean` | **Deletes all partitions and data** on the selected disk. |
| `convert gpt` | Converts the disk to the GPT partition style (required for UEFI). |
| `create part efi size=512` | Creates the EFI System Partition (512 MB). |
| `format quick fs=fat32 label="System"` | Formats the EFI partition as FAT32. |
| `assign letter=S` | Assigns a temporary drive letter 'S' to the EFI partition. |
| `create part msr size=16` | Creates the Microsoft Reserved Partition (16 MB). |
| `create part primary` | Creates the main Windows partition using the remaining space. |
| `format quick fs=ntfs label="Windows"` | Formats the primary partition as NTFS. |
| `assign letter=W` | Assigns a temporary drive letter 'W' to the primary partition. |
| `list volume` | Confirms the drive letters assigned. |
| `exit` | Exits DiskPart. |

***

### Step 3: Deploy the Windows Image (DISM)

Use **DISM** to apply the Windows image file (`install.wim` or `install.esd`) from your installation media to the newly created primary partition.

1.  **Find the installation media letter:**
    * Find the drive letter for your USB/DVD installation media (e.g., `D:`).
    * Type `D:` and then `cd sources`.

2.  **Identify the Windows SKU index:**
    * Run `dism /Get-ImageInfo /ImageFile:install.wim` (or `install.esd`) to view the indexes for different Windows editions (Home, Pro, etc.). Note the **Index Number** you wish to install (e.g., `6` for Windows Pro).

3.  **Apply the Windows image:**
    * Run the command to deploy the image to your primary partition (e.g., `W:`):
        `dism /apply-image /imagefile:install.wim /index:6 /applydir:W:\`
        *(Replace `install.wim` with `install.esd` if applicable, and replace `6` and `W:` with your specific index and partition letter).*

***

### Step 4: Create Boot Files (BCDBoot)

Use **BCDBoot** to create the system boot files on the EFI partition and configure the Boot Configuration Data (BCD).

* Run the command:
    `bcdboot W:\Windows /s S: /f ALL`
    *(This copies the boot files from the Windows directory on partition `W:` to the EFI partition `S:` and creates the BCD store).*

***

### Step 5: Finalize and Reboot

1.  Type `exit` to close the Command Prompt.
2.  Close the Windows Setup window. The system should automatically reboot, or you may be prompted to do so.
3.  Remove the installation media and the computer will boot into the initial Windows setup phase (OOBE - Out-of-Box Experience).

This video shows a full Windows installation using DISM and DiskPart from the command line: [Install Windows 11 On ANY Unsupported PC Using Command Prompt](https://www.youtube.com/watch?v=3BWVxDGtLw4).
