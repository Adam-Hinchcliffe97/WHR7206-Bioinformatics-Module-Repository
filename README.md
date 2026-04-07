# WHR7206 Bioinformatics Module Repository

This repository contains a bash-based pipeline for quality filtering of a trio of whole exome sequencing variants in a VCF file.
This is genotype and variant level quality control and was implemented using bcftools.

## Pipeline overview
The script executes:
- Variant-level filtering (filter=PASS)
- Genotype level filtering QC (DP≥10, GQ≥20)
- Removal of variants where any of the three trio genotypes have missingness
- Annotation of variants with canonical transcripts and MANE, gnomAD allele frequencies, associated genes and variant consequence
- Filtering for biological relevance, retaining only coding or splice variants
- Filtering for rare alleles (AF <0.01)
- Identification of candidate variants for autosomal recessive inheritance and X-linked recessive inheritance

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
- Family_trio_2026.vcf — Raw trio VCF provided by QMUL prior to any processing.
- Family_trio_2026.vcf.gz — bgzip‑compressed raw VCF for efficient processing.
- Family_trio_2026.vcf.gz.tbi — Tabix index for the compressed raw VCF.
- step1.pass.vcf.gz — Variants retained after applying the VCF‑level quality filter (FILTER=PASS).
- step1.pass.vcf.gz.tbi — Tabix index for step 1 output.
- step2.dp_gq_filtered.vcf.gz — Variants retained after genotype‑level QC filtering (DP ≥ 10, GQ ≥ 20).
- step2.dp_gq_filtered.vcf.gz.tbi — Tabix index for step 2 output.
- step3.trio_complete.vcf.gz — Variants with complete genotypes across all trio members (no missing calls).
- step3.trio_complete.vcf.gz.tbi — Tabix index for step 3 output.
- step3.trio_complete.mane.vep.vcf — VEP‑annotated VCF (GRCh37, offline cache) including gene symbol, consequence, canonical and MANE transcripts, and gnomAD allele frequencies.
- step4.coding_only.vcf.gz — Variants retained if any transcript had a protein‑altering or essential splice‑site consequence.
- step4.coding_only.vcf.gz.tbi — Tabix index for step 4 output.
- step4.with_AF.vcf.gz — Coding variants with a numeric gnomADe_AF INFO field extracted for frequency filtering.
- step4.with_AF.vcf.gz.tbi — Tabix index for AF‑augmented file.
- step5.rare_variants.vcf.gz — Rare coding variants retained using gnomAD exome AF ≤ 0.01 (or missing).
- step5.rare_variants.vcf.gz.tbi — Tabix index for rare‑variant pool.
- step6.AR_candidates.vcf.gz — Autosomal‑recessive candidate variants (chromosomes 1–22).
- step6.AR_candidates.vcf.gz.tbi — Tabix index for AR candidate file.
- step7.XR_candidates.vcf.gz — X‑linked recessive candidate variants (chromosome X, AF ≤ 0.001).
- step7.XR_candidates.vcf.gz.tbi — Tabix index for XR candidate file.
