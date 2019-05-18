#!/bin/bash

# pip install --user watchme[all]
watchme create singularity-pull

# Adding watcher /home/users/vsochat/.watchme/singularity-pull...
# Generating watcher config /home/users/vsochat/.watchme/singularity-pull/watchme.cfg

# disable caching
export SINGULARITY_DISABLE_CACHE=yes

# 1. On the head node (bad dinosaur!)

cd ${SCRATCH}

# Add variables for host, cpu, etc.
export WATCHMEENV_HOSTNAME=$(hostname)
export WATCHMEENV_NPROC=$(nproc)

for iter in 1 2 3 4 5; do
    for name in ubuntu busybox centos alpine nginx; do
    echo "Running $name iteration $iter..."
    watchme monitor singularity-pull singularity pull --force docker://$name --name $name-$iter --seconds 1
    done
done

# Next, here is an example of saving to flat files.
outdir=/home/users/vsochat/.watchme/singularity-pull/data
mkdir -p ${outdir}

# Next, we can run this on nodes with different memory. Since git doesn't
# do well with running in parallel, we will just save these files to the host,
# named based on the run.

for iter in 1 2 3 4 5; do
    for name in ubuntu busybox centos alpine nginx; do
        for mem in 4 6 8 12 16 18 24 32 64 128; do
            output="${outdir}/${name}-iter${iter}-${mem}gb.json"
            echo "sbatch --mem=${mem}GB pull-job.sh ${mem} ${iter} ${name} ${output}"            
            sbatch --mem=${mem}GB pull-job.sh "${mem}" "${iter}" "${name}" ${output}
        done
    done
done

