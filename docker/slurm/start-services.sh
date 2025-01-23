#!/bin/bash

# Skip cgroups
echo "Skipping cgroup setup for simplicity."

# Start services
service munge start
service slurmctld start
service slurmd start

source /opt/conda/etc/profile.d/conda.sh
conda activate phyloherb
/bin/bash