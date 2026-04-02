
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/usr/local/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    CUDA_HOME=/usr/local/cuda \
    FORCE_CUDA=1 \
    PIP_PROGRESS_BAR=on \
    TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.9"

SHELL ["/bin/bash", "-lc"]

# 1) 系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    openssh-client \
    vim \
    curl \
    wget \
    ca-certificates \
    pkg-config \
    cmake \
    ninja-build \
    ffmpeg \
    tmux \
    libsm6 \
    libxext6 \
    libxrender1 \
    libglib2.0-0 \
    libgl1 \
    zlib1g-dev \
    libbz2-dev \
    libssl-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncursesw5-dev \
    libgdbm-dev \
    liblzma-dev \
    libexpat1-dev \
    tk-dev \
    uuid-dev \
    xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p -m 0700 /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

# 2) 安装 Python 3.9.25（与 environment.yml 对齐）
ARG PYTHON_VERSION=3.9.25
RUN cd /tmp \
 && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
 && tar -xzf Python-${PYTHON_VERSION}.tgz \
 && cd Python-${PYTHON_VERSION} \
 && ./configure --enable-shared --with-ensurepip=install \
 && make -j"$(nproc)" \
 && make altinstall \
 && ldconfig \
 && ln -sf /usr/local/bin/python3.9 /usr/local/bin/python \
 && ln -sf /usr/local/bin/pip3.9 /usr/local/bin/pip \
 && python --version \
 && pip --version \
 && rm -rf /tmp/Python-${PYTHON_VERSION} /tmp/Python-${PYTHON_VERSION}.tgz

WORKDIR /workspace

# 3) 拷贝代码
RUN --mount=type=ssh git clone git@github.com:DoubleFlicker7/gaussian-splatting.git --recursive
WORKDIR /workspace/gaussian-splatting

RUN git config pull.rebase false

# 4) 确保 submodules 已经带进来了
RUN test -d submodules/diff-gaussian-rasterization \
 && test -d submodules/simple-knn \
 && test -d submodules/fused-ssim

# 5) 安装 Python 依赖
#    这里额外 pin 了 numpy<2，避免老版本 PyTorch 在 NumPy 2 上踩坑
RUN python -m pip install --upgrade pip==23.0.1 setuptools wheel \
 && python -m pip install "numpy==1.26.4" 
COPY wheel/torch-2.0.0+cu118-cp39-cp39-linux_x86_64.whl /tmp/
RUN python -m pip install /tmp/torch-2.0.0+cu118-cp39-cp39-linux_x86_64.whl
RUN rm -f /tmp/torch-2.0.0+cu118-cp39-cp39-linux_x86_64.whl
RUN python -m pip install torchvision==0.15.1 \
      torchaudio==2.0.1 \
      --index-url https://download.pytorch.org/whl/cu118 
RUN python -m pip install \
      tqdm \
      plyfile \
      opencv-python==4.11.0.86 \
      joblib \
      nvitop \
      tensorboard
RUN python -m pip install --upgrade pip wheel \
 && python -m pip install "setuptools<82" packaging ninja
RUN python -m pip install --no-build-isolation ./submodules/diff-gaussian-rasterization \
 && python -m pip install --no-build-isolation ./submodules/simple-knn \
 && python -m pip install --no-build-isolation ./submodules/fused-ssim

# 6) 可选：做一个 sanity check
RUN python - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
print("torch cuda:", torch.version.cuda)
PY

CMD ["bash"]
