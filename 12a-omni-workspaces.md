---
title: "Managing Workspaces on OMNI"
teaching: 20
exercises: 10
---

::::::::::::::::::::::::::::::::::::::: objectives

- Explain when to use home directories, `/work`, and `/fast` on OMNI.
- Create, locate, list, and extend a temporary workspace.
- Organize input files and job output in a workspace.
- Recognize workspace expiration and avoid losing results.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- Where should I store input data and results for an OMNI job?
- How do I create and manage a workspace?
- What happens when my workspace expires?

::::::::::::::::::::::::::::::::::::::::::::::::::

On OMNI, a **workspace** is a temporary directory for computational data.
Unlike your home directory, it is intended for larger job inputs and outputs.
Workspaces **expire**, so they are not a substitute for long-term storage or
backups.

## Choose the right storage location

| Location | Best for | Important limitations |
| :------- | :------- | :-------------------- |
| `~` (home) | Scripts, configuration, small persistent files | Per-user storage limit (currently 100 GB) |
| `/work` | Working datasets and most Slurm job input/output | Workspace lifetime is limited; no automatic backup |
| `/fast` | Workloads that specifically benefit from the faster workspace filesystem | Limited shared capacity; use only when needed; no automatic backup |
| `/tmp` on a compute node | Temporary files needed by one job on that node | Node-local, not shared between nodes; do not rely on persistence |

OMNI workspaces on `/work` use the **`work`** filesystem by default. The
`fast` filesystem is an optional performance-oriented alternative. Follow the
HPC team's current guidance about which workloads benefit from `/fast`.

::::::::::::::::::::::::::::::::::::::::: caution

## A workspace is temporary, not a backup

The maximum initial workspace lifetime is **30 days**. It can be extended up
to **three times**, for at most 30 days per extension. OMNI does **not** make
automatic backups of workspace data. Copy important results to appropriate
long-term storage **before** the workspace expires.

::::::::::::::::::::::::::::::::::::::::::::::::::

## 1. Create a workspace

Run the following commands **after logging in to OMNI**, not on your laptop.
For this lesson, we will use a workspace named `hpc-training` lasting **2 days**:

```bash
ws_allocate hpc-training 2
```

The command reports the workspace path and remaining lifetime. For example,
for a user named `demo_user`, the path is:

```output
/work/ws-tmp/demo_user-hpc-training
```

Your actual username and output will differ. The general command is:

```bash
ws_allocate <workspace-name> <duration-in-days>
```

**Always specify the duration.** Omitting it creates a workspace for only
**one day**. Choose a different name if you already have a workspace called
`hpc-training`.

To enter your workspace, replace the path below with the actual path printed
by `ws_allocate`:

```bash
cd /work/ws-tmp/$USER-hpc-training
pwd
```

If the username in your path differs from `$USER`, use the printed path
instead. A workspace is a normal directory once it has been allocated.

## 2. List your workspaces and available filesystems

```bash
ws_list
ws_list -l
```

`ws_list` displays your workspaces. The `-l` option lists available
filesystems, including `work` (default) and `fast`.

For command-specific options, read the on-cluster manual:

```bash
man ws_allocate
man ws_extend
```

## 3. Organize input, output, and scripts

Make some directories and a small text file in your training workspace:

```bash
cd /work/ws-tmp/$USER-hpc-training
mkdir -p input output scripts
printf 'OMNI workspace practice\n' > input/readme.txt
ls -lah
cat input/readme.txt
```

Keep track of which workspace a job should use. For example, a small Slurm
batch script could look like this:

```bash
#!/bin/bash
#SBATCH --job-name=workspace-demo
#SBATCH --time=00:02:00
#SBATCH --ntasks=1
#SBATCH --output=output/slurm-%j.out

set -e
cat input/readme.txt
hostname
```

Save it as `scripts/demo.sh` **inside your workspace**. Then submit from the
workspace root, where the relative `input/` and `output/` paths exist:

```bash
cd /work/ws-tmp/$USER-hpc-training
sbatch scripts/demo.sh
squeue -u "$USER"
```

When the job completes, inspect the output in `output/`. `sbatch` returns a
job ID, which you can use to identify `output/slurm-<job-id>.out`. The
scheduler episode explains these commands in detail.

::::::::::::::::::::::::::::::::::::::::: tip

## Use full paths in production jobs

The example deliberately submits a job from the workspace directory. In your
own batch scripts, prefer explicit paths or set the job working directory
carefully, so files do not accidentally end up in your home directory.

::::::::::::::::::::::::::::::::::::::::::::::::::

## 4. Extend a workspace before it expires

To extend the workspace, use:

```bash
ws_extend hpc-training 7
ws_list
```

This requests an extension of **7 days** and consumes one of the allowed
extensions. Do this **only when you actually need more time**; you can skip
this command during training. Each extension is limited to 30 days, and the
number of extensions is limited to three.

For a workspace created on the optional `fast` filesystem, use the same
filesystem on extension:

```bash
ws_allocate -F fast my-fast-workspace 2
ws_extend -F fast my-fast-workspace 7
```

Do not allocate a `/fast` workspace unless your workload needs it.

## 5. Expiration, release, and recovery

When finished, copy results you need to retain to approved long-term storage.
Then you may release a workspace:

```bash
ws_release hpc-training
```

**Do not run this command during the practice exercise.** Releasing a
workspace makes its files inaccessible immediately.

If a workspace has expired or was released accidentally, OMNI normally
retains it for **up to 10 days** before permanent deletion. Recovery may be
possible, but is **not guaranteed**:

```bash
ws_restore -l
ws_allocate recovered-data 2
ws_restore <full-expired-workspace-id> recovered-data
```

The full expired ID comes from `ws_restore -l`; it includes your username and
a numeric identifier. Follow any interactive confirmation that appears. The
restored content will appear in a subdirectory of the new workspace.

::::::::::::::::::::::::::::::::::::::::: challenge

## Practice: Check your workspace

1. Create a workspace named `hpc-training` for two days (or choose a unique
   name if you already used that name).
2. Use `ws_list` to check that it exists.
3. Enter its directory and create subdirectories `input` and `output`.
4. Create `input/readme.txt` containing one line of text.
5. Check your current directory and list its contents.
6. **Discuss**, without executing: What happens if the workspace expires?

:::: solution

## Example solution

```bash
ws_allocate hpc-training 2
ws_list
cd /work/ws-tmp/$USER-hpc-training
mkdir -p input output
printf 'Hello from OMNI\n' > input/readme.txt
pwd
ls -lah
cat input/readme.txt
```

When a workspace expires, it becomes inaccessible; retained data may be
recoverable for a limited period. Save important results elsewhere before
expiration. If you used a different workspace name, adjust the path above.

::::

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::: keypoints

- Use `/work` workspaces for most computational inputs and outputs on OMNI.
- Create workspaces with `ws_allocate NAME DAYS`; check them with `ws_list`.
- The default filesystem is `work`; specify `-F fast` only when needed.
- Workspaces expire and are not automatically backed up.
- Extend proactively with `ws_extend`, and use `ws_release` only when finished.

::::::::::::::::::::::::::::::::::::::::::::::::::

Further reading: [University of Siegen HPC file systems](https://www.uni-siegen.de/en/hpc-file-systems).
