FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh

# Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment and install packages
RUN conda create -n phyloherb python=3.7.0 -y \
    && echo "source activate phyloherb" > ~/.bashrc

# Install required packages
SHELL ["/bin/bash", "-c"]
RUN source activate phyloherb \
    && conda install -y -c bioconda getorganelle \
    && conda install -y -c conda-forge biopython \
    && conda install -y -c etetoolkit ete3 \
    && conda install -y -c bioconda mafft \
    && conda install -y -c bioconda iqtree

# Download GetOrganelle databases
RUN source activate phyloherb \
    && get_organelle_config.py --add embplant_pt,embplant_mt,embplant_nr

# Set the default command to activate the conda environment
ENTRYPOINT ["/bin/bash", "-c"]
# Create and set a working directory
WORKDIR /app

# Download and extract PhyloHerb repository
RUN wget https://github.com/lmcai/PhyloHerb/archive/refs/heads/main.zip \
    && unzip main.zip \
    && mv PhyloHerb-main PhyloHerb \
    && rm main.zip

CMD ["source activate phyloherb && /bin/bash"]