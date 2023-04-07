#!/usr/bin/env bash
# Copyright 2021 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
# Called with following arguments:
# 1 - (optional) TENSORFLOW_ROOT: path to root of the TFLM tree (relative to directory from where the script is called).
# 2 - (optional) EXTERNAL_DIR: Path to the external directory that contains external code
# 3 - (optional) Path to the HEXAGON TFLM Lib

set -e

# Default prebulit core library on docker
HEXAGON_TFLM_LIB=/root/Qualcomm/hexagon_tflm_core.a

TENSORFLOW_ROOT=${1}
EXTERNAL_DIR=${2}

if [[ $# -ge 3 ]];
then
  HEXAGON_TFLM_LIB=$3
fi

source ${TENSORFLOW_ROOT}tensorflow/lite/micro/tools/ci_build/helper_functions.sh

readable_run make -f ${TENSORFLOW_ROOT}tensorflow/lite/micro/tools/make/Makefile clean TENSORFLOW_ROOT=${TENSORFLOW_ROOT} EXTERNAL_DIR=${EXTERNAL_DIR}

# TODO(b/143904317): downloading first to allow for parallel builds.
readable_run make -f ${TENSORFLOW_ROOT}tensorflow/lite/micro/tools/make/Makefile third_party_downloads TENSORFLOW_ROOT=${TENSORFLOW_ROOT} EXTERNAL_DIR=${EXTERNAL_DIR}

readable_run make -f ${TENSORFLOW_ROOT}tensorflow/lite/micro/tools/make/Makefile \
  TARGET=hexagon \
  OPTIMIZED_KERNEL_DIR=hexagon \
  OPTIMIZED_KERNEL_DIR_PREFIX=${TENSORFLOW_ROOT}third_party \
  HEXAGON_TFLM_LIB=${HEXAGON_TFLM_LIB} \
  TENSORFLOW_ROOT=${TENSORFLOW_ROOT} \
  EXTERNAL_DIR=${EXTERNAL_DIR} \
  build -j$(nproc)

readable_run make -f ${TENSORFLOW_ROOT}tensorflow/lite/micro/tools/make/Makefile \
  TARGET=hexagon \
  OPTIMIZED_KERNEL_DIR=hexagon \
  OPTIMIZED_KERNEL_DIR_PREFIX=${TENSORFLOW_ROOT}third_party \
  HEXAGON_TFLM_LIB=${HEXAGON_TFLM_LIB} \
  TENSORFLOW_ROOT=${TENSORFLOW_ROOT} \
  EXTERNAL_DIR=${EXTERNAL_DIR} \
  test -j$(nproc)


