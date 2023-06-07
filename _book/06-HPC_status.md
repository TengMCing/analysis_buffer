# HPC status

## Workflow

This section records the setup of the remote machine.

```
# Create personal folder and clone the github repo
cd sk54
mkdir patrickli
git clone https://github.com/TengMCing/automatic_visual_inference.git

# Install tensorflow and init conda
cd ~
module load conda-install
conda-install
sk54_scratch/wlii0039/miniconda/bin/conda init
conda create --name tf2-gpu

# Please strictly follow these two steps
# This is the only working tf setup
conda install python==3.7 pandas==1.3
pip install tensorflow==2.1.0

# Check if the GPU is recognized
# Please use exactly these two libraries
module load cuda/10.1
module load cudnn/7.6.5.32-cuda10
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

# Create a folder to install our own R packages
cd sk54_scratch/wlii0039
mkdir r_libs

# Specify the library location such that `.libPaths()` will return the
# correct library path
cd ~
echo "R_LIBS=~/sk54_scratch/wlii0039/r_libs" > .Renviron

# Specify the `reticulate` environment variable
echo "R_RETICULATE_CONDA=~/sk54_scratch/wlii0039/miniconda/bin/conda" > .Renviron
echo "R_RETICULATE_PYTHON=~/sk54_scratch/wlii0039/miniconda/conda/envs/tf2-gpu/bin/python" > .Renviron

# Install our R packages to `r_libs`
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
