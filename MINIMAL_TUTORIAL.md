# Goal
The goal of this tutorial is to learn to perform phylogenomic analysis on plant genome data using PhyloHerb and related tools. The inputs are reads from the genomes of several plant species; the final result is a phylogenetic species tree describing the estimated evolution of the input plant species from (unknown) common ancestors.

## Prerequisites
This tutorial is for MacOS.

Install miniconda (see https://conda.io/projects/conda/en/latest/user-guide/install/index.html)

Create a conda environment and install GetOrganelle and its dependencies (may take a while)
```
conda create --name phyloherb python=3.7.0
#answer promt questions 
#proceed ([y]/n)?
#y
conda activate phyloherb
conda install -c bioconda getorganelle
conda install -c conda-forge biopython
conda install -c etetoolkit ete3

#get database for getorganelle
get_organelle_config.py --add embplant_pt,embplant_mt,embplant_nr

conda install -c bioconda mafft
conda install -c bioconda iqtree
```

## Assembly
The goal of assembly is to take *reads* (fragments of DNA) from a species's genome and assemble them into a complete genome for the species. In this tutorial, we will use plastid DNA (DNA from the chloroplasts), not nuclear DNA, from five species: sp1, sp2, sp3, sp4, sp5

We will illustrate the assembly process for a single species, sp1, using example reads stored in the PhyloHerb repository.

### 1. Input preparation:
Download PhyloHerb and example datasets from Github
```
git clone https://github.com/lmcai/PhyloHerb.git
```

Then let's create a working directory `minimal_example`.
```
mkdir minimal_example
cd minimal_example
export PH=$(pwd)/../PhyloHerb
```

Move and rename the example dataset from PhyloHerb to the current working directory
```
mkdir 0_fastq
mv $PH/example/*.gz 0_fastq
```

### 2. Assembly
Load dependencies (assuming installing GetOrganelle under the conda environment named 'phyloherb')
```
# If environment not yet active
conda activate phyloherb
```
Create a working directory for assembly

```
mkdir 1_getorg
cd 1_getorg
mkdir chl
```

Perform assembly

```
export DATA_DIR=$(pwd)/../0_fastq
get_organelle_from_reads.py -1 $DATA_DIR/SP1_R1.100m.1.fastq.gz -2 $DATA_DIR/SP1_R2.100m.1.fastq.gz -o chl/sp1 -R 15 -k 21,45,65,85,95,105 -F embplant_pt
```
This stores the output of assembly in in minimal_example/1_getorg/chl/sp1/. See [this fasta file](minimal_example/1_getorg/chl/sp1/embplant_pt.K105.complete.graph1.1.path_sequence.fasta) for the assembled genome.

### Shortcut: Copy Pre-Assembled Genomes
If we had reads for the remaining species sp2, sp3, sp4, sp5, we would perform the corresponding commands for those species:
```
get_organelle_from_reads.py -1 $DATA_DIR/<species>_R1.100m.1.fastq.gz -2 $DATA_DIR/<species>_R2.100m.1.fastq.gz -o chl/<species> -R 15 -k 21,45,65,85,95,105 -F embplant_pt
```
However, the PhyloHerb does not store the raw reads for the remaining five species; it stores only the assembled genomes for those species. To finish this tutorial, we will copy the pre-assembled genomes from PhyloHerb to our working directory.
```
# Return to minimal_example dir
# cd minimal_example
# Remove single-species assembly results
rm -rf 1_getorg
# Copy all assembled genomes
cp $PH/example/results/1_getorg.tgz .
tar xzvf 1_getorg.tgz
rm 1_getorg.tgz
```

## Assembly QC
After the assemblies are completed, you can summarize the results using the QC function of phyloherb. For each species, it will extract the following information: the number of total input reads, the number of reads used for assembly, average base coverage, the total length of the assembly, GC%, and whether the assembly is circularized. It will also copy only the relevant assembled genomes to the output directory.

```
# cd minimal_example
mkdir 2_assemblies
python $PH/phyloherb.py -m qc -i 1_getorg/chl -o 2_assemblies/chl
```


## Ortholog Identification and Alignment
### Ortholog Identification
We identify orthologous genes from each species' genome using PhyloHerb.

In the `minimal_example` directory, type the following commands
```
# 
mkdir 3_alignments
python $PH/phyloherb.py -m ortho -i 2_assemblies/chl -o 3_alignments/chl/ -l 120
```

In the output directory `3_alignments/chl`, orthologous genes will be written to separate fasta files and the headers will be the species prefixes.

### Alignment
The copies of orthologous genes contained in the species are typically not exact matches for the reference genes; some insertions and deletions have occurred during evolution from the reference gene. Therefore the orthologous genes do not match exactly among the five sample species. In this step, we *align* matching sections of the gene sequence among the five sample sample species, leaving placeholder values '-' for deletions.

Just as we illustrated assembly with a single species, then copied the pre-assembled genomes from PhyloHerb to continue the tutorial, so we will illustrate alignment for a single gene, then copy pre-aligned results from PhyloHerb for all genes before continuing the tutorial.
```
cd 3_alignments/chl
mafft --adjustdirection accD.fas | sed 's/_R_//g' >accD.mafft.aln.fas
```

### Shortcut: Copy Pre-Aligned Results
```
# cd minimal_example
rm -rf 3_aligments
cp $PH/example/results/3_alignments.tgz .
tar xzvf 3_alignments.tgz
rm 3_alignments.tgz
```

## Phylogeny reconstruction
1. Concatenation
In this step, we concatenate the aligned genes for all five sample species. This creates an neatly aligned, simplified genome for each species, containing only the orthologous genes in the same order. We will use these simplified genomes to estimate the phylogeny.

Concatenate all of the fasta sequences in the input directory `3_alignments/chl` with the suffix `.mafft.aln.fas`:
```
python $PH/phyloherb.py -m conc -i 3_alignments/chl -o 5sp_chl -suffix .mafft.aln.fas
```

2. Maximum likehood phylogeny
In this step, we create the estimated phylogenetic tree connecting the five sample species to each other via unknown common ancestors.

For this small dataset, we will use IQTREE to generate the maximum likelihood tree.
```
iqtree2 -m GTR+G -s 5sp_chl.conc.fas --prefix 5sp_chl.rnd1
```
You will find a report on the tree, including a diagram, in `minimal_example/5sp_chl.rnd1.iqtree`. A textual representation of the tree in newick format is in `minimal_example/5sp_chl.rnd1.iqtree`.
