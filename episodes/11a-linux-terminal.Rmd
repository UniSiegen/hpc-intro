---
title: Essential Linux Terminal Commands
teaching: 30
exercises: 15
---

::::::::::::::::::::::::::::::::::::::: objectives

- Navigate the Linux filesystem from a terminal.
- Create, inspect, copy, move, and remove files and directories.
- Search text, inspect command output, and use pipes and redirection.
- Check processes, storage usage, and file permissions.
- Use terminal commands safely on a shared HPC system.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- Which Linux commands will I use most often on an HPC cluster?
- How can I find files, inspect output, and troubleshoot problems?
- Which commands require extra care on shared systems?

::::::::::::::::::::::::::::::::::::::::::::::::::

After connecting to the cluster via SSH, you will usually work in a **shell**,
which accepts commands typed into a terminal. This episode introduces the
commands you need for the rest of the course. The examples use **Bash**, a
commonly used Linux shell.

A command typically consists of a name followed by options and arguments:

```bash
ls -lh my_directory
```

Here, `ls` is the command, `-lh` contains options, and `my_directory` is the
argument. Press **Enter** to run a command. Use the **Up arrow** to recall an
earlier command and **Tab** to complete a filename or command.

:::::::::::::::::::::::::::::::::::::::::  tip

## Ask Linux for help

Try `man ls` for a manual page, `ls --help` for a brief help message, or
`help cd` for help on the Bash built-in command `cd`. Press `q` to leave a
manual page. Not every command supports `--help`.

::::::::::::::::::::::::::::::::::::::::::::::::::

## 1. Where am I? Navigating directories

Linux files and folders form a directory tree rooted at `/`. Your personal
home directory is abbreviated as `~`. A **relative path** starts from your
current directory, while an **absolute path** starts at `/`.

| Command | What it does | Example |
| :------ | :----------- | :------ |
| `pwd` | Print the current directory | `pwd` |
| `ls` | List files and directories | `ls` |
| `ls -lah` | List details, sizes, and hidden files | `ls -lah` |
| `cd` | Go to your home directory | `cd` |
| `cd DIR` | Change into directory `DIR` | `cd projects` |
| `cd ..` | Go to the parent directory | `cd ..` |
| `cd -` | Return to the previous directory | `cd -` |
| `cd ~` | Return to your home directory | `cd ~` |

For example:

```bash
pwd
ls -lah
cd ~
```

The special directory `.` means *here*, and `..` means *one level up*.
Names beginning with `.` are normally hidden from a plain `ls` listing.

## 2. Create, copy, move, and remove files

The following practice commands work in a directory under your home folder.
Use a unique name if `linux-practice` already exists.

```bash
mkdir ~/linux-practice
cd ~/linux-practice
mkdir results
printf 'First HPC run\n' > notes.txt
cp notes.txt notes-backup.txt
mv notes-backup.txt results/notes-backup.txt
ls -lah results
```

| Command | What it does | Example |
| :------ | :----------- | :------ |
| `mkdir DIR` | Create a directory | `mkdir results` |
| `mkdir -p A/B` | Create nested directories | `mkdir -p project/data` |
| `touch FILE` | Create an empty file or update its timestamp | `touch output.txt` |
| `cp SOURCE DEST` | Copy a file | `cp input.txt input.bak` |
| `cp -r DIR DEST` | Copy a directory recursively | `cp -r results results-copy` |
| `mv SOURCE DEST` | Move or rename a file | `mv old.txt new.txt` |
| `rm FILE` | Permanently remove a file | `rm old.txt` |
| `rmdir DIR` | Remove an **empty** directory | `rmdir empty-dir` |

:::::::::::::::::::::::::::::::::::::::::  caution

## Deletion does not go to a recycle bin

`rm` normally deletes files without a recycle bin. `rm -r` removes directories
and their contents recursively, and `rm -rf` is particularly dangerous.
**Never copy and paste a deletion command without checking the exact path.**
Use `pwd` and `ls` to confirm your location and targets first. Avoid broad
wildcards or recursive deletion when working with shared project data.

::::::::::::::::::::::::::::::::::::::::::::::::::

## 3. Read files and examine results

| Command | What it does | Example |
| :------ | :----------- | :------ |
| `cat FILE` | Print a small text file | `cat notes.txt` |
| `less FILE` | Scroll through a long text file (`q` to quit) | `less job.out` |
| `head -n 10 FILE` | Show the first 10 lines | `head -n 10 data.csv` |
| `tail -n 20 FILE` | Show the last 20 lines | `tail -n 20 job.out` |
| `tail -f FILE` | Follow new lines as a file grows (`Ctrl+C` to stop) | `tail -f job.out` |
| `wc -l FILE` | Count lines | `wc -l data.csv` |
| `file FILE` | Identify the file type | `file result.dat` |

On HPC systems, a job often writes its progress to a log file. `tail` and
`less` are useful for checking this output without opening a graphical editor.

```bash
cat notes.txt
wc -l notes.txt
less notes.txt
```

## 4. Find files and search their contents

| Command | What it does | Example |
| :------ | :----------- | :------ |
| `find DIR -name PATTERN` | Find matching filenames | `find . -name '*.txt'` |
| `grep TEXT FILE` | Print lines containing text | `grep 'ERROR' job.out` |
| `grep -n TEXT FILE` | Show matching line numbers | `grep -n 'ERROR' job.out` |
| `grep -i TEXT FILE` | Search without case sensitivity | `grep -i 'warning' job.out` |
| `grep -r TEXT DIR` | Search recursively within text files | `grep -r 'TODO' scripts/` |
| `which COMMAND` | Show the executable found on `PATH` | `which python` |

Quote wildcard patterns such as `'*.txt'` when passing them to `find`, so the
shell does not expand them before `find` receives them.

```bash
printf 'INFO: starting\nERROR: example failure\n' > sample.log
grep -n 'ERROR' sample.log
find . -name '*.log'
```

For large shared filesystems, avoid searching the entire filesystem (for
example, `find /`) or recursively grepping huge directories. Limit your
search to your own project or job directory.

## 5. Pipes, redirection, and wildcards

A **pipe**, `|`, sends one command's output to another command. Redirection
writes output to a file.

| Symbol | Meaning | Example |
| :----- | :------ | :------ |
| `|` | Send output to another command | `grep ERROR sample.log \| wc -l` |
| `>` | Write output, **overwriting** an existing file | `echo hello > message.txt` |
| `>>` | Append output to a file | `echo again >> message.txt` |
| `*` | Match any number of filename characters | `ls *.txt` |
| `?` | Match one filename character | `ls run?.txt` |

```bash
grep 'ERROR' sample.log | wc -l
printf 'one\n' > numbers.txt
printf 'two\n' >> numbers.txt
cat numbers.txt
```

Be careful: `>` replaces the previous contents of its destination file.

## 6. Processes, resources, and permissions

| Command | What it does | Example |
| :------ | :----------- | :------ |
| `whoami` | Display your username | `whoami` |
| `hostname` | Display the current host | `hostname` |
| `date` | Show the date and time | `date` |
| `ps -u "$USER"` | Show your processes | `ps -u "$USER"` |
| `top` | View running processes (`q` to quit) | `top` |
| `df -h .` | Show filesystem capacity for current location | `df -h .` |
| `du -sh DIR` | Estimate space used by a directory | `du -sh results` |
| `ls -l FILE` | Show file permissions | `ls -l notes.txt` |
| `chmod u+x FILE` | Add execute permission for the owner | `chmod u+x run.sh` |

Linux permissions are usually represented by `r` (read), `w` (write), and
`x` (execute), applied to the file's owner, group, and others. For example,
`chmod u+x run.sh` allows the owner to execute a shell script.

**HPC-specific note:** `top`, `ps`, and `df` describe what is happening on the
machine or filesystem where you run them. From a login node, they do **not**
show your allocated compute-node resources or the full scheduler queue. Use
Slurm commands such as `squeue -u "$USER"`, `sinfo`, and `sacct` for job and
cluster information, as explained in the scheduler episode. Do not run
computationally intensive work on login nodes.

## 7. Useful keyboard shortcuts

| Shortcut | Action |
| :------- | :----- |
| `Tab` | Complete a command or path |
| `Up arrow` | Recall earlier commands |
| `Ctrl+C` | Interrupt a command in the foreground |
| `Ctrl+L` | Clear the terminal display |
| `Ctrl+R` | Search shell command history |
| `Ctrl+D` | End terminal input or log out of the shell |

`Ctrl+C` interrupts the **foreground command in that terminal**. It does not
normally cancel a Slurm job submitted with `sbatch`. To cancel such a job,
use `scancel JOB_ID` only for a job you own.

:::::::::::::::::::::::::::::::::::::::: challenge

## Exercise: Explore and organize your files

In your `~/linux-practice` directory:

1. Print your current directory and list the files with details.
2. Make a directory called `logs`.
3. Copy `sample.log` into `logs`.
4. Show the last line of the copied log and count the lines containing `ERROR`.
5. Find all `.log` files under the current directory.

:::::::::::::::::::::::::::::::::::::::: solution

## Example solution

```bash
cd ~/linux-practice
pwd
ls -lah
mkdir logs
cp sample.log logs/
tail -n 1 logs/sample.log
grep 'ERROR' logs/sample.log | wc -l
find . -name '*.log'
```

The error count should be `1` if you used the example `sample.log` above.

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

## Exercise: Read an HPC job log

Suppose you have a job output file named `slurm-12345.out` in your project
folder. Which commands would you use to:

1. Read only the last 20 lines?
2. Search for `error` regardless of capitalization, showing line numbers?
3. Follow new output while the file is being written?

:::::::::::::::::::::::::::::::::::::::: solution

## Example solution

```bash
tail -n 20 slurm-12345.out
grep -in 'error' slurm-12345.out
tail -f slurm-12345.out
```

Use `Ctrl+C` to stop following the file. The filename is illustrative: use
the actual output filename for your job.

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::  keypoints

- `pwd`, `ls`, and `cd` help you navigate the filesystem.
- `mkdir`, `cp`, and `mv` organize files; `rm` permanently deletes them.
- `less`, `head`, `tail`, `grep`, and `find` help inspect job outputs and data.
- Pipes and redirection combine commands, but `>` overwrites existing files.
- Use Slurm rather than login-node process tools to check scheduled HPC jobs.
- Read commands and file paths carefully before modifying or removing data.

::::::::::::::::::::::::::::::::::::::::::::::::::
