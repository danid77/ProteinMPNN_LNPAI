#!/usr/bin/env bash
set -Eeuo pipefail

# conda env 실행 래퍼
CONDA_RUN="/opt/conda/bin/conda run --no-capture-output -n mlfold"

# bash가 첫 인자면 쉘로 진입
if [[ "${1:-}" == "bash" ]]; then
  exec bash
fi

# 기본: protein_mpnn_run.py에 전달된 모든 인자를 그대로 넘김
exec $CONDA_RUN python /workspace/ProteinMPNN_LNPAI/protein_mpnn_run.py "$@"