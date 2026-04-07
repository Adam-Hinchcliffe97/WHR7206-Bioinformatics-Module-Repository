#Windows Power Shell
wsl

# install bcf tools
sudo apt update
sudo apt install bcftools tabix -y
brew install bcftools

# Check installation
bcftools --version

# Compress and index the VCF
bgzip Family_trio_2026.vcf
tabix -p vcf Family_trio_2026.vcf.gz

# Technical quality control filtering
# Apply QC filtering: filter=PASS
bcftools view -f PASS \
  Family_trio_2026.vcf.gz \
  -Oz -o step1.pass.vcf.gz
 tabix -p vcf step1.pass.vcf.gz

# Genotype-level QC: DP ≥ 10, GQ ≥ 20
bcftools filter \
  -S . \
  -e 'FMT/DP<10 || FMT/GQ<20' \
  step1.pass.vcf.gz \
  -Oz -o step2.dp_gq_filtered.vcf.gz
 tabix -p vcf step2.dp_gq_filtered.vcf.gz

# Remove variants with missing genotypes in the trio
bcftools view \
  -i 'COUNT(GT="mis")==0' \
  step2.dp_gq_filtered.vcf.gz \
  -Oz -o step3.trio_complete.vcf.gz
 tabix -p vcf step3.trio_complete.vcf.gz

##############################################
#Annotation with ensembl VEP - see annotation folder for details
##############################################
# Biological Prioritisation
# Keep only coding / splice variants
bcftools view \
  -i 'INFO/CSQ~"missense_variant|stop_gained|frameshift_variant|splice_acceptor_variant|splice_donor_variant|start_lost"' \
  step3.trio_complete.mane.vep.vcf \
  -Oz -o step4.coding_only.vcf.g
 tabix -p vcf step4.coding_only.vcf.gz

# Prioritise canonical  OR  MANE transcripts
bcftools view \
  -i 'INFO/CSQ~"CANONICAL=YES" || INFO/CSQ~"MANE_SELECT|MANE_PLUS_CLINICAL"' \
  step4.coding_only.vcf.gz \
  -Oz -o step5.transcript_prioritised.vcf.gz
 tabix -p vcf step5.transcript_prioritised.vcf.gz

# Allele‑frequency filtering -- filtering on gnomADe_AF
# Create rare variant pool (AF ≤ 0.01)
bcftools view \
  -i 'INFO/CSQ~"gnomADe_AF=0(\\.0*)?" || INFO/CSQ~"gnomADe_AF=[0-9]\\.[0-9]*E-[0-9]+" || INFO/CSQ~"gnomADe_AF=\\."' \
  step5.transcript_prioritised.vcf.gz \
  -Oz -o step6.rare_variants.vcf.gz
tabix -p vcf step6.rare_variants.vcf.gz

# Create autosomal recessive candidate file
bcftools view \
  -r 1-22 \
  step6.rare_variants.vcf.gz \
  -Oz -o step7.AR_candidates.vcf.gz
 tabix -p vcf step7.AR_candidates.vcf.gz

# X‑linked recessive (male proband, AF ≤ 0.001)
# First restrict to chromosome X, then filter to 0.001
bcftools view \
  -r X \
  -i 'INFO/CSQ~"gnomADe_AF=0(\\.0*)?" || INFO/CSQ~"gnomADe_AF=[0-9\\.e-]+E-[3-9]" || INFO/CSQ~"gnomADe_AF=\\."' \
  step6.rare_variants.vcf.gz \
  -Oz -o step8.XR_candidates.vcf.gz
 tabix -p vcf step8.XR_candidates.vcf.gz