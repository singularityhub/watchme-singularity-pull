#!/bin/bash

# singularity-pull watcher is already created!

mem=${1}
iter=${2}
name=${3}
output=${4}

# disable caching
export SINGULARITY_DISABLE_CACHE=yes

source /home/users/vsochat/.profile

cd ${SCRATCH}

# Add variables for host, cpu, etc.
export WATCHMEENV_HOSTNAME=$(hostname)
export WATCHMEENV_NPROC=$(nproc)
export WATCHMEENV_MAXMEMORY=${mem}
watchme monitor singularity pull --force docker://$name --name $name-$iter --seconds 1 > ${output}
