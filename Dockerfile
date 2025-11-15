# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git ca-certificates bzip2 tini \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Miniconda 설치
# -----------------------------

ENV CONDA_DIR=/opt/conda
RUN wget -qO /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

SHELL ["/bin/bash", "-lc"]

# -----------------------------
# conda env + PyTorch CUDA 12.1 + biopython
# -----------------------------
# 약관 수락
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda create -n mlfold python=3.10 -y \
 && conda run -n mlfold python -m pip install --upgrade pip \
 && conda run -n mlfold pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cu121 \
      torch torchvision torchaudio \
 && conda run -n mlfold pip install --no-cache-dir biopython \
 && conda clean -afy

# -----------------------------
# ProteinMPNN_LNPAI 소스
# (원하시면 특정 커밋으로 핀 고정 가능: ARG PMPNN_COMMIT=<sha> && git checkout <sha>)
# -----------------------------
ARG PMPNN_REPO=https://github.com/danid77/ProteinMPNN_LNPAI.git
ARG PMPNN_DIR=/workspace/ProteinMPNN_LNPAI
RUN git clone --depth=1 ${PMPNN_REPO} ${PMPNN_DIR}

WORKDIR ${PMPNN_DIR}

# 기본 I/O 폴더(마운트 대상)s
RUN mkdir -p /input /output

# 엔트리포인트
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
# 인자를 안 주면 --help를 보여줍니다.
CMD ["--help"]