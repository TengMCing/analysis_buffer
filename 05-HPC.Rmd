# HPC (M3) Documentation

This is a chapter for documenting the use of HPC in terms of folder structure, model setup, tasks submission, etc.

## Help and Support

Encounter network issues? Check the system stauts on https://monasheresearch.statuspage.io/. 

Send email to help@massive.org.au with 

- Commands
- Simple reproducible example
- Full path to `slurm` script and input files
- Software used
- Error messages

## Nodes for Job Submission

- K80
- T4
- P100
- V100
- A40
- DGX1

## Remote Desktop

- P4: 60
- T4: 32
- Dual T4: 16
- K80: 26
- A40: 16

## Connection Methods

### ssh

```
ssh -l username m3.massive.org.au
```

### X11 port forwarding

Trusted X11 forwarding

```
ssh -l username m3.massive.org.au -Y
```

Enables X11 forwarding

```
ssh -l username m3.massive.org.au -X
```

## Remote Desktop

- Strudel Web (http://desktop.massive.org.au/)
- Strudel2 (https://beta.desktop.cvl.org.au/login)

Great for setting up the environment interactively.

### Change the Size of the Desktop

- Use `xrandr -s "1920 * 1080"` in the desktop terminal.
- Use TurboVNC (`ctl-cmd-shift-o`?), under "Connection Option"

### Connection Speed

- Use "WAN" options under "Encoding method" of TurboVNC

### Others

The remote machine may have copy and paste keys different from your local machine.

### Jupyter Lab

- Disable pop-up blocker
- Install user site package `pip install --user pkg_name`
- Or `!pip install --user pkg_name`
- Or create a conda env/venv
- `pip list installed`

### Login Node VS. Compute Node

Login node is for editing scripts and submitting jobs.

### Use Miniconda

https://docs.massive.org.au/M3/software/pythonandconda/python-miniconda.html#python-miniconda

```
module load conda-install

# Install miniconda to default space (/scratch/nq46/username/miniconda)
conda-install

# Activate env
source /scratch/nq46/username/miniconda/bin/activate

# Create env (Note that there is an environment called jupyterlab that can be used)
conda create --name myenv -f myenv.yml

conda activate myenv
```

```
conda install pkg_name=ver_num

conda update pkg_name=ver_num
```

#### Add New Env to JupyterLab

```
add-strudel2-conda /path/to/miniconda/ newJupyterEnv
```

### VS Code Connection

https://docs.massive.org.au/M3/connecting/strudel2/connecting-to-vscode.html

## Useful commands

`user_info`

## File systems

