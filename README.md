# Watchme Singularity Pull

This is a simple watcher that will collect resource usage during a Singularity pull of several
containers, ubuntu, busybox, centos, alpine, and nginx. I chose these fairly randomly.
The goal will be to create plots, where we take a measurement each second, and
ask the following questions:

 1. Is running on a head node as bad an idea as we expect it to be.
 2. Is there varying performance based on the amount of memory available?

For the first point, it would be more accurate to look at a collection of head nodes
at different times of day (for example, it's a Saturday morning, and unlikely to be busy now).
For the second point, the extent to which the software takes advantage of available memory
depends on the software itself. Singularity (I think) should do a fairly good job at this.

## Scripts Included

This is a fairly simple analysis in that I could install [watchme](https://www.github.com/vsoch/watchme)
and then write a few quick scripts, run, and be done! 

 - [pull.sh](pull.sh) Is the script I ran on the head node to pull 5 containers (5 times each)
 - [pull-job.sh](pull-job.sh) I submit to different nodes with varying memory, also each 5 times)
 - [export.sh](export.sh) is a smalll script to export the data from the .git repository.

Note that since the cluster runs were done in parallel, watchme saved files directly to [data](data).
We can't use git as a temporal database here because it's likely to have issues with multiple jobs
trying to write and commit at the same time. I realize this is a drawback of the temporal database
approach, but this is also why it's reasonable to run watchme on its own and just save each
result to a file.

## 1. Setup

Specifically, to install watchme:

```bash
$ pip install watchme[all]
```

You can also clone and install from the master branch directly:

```bash
$ git clone https://www.github.com/vsoch/watchme
cd watchme
pip install .[all] --user
```

And then I created a watcher folder (this repo).

```bash
$ watchme create singularity-pull
```

## 2. Singularity Pull on a Head Node

This was the script [pull.sh](pull.sh) and it looked like this:

```bash
for iter in 1 2 3 4 5; do
    for name in ubuntu busybox centos alpine nginx; do
    echo "Running $name iteration $iter..."
    watchme monitor singularity-pull singularity pull --force docker://$name --name $name-$iter --seconds 1
    done
done
```

Notice how we are saving directly to the watcher. Then we can easily
export using [export.sh](export.sh). The data for this export is in [export](export).

## 3. Singularity Pull Varying Memory

We used the last section of the [pull.sh](pull.sh) script to launch a number
of jobs on the Sherlock cluster, each performing a pull:

```bash
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
```

The results were each written directly to files in [data](data) (not using
git as a temporal database).
