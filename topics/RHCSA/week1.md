That's a great request! Focusing on Week 1 is the perfect starting point.
Here is a detailed, day-by-day study plan for Week 1: Linux Fundamentals & Command Line Basics, including specific lab exercises and practice advice, building upon the course outline.
🗓️ Week 1: Day-by-Day Study Plan & Labs
Objective: Master essential Linux commands, filesystem navigation, permissions, and basic text processing.
| Day | Topic Focus | Study/Lecture Time (1.5 hrs) | Hands-on Lab Exercise (1.5 hrs) | Practice/Review (30 min) |
|---|---|---|---|---|
| Day 1 | Filesystem Hierarchy & Basic Navigation | Review /, /home, /etc, /var, /usr hierarchy. Learn ls, cd, pwd, man, info, and whatis. | Lab 1.1: Filesystem Tour. Navigate to all major directories. Use ls -l and ls -a. Create a directory structure in /tmp using one mkdir command with the -p option. | Review man pages for ls and cd. |
| Day 2 | File Creation, Viewing, and Manipulation | Learn cat, echo, touch, cp, mv, rm, rmdir, and using wildcards (*, ?). Learn file content viewing (less, more, head, tail). | Lab 1.2: File Management Challenge. Create, copy, rename, and delete various files. Use head and tail to view the first/last 10 lines of a log file in /var/log. | Practice using wildcards to delete multiple files with specific patterns (e.g., rm *log). |
| Day 3 | File Permissions: Octal & Symbolic | Understand the three permission sets (User, Group, Other) and the read/write/execute flags. Master the symbolic (u+w, o-r) and octal (755) methods of chmod. | Lab 1.3: Permission Setting. Create a file. Set read/write access for yourself and read-only for the group and others (644). Change it using symbolic notation to remove read access for others (o-r). | Convert octal to symbolic and back for various combinations (e.g., 770, 754, 500). |
| Day 4 | Ownership & Special Permissions | Learn chown (user ownership) and chgrp (group ownership). Understand the default file creation mask (umask). Introduction to SUID/SGID/Sticky bit. | Lab 1.4: Ownership & Mask. Create a file and a group (groupadd). Change the file's ownership to another user and the group to the new group. Check the default umask and test its effect. | Practice creating files and immediately setting a different owner/group. |
| Day 5 | Redirection & Pipes | Master standard input/output/error (0, 1, 2). Learn redirection operators (>, >>, ` | , 2>, &>). Understand the concept and use of pipes ( | `). |
| Day 6 | Text Processing Essentials (grep, cut, sort) | Learn filtering with grep (search patterns). Learn column extraction with cut. Learn sorting with sort and removing duplicates with uniq. | Lab 1.6: Log Filtering. Use grep to find all lines containing "error" in /var/log/messages. Use cut to extract only the usernames from the /etc/passwd file. Sort the output alphabetically. | Use grep with the -v option to exclude lines containing a specific pattern. |
| Day 7 | Review & Practice Exam Simulation | Review all commands and concepts from the week. Re-read the RHCSA objectives for Week 1. | Lab 1.7: Week 1 Integration. A single, continuous lab combining navigation, permissions, file creation, and filtering. (See Lab Exercise 1.7 below). | Final self-assessment. Identify 3 weakest commands/concepts and practice them specifically. |
📝 Detailed Lab Exercises (Week 1)
Lab Exercise 1.7: Week 1 Integration (Day 7 Simulation)
You must complete all the steps below from your home directory (~).
 * Preparation:
   * Create a directory named RHCSA_W1.
   * Navigate into the RHCSA_W1 directory.
   * Create 5 empty files named data-01.txt, data-02.log, data-03.tmp, data-04.log, and master-data.csv.
 * Permissions and Ownership:
   * Set the permissions on the data-01.txt file so that only the owner can read and write to it, and no one else has any access (Octal notation).
   * Set the permissions on the data-02.log file so that the owner has all rights (rwx), the group has read and execute (r-x), and others have only execute (--x) (Symbolic notation).
   * Create a test group named reports (groupadd reports).
   * Change the group ownership of the master-data.csv file to the new reports group.
 * Redirection and Manipulation:
   * Use the echo command to write the text "START OF REPORT" into data-02.log.
   * Use the ls -l command on the current directory and append its output (list of files) to the data-02.log file.
   * Use the echo command to write the text "END OF REPORT" into data-02.log.
 * Pipes and Filtering:
   * Use cat to view the /etc/passwd file.
   * Pipe the output (|) to the cut command to extract only the usernames (the first field, assuming colon : delimiter).
   * Pipe the output again (|) to the grep command to find any line that contains the letter "root".
   * Redirect the final output to a new file called user-filter.txt.
 * Clean Up:
   * Navigate back to your home directory (~).
   * Remove the entire RHCSA_W1 directory and its contents with a single command.
💡 What Do I Need to Practice?
The single most important resource you need is a Red Hat Enterprise Linux 9 Virtual Machine (VM). The RHCSA exam is performance-based, meaning you must execute the commands correctly.
Required Setup:
 * Virtualization Software: Install a hypervisor like VirtualBox or VMware Workstation/Fusion.
 * RHEL 9 Image: Download the Red Hat Enterprise Linux 9 ISO. You can get a free Developer Subscription from Red Hat, which grants you access to official RHEL ISOs and licenses for development use.
 * Installation: Install RHEL 9 into a VM. Use the Server with GUI option during installation initially, but force yourself to use the Command Line Interface (CLI) as much as possible, as the exam is CLI-based.
Practice Methodology:
 * Muscle Memory: Every command (e.g., chmod 755, ls -l, grep pattern file) must be practiced until it becomes automatic.
 * The Man Pages: Get comfortable using man (e.g., man ls, man grep). The exam environment will provide man pages, and you must rely on them for syntax help.
 * Don't Memorize Output: Focus on how the commands work and how to find the syntax (via man or --help), not on memorizing the output of every single command.
 * Verify Everything: After every lab step, verify that your command worked as intended (e.g., after chmod, run ls -l to check the permissions).
