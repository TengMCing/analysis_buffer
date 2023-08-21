# HPC status

## Workflow

This section records the setup of the remote machine.

### Project folder 

Create personal folder and clone the github repo.

```bash
cd sk54
mkdir patrickli
git clone https://github.com/TengMCing/automatic_visual_inference.git
```

### `Tensorflow`

Please make sure the terminal is fresh new and **no modules** have been loaded.

1. Install `miniconda`

We install the miniconda with the module `conda-install`.

```bash
cd ~
module load conda-install
conda-install
```

2. Init `conda`

Init the `conda` command. This will modify the `~/.bashrc` file.

```bash
sk54_scratch/wlii0039/miniconda/bin/conda init
```

Source the `~/.bashrc` to load the `conda` command.

```bash
source ~/.bashrc
```

3. Create `conda` environment

We use the latest version of `Python`.

```bash
conda create --name tf python=3.11
```

Check if the GPU driver is available and the version is greater or equal to `450.80.82`. You need to run this step using a GPU node (e.g. M3 desktop with T4 GPU). 

```bash
nvidia-smi
```

4. Install `cudatoolkit`

We first need to activate the conda environment. All the following steps require an activated environment.

```bash
conda activate tf
```

You may notice that the system has several available `cuda` runtime API. We can check this by running the following command.

```bash
module avil cuda
```

However, these `cuda` runtime APIs are not guaranteed to work with the desired `tensorflow` version as they may not have been tested by the `tensorflow` team (see https://www.tensorflow.org/install/source#linux for tested build configuration). Ideally, we want to use our own runtime API.

This can be done by installing the desired version of `cudatoolkit` via `conda`. We specify the channel to be `conda-forge` since the package is available on that channel. And we want version `11.8.0` because `tensorflow-2.12` works nicely with this version. 

```bash
conda install -c conda-forge cudatoolkit=11.8.0
```

5. Install `cudnn`

Install `cudnn` via `pip` for training neural networks with GPUs. Version `8.6.0.163` has been tested by the `tensorflow` team so we use it.

```bash
pip install nvidia-cudnn-cu11==8.6.0.163
```

Since we are using our own `cuda` runtime API and `cudnn` API, we need to tell the program where to find the dynamic libraries. On unix system, this can be done by appending new paths to the environment variable `LD_LIBRARY_PATH`. 

We can setup a startup script for the `tf` `conda` environment. Once `tf` is activated, the script will be executed. The script will be placed at `miniconda/conda/envs/tf/etc/conda/activate.d`.

```bash
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
echo 'CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/:$CUDNN_PATH/lib' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
```

6. Install `tensorflow`

Before we install tensorflow, we need to update `pip` to the latest version.

```bash
pip install --upgrade pip
```

Install `tensorflow` and `pillow` (needed for image preprocessing).

```bash
pip install tensorflow==2.12.*
pip install pillow
```

7. Install `nvcc`

Usually, the `cudatoolkit` will come with a `cuda` compiler, but for some reasons, it does not ship with one to the appropriate location. This can be fixed by manually installing `nvcc` via `conda`.

```bash
conda install -c nvidia cuda-nvcc=11.3.58
```

Again, we need to tell the program where to find the compiler.

```bash
printf 'export XLA_FLAGS=--xla_gpu_cuda_data_dir=$CONDA_PREFIX/lib/\n' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
source $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
mkdir -p $CONDA_PREFIX/lib/nvvm/libdevice
cp $CONDA_PREFIX/lib/libdevice.10.bc $CONDA_PREFIX/lib/nvvm/libdevice/
```


8. Verify the installation

Check `python` version (3.11).

```bash
python --version
```

Check `tensorflow`.

```bash
python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

Check if the GPU is detected.

```bash
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

Use `python` to test the following code. Open another terminal, run the `nvidia-smi` command to monitor if `tensorflow` actually uses GPU.

```python
import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10)
])

model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])
              
model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test,  y_test, verbose=2)
```

9. Install `keras_tuner`

```bash
pip install keras-tuner --upgrade
```

### `R`

We want to install some `R` libraries, but we are not allowed to write to the default library path. So we need to create a folder to store them.

```bash
cd sk54_scratch/wlii0039
mkdir r_libs
```

Specify the library location such that `.libPaths()` will return the correct library path.

```bash
cd ~
echo "R_LIBS=~/sk54_scratch/wlii0039/r_libs" > .Renviron
```

Since we may also want to use `tesnsorflow` in `R`, we need to specify some environment variables for `reticulate`.

```bash
echo "R_RETICULATE_CONDA=~/sk54_scratch/wlii0039/miniconda/bin/conda" > .Renviron
echo "R_RETICULATE_PYTHON=~/sk54_scratch/wlii0039/miniconda/conda/envs/tf/bin/python" > .Renviron
```

Then, we can install our own libraries.

```bash
module load R/4.0.5
R
```


```r
remotes::install_github("TengMCing/bandicoot")
remotes::install_github("TengMCing/visage")
install.packages("tidyverse")
install.packages("tensorflow")
install.packages("keras")
```

## Experience

1. The Massive desktop virtual machine is great, except for the key bindings if you are using Mac. The copy and paste key never work.
2. There are many different types of Massive desktop. P4 and single T4 are preferred since they have lower waiting time. Dual T4 and K80 are more powerful and both have 2 GPUs but it could be a waste if your program can not use multiple GPUs.
3. Massive desktop is also very important if you want to test the correctness of your code in an environment similar to the `sbatch` cluster. You can not modify your `sbatch` job, but you can test it on Massive desktop.
4. Libraries (dynamic or not) and software packages on Massive are often out-of-date. The latest version of R on Massive is 4.1.0-mkl which is a vesion of R linking to the Intel BLAS and LAPACK library. It is better not to use this version because it may give math result inconsistent to other machines. The R we are currently using is R 4.0.5 which is released on March 2021 missing some important feature updates such as the built-in pipe operator. 
5. The out-of-date R is usually not a big deal. But the out-of-date system tools could make you mad. For
example, the important GPU driver `cuda` and `cudnn` provided by Massive are of version 10.1 and 7.6.5.32-cuda10 released on May 2019 and Nov 2019 respectively. Massive actually has newer version of `cuda` and `cudnn`, but I found they doesn't actually work with the "supported" version of Python and tensorflow after reinstalling different configurations of my miniconda for 7 times. Further, some commonly used tools such as `conda` is also seriously out-of-date. Attempting to update it may also crash all of your `conda` environments. 
6. The most important difference between the cluster and our local machine is the control of the available software and the software version. You can not easily install or update any important library on the cluster. This usually forces the user to install and use the out-of-date library on their own local machine such that the code can be tested locally.
7. The only working combination of Python, tensorflow, cuda and cudnn on Massive I found so far is Python 3.7, pandas 1.3, tensorflow 2.1.0, cuda 10.1 and cudnn 7.6.5.32-cuda10. I can not install Python 3.7 and tensorflow 2.1.0 on my local machine since Apple M1 doesn't support them (https://developer.apple.com/metal/tensorflow-plugin/). This means I have to (1) use the out-of-date keras APIs which is possibly deprecated on the version installed on my local machine (2) test them on Massive Desktop every time.
8. The VGG16 model spend around 30mins per epoch on thesingle T4 GPU. Training a model possibly needs around 50 epochs, so 25 hours.
9. The CPU on Massive is not very fast, sometimes it is even slower than M1. I have enabled multiprocessing on my data setup script, but it still takes around 3 hours to generate all the images.  

## Status

After fixing numerous issues, now I can successfully launch tensorflow training scripts on both the Massive desktop and the Massive cluster. The script can be written in R or Python. The R API is working correctly with tensorflow 2.1.0.

I have also setup the training data for the single residual plot model. The training data contains 141602 images, where 50% of them are null images and 50% of them are not null images. They are generated from three regression model with violations, namely polynomial model, heteroskedasticity model and non-normal model. Images of AR(1) model are also prepared but they are not mixed in the training data due to the difficulty of learning. The test data contains 14162 images.

### Plans

1. Train a VGG16 model via Massive desktop ensuring it works on the platform.
2. Train a VGG16 model via `sbatch` to see how long it takes.
3. Bring in keras-tuner to optimize the hyperparameters of VGG16. (use cross-validation?)
4. Try to use multiple GPU with `tf.distribute.MirroredStrategy()`. I also need to know how long it will take to schedule the job.
4. Try other architecture such as ResNet. Also use keras-tuner to optimize hyperparameters.
