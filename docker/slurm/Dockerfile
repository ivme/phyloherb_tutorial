FROM giovtorres/slurm-docker-cluster:latest

# Update to use CentOS vault mirrors
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum clean all && \
    yum makecache && \
    yum -y install \
    wget \
    curl \
    bzip2 \
    unzip \
    && yum clean all

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

RUN conda create -n phyloherb python=3.7.0 -y \
    && echo "source activate phyloherb" > ~/.bashrc

SHELL ["/bin/bash", "-c"]
RUN source activate phyloherb \
    && conda install -y -c bioconda getorganelle \
    && conda install -y -c conda-forge biopython \
    && conda install -y -c etetoolkit ete3 \
    && conda install -y -c bioconda mafft \
    && conda install -y -c bioconda iqtree

RUN source activate phyloherb \
    && get_organelle_config.py --add embplant_pt,embplant_mt,embplant_nr

WORKDIR /tutorial

RUN wget https://github.com/lmcai/PhyloHerb/archive/refs/heads/main.zip \
    && unzip main.zip \
    && mv PhyloHerb-main PhyloHerb \
    && rm main.zip

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]