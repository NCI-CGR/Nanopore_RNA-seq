#!/bash/bin
module load snakemake/5.24.1 graphviz
snakemake --rulegraph | dot -T png > nanopore_RNA.png

