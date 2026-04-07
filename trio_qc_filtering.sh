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

# NOT YET DONE, MAYBE NEEDS ANNOTATION

# Allele‑frequency filtering -- Assuming AF is in INFO as AF or gnomAD_AF

# Autosomal recessive (AF ≤ 0.01)

bcftools view \
  -i 'INFO/AF<=0.01' \
  step3.trio_complete.vcf.gz \
  -Oz -o AR_candidates.vcf.gz

# X‑linked recessive (male proband, AF ≤ 0.001)
# First restrict to chromosome X:

bcftools view -r X \
  step3.trio_complete.vcf.gz \
  -Oz -o chrX.vcf.gz

# Then filter AF more strictly:

bcftools view \
  -i 'INFO/AF<=0.001' \
  chrX.vcf.gz \
  -Oz -o XR_candidates.vcf.gz

