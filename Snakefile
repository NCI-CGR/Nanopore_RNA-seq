### This pipeline is for Oxford Nanopore RNA sequencing data analysis
# 1)
# 2)

## vim: ft=python
import sys
import os
import glob
import itertools

shell.prefix("set -eo pipefail; ")
configfile:"config/config.yaml"
localrules: all

# Path
run = os.getcwd() + "/"
raw = config["raw"]
out = config.get("out","output")
bo = config["bonito"]
fl = config["flair"]

# Sample names
def parse_sampleID(fname):
    return fname.split(raw)[-1].split('_fast5')[0]

dire = sorted(glob.glob(raw + '*_fast5'), key=parse_sampleID)

d = {}
for key, value in itertools.groupby(dire, parse_sampleID):
    d[key] = list(value)

samples = d.keys()

if config["hpv"]=="yes":
   include: "modules/Snakefile_map_hpv"
   include: "modules/Snakefile_stringtie_hpv"
   include: "modules/Snakefile_freddie_hpv"
   include: "modules/Snakefile_map"
   include: "modules/Snakefile_stringtie"
   include: "modules/Snakefile_freddie"
   rule all:
        input:
              expand(out + "alignment/{sample}/qc",sample=samples),
              expand(out + "alignment_hpv/{sample}/qc",sample=samples),
              expand(out + "stringtie_hpv/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
              expand(out + "stringtie_hpv/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples),
              expand(out + "freddie_hpv/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
              expand(out + "freddie_hpv/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples),
              expand(out + "stringtie/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
              expand(out + "stringtie/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples),
              expand(out + "freddie/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
              expand(out + "freddie/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples)

else:
    include: "modules/Snakefile_map"
    include: "modules/Snakefile_stringtie"
    include: "modules/Snakefile_freddie"
    rule all:
         input:
               expand(out + "alignment/{sample}/qc",sample=samples),
               expand(out + "stringtie/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
               expand(out + "stringtie/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples),
               expand(out + "freddie/{sample}/{sample}_gffcompare/complete.txt",sample=samples),
               expand(out + "freddie/{sample}/{sample}_gffread/{sample}_gffread.fa",sample=samples)
