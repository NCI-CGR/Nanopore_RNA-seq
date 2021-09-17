# Alternative Splicing Analysis Using Nanopore Long-Reads RNA Sequencing Data

## Description
This snakemake pipeline is for alternative splicing analysis using Nanopore long-read RNA sequencing data. The pipeline may be run on an HPC or in a local environment.

Major steps in this workflow include:

1) Basing calling using [BONITO](https://github.com/nanoporetech/bonito)
2) Alignment using [Minimap2](https://github.com/lh3/minimap2)
3) Splicing analysis using [Stringtie2](https://github.com/skovaka/stringtie2)
4) Splicing analysis using [Freddie](https://github.com/vpc-ccg/freddie)

## Software Requirements
* [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
* [Bonito](https://github.com/nanoporetech/bonito)
* [Freddie](https://github.com/vpc-ccg/freddie)

## User's guide
### I. Input requirements
* Edited config/config.yaml
* Demultiplexed Nanopore fast5 data
* Reference genome and annotation files

### II. Editing the config.yaml
Basic parameters:
* bonito: Path to the directory where Bonito is installed
* raw: Path to the directory where demultiplexed fast5 data is stored. The name of sub-directory for each sample should be in this format: {sampleID}_fast5
* out: Output directory, default without input: "output" in working directory
* reference: Path to primary reference genome fasta file
* gtf: Path to primary reference genome annotation gtf file
* py: If use Pychopper to identify, orient and trim full-length Nanopore cDNA reads or not. Input "yes" if PCR amplification is included in the library preparation protocol; otherwise input "no".

Parameters for alignment quality filtering:
* mq: Minmum mapping quality

Parameters for Stringtie2:
* stringtie_opts: --conservative (conservative transcriptome assembly) --rf/--fr (stranded library), etc

Parameters for Freddie:
* split: Path to the script freddie_split.py
* segment: Path to the script freddie_segment.py
* cluster: Path to the script freddie_cluster.py
* isoforms: Path to the script freddie_isoforms.py
* lic: Path to gurobi license
* mr1: Minimum contrasting coverage support required for a breakpoint in Segment. Default: 3
* mr2: Minimum read support allowed for an isoform in Cluster. Default: 3
* mps: Maximum number of candidate breakpoints allowed per segmentation problem in Segment. Default: 50


Optional parameters to run the full analysis on HPV genomes:

(This function was originally designed for the HPV project, however, it can be applied to any secondary genome analysis of any species with references.)

* hpv: Run the analysis on HPV genomes or not
* hpv_ref: Path to HPV reference genome fasta file
* hpv_gtf: Path to HPV reference genome annotation file

### III. To run
* Clone the repository to your working directory
  ```bash
  git clone https://github.com/NCI-CGR/Nanopore_RNA-seq.git
  ```
* Install required software
* Create conda environment using the provided yaml file and activate it after installation:
  ```bash
  conda env create -f env/nanopore_RNA.yaml
  conda activate nanopore_RNA
  ```
* Edit and save config/config.yaml
* To run on an HPC using slurm job scheduler like NIH Biowulf (Pascal GPU or higher architecture required):

  Edit config/cluster_config.yaml according to your HPC information and adjust the computing resources as needed. Run sbatch.sh to initiate pipeline running.
  ```bash
  bash sbatch.sh
  ```
* To run in a local environment:
  ```bash
  export LD_LIBRARY_PATH={PATH}/conda/envs/nanopore_RNA/lib/:$LD_LIBRARY_PATH
  export PYTHONPATH=$PYTHONPATH:{PATH}/conda/envs/nanopore_RNA/lib/python3.7/site-packages/
  export GRB_LICENSE_FILE={PATH}/gurobi.lic
  snakemake -p --cores 16 --keep-going --rerun-incomplete --jobs 300 --latency-wait 120 all
  ```
* Look in log directory for logs for each rule
* To view the snakemkae rule graph:
  ```bash
  snakemake --rulegraph | dot -T png > nanopore_RNA.png
  ````
![dag](https://github.com/NCI-CGR/Nanopore_RNA-seq/blob/master/nanopore_RNA.png)

### IV Output directory structure
```bash
{output directory}
├── alignment # Alignment on primary (eg human) genome
│   └── {sampleID}
├── alignment_hpv # Alignment on secondary (eg HPV) genome
│   └── {sampleID}
├── freddie # Splicing analysis on primary genome using Freddie
│   └── {sampleID}
├── freddie_hpv # Splicing analysis on secondary genome using Freddie
│   └── {sampleID}
├── reads # Base calling
│   └── {sampleID}
├── stringtie # Splicing analysis on primary genome using Stringtie2
│   └── {smapleID}
└── stringtie_hpv # Splicing analysis on secondary genome using Stringtie2
    └── {smapleID}
```
