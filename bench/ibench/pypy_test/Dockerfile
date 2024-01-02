from pypy

# Install basic tools
RUN apt-get update -y && apt-get install -y git vim

# Install postgres client library for PYPY
RUN python3 -m pip install psycopg2cffi

WORKDIR /workspace
# Pull branch with PYPY-patched ibench
RUN git clone -b pypy https://github.com/tiemobang/mytools.git

WORKDIR /workspace/mytools/bench/ibench
