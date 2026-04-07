# WHR7206 Bioinformatics Module Repository

This repository contains a bash-based pipeline for quality filtering of a trio of whole exome sequencing variants in a VCF file.
This is genotype and variant level quality control and was implemented using bcftools.

## Pipeline overview
The script executes:
- Variant-level filtering (filter=PASS)
- Genotype level filtering QC (DP≥10, GQ≥20)
- Removal of variants where any of the three trio genotypes have missingness

Quality control is performed before variant annotation, which is then followed by inheritance-based filtering.

## Pedigree Generation
A pedigree diagram of the trio and unaffected older sister was generated in R using the kinship2 package.
The script (pedigree_plot.R) produces a JPEG figure (pedigree.jpeg) used to support inheritance model selection in the assignment.

## VEP Annotation
Variants were annotated using Ensembl Variant Effect Predictor (VEP) v115, run via the official Ensembl Docker container in offline cache mode.
The script `vep_annotation.sh` documents the exact command-line settings used, including GRCh37 assembly, canonical transcripts, and gnomAD allele frequencies.


## Files
- trio_qc_filtering.sh — QC filtering script
- Pedigree script.R - Pedigree generation script
- pedigree.jpeg - Pedigree figure
- vep_annotation.SH - VEP annotation command line

