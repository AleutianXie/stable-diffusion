FROM nvidia/cuda:11.4.1-base-ubuntu20.04
MAINTAINER Aleutian Xie<huisheng.xie@freshape.com>

ENV DEBIAN_FRONTEND=noninteractive

# update apt sources to aliyun
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# update apt sources to tsinghua
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN apt-get clean && apt-get update

# change time zone
RUN echo "Asia/Shanghai" > /etc/timezone

# install wget, git
RUN apt-get -y install wget git

# install glib sm6 xrender1
RUN apt-get -y install libglib2.0-dev libsm6 libxrender1

# install conda
# Create a working directory
RUN mkdir -p /app/anaconda3
WORKDIR /app
RUN cd /app/anaconda3
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2022.10-Linux-x86_64.sh
RUN bash Anaconda3-2022.10-Linux-x86_64.sh -b && \
    echo "export PATH=\"/root/anaconda3/bin:$PATH\"" >> ~/.bashrc && \
    /bin/bash -c "source /root/.bashrc"
ENV PATH /root/anaconda3/bin:$PATH
RUN conda init bash
# conda change to tsinghua source
COPY .condarc /root/.condarc
# change pip to tsinghua source
COPY pip.conf /root/.pip/pip.conf

RUN cd /app
RUN git clone https://github.com/AleutianXie/stable-diffusion.git
WORKDIR /app/stable-diffusion

# RUN conda env create -f environment.yaml
RUN conda create -n ldm python=3.8 -y
# Make RUN commands use the new environment:
RUN echo "conda activate ldm" >> /root/.bashrc
# Make QT_QPA_PLATFORM=offscreen
# Make QT_QPA_PLATFORM=offscreen
RUN echo "export QT_QPA_PLATFORM=offscreen" >> /root/.bashrc
SHELL ["conda", "run", "-n", "ldm", "/bin/bash", "-c"]
# CUDA 11.3
RUN conda install -n neus pytorch==1.11.0 \
    torchvision==0.12.0 \
    cudatoolkit=11.3 -c pytorch
# RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
# RUN conda install -n neus colmap=3.7=gpuhf1cd06d_106 -y
RUN pip install tqdm \
    numpy==1.19.2 \
    albumentations==0.4.3 \
    diffusers \
    opencv-python==4.1.2.30 \
    pudb==2019.2 \
    invisible-watermark \
    imageio==2.9.0 \
    imageio-ffmpeg==0.4.2 \
    pytorch-lightning==1.4.2 \
    omegaconf==2.1.1 \
    test-tube>=0.7.5 \
    streamlit>=0.73.1 \
    einops==0.3.0 \
    torch-fidelity==0.3.0 \
    transformers==4.19.2 \
    torchmetrics==0.6.0 \
    kornia==0.6

RUN pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
RUN pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
RUN pip install -e .
RUN wget https://freshape-xjp.oss-accelerate.aliyuncs.com/Download_data/model/dfu/sd-v1-1.ckpt

# python model
RUN pip install PyMySQL
RUN pip install PyMySQL[rsa]
RUN pip install pydantic
RUN pip install pydantic[dotenv]
# install oss python sdk
RUN pip install oss2

# copy resource uplate later to k8s config
COPY .env_prod /app/stable-diffusion/ape/.env_prod
COPY .env_test /app/stable-diffusion/ape/.env_test
COPY .env_dev /app/stable-diffusion/ape/.env_dev

# Download hub ...
RUN python scripts/txt2img.py --prompt "a pretty girl" --plms --ckpt sd-v1-1.ckpt --skip_grid --n_samples 1 --n_iter 1 --ddim_steps 100
