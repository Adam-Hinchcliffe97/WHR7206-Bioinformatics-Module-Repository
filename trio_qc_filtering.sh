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
  -i 'INFO/CSQ~"|missense_variant|" || INFO/CSQ~"|stop_gained|" || INFO/CSQ~"|frameshift_variant|" || INFO/CSQ~"|splice_acceptor_variant|" || INFO/CSQ~"|splice_donor_variant|" || INFO/CSQ~"|start_lost|"' \
  step3.trio_complete.mane.vep.vcf \
  -Oz -o step4.coding_only.vcf.gz
 tabix -p vcf step4.coding_only.vcf.gz

# Create a numerical column for allele frequency to filter on
bcftools +split-vep step4.coding_only.vcf.gz \
  -c gnomADe_AF:Float \
  -Oz -o step4.with_AF.vcf.gz
tabix -p vcf step4.with_AF.vcf.gz

# Allele‑frequency filtering -- filtering on gnomADe_AF
# Create rare variant pool (AF ≤ 0.01, including those with 0 or no entry)
bcftools view \
  -i 'gnomADe_AF<=0.01 || gnomADe_AF="."' \
  step4.with_AF.vcf.gz \
  -Oz -o step5.rare_variants.vcf.gz
 tabix -p vcf step5.rare_variants.vcf.gz

# Create autosomal recessive candidate file
bcftools view \
  -i 'CHROM!="X" && CHROM!="MT"' \
  step5.rare_variants.vcf.gz \
  -Oz -o step6.AR_candidates.vcf.gz
 tabix -p vcf step6.AR_candidates.vcf.gz

# X‑linked recessive (male proband, AF ≤ 0.001)
# First restrict to chromosome X, then filter to 0.001
bcftools view \
  -i 'CHROM=="X" && (gnomADe_AF<=0.001 || gnomADe_AF=".")' \
  step5.rare_variants.vcf.gz \
  -Oz -o step7.XR_candidates.vcf.gz
 tabix -p vcf step7.XR_candidates.vcf.gz

# De novo autosomal heterozygous in the proband only
bcftools view \
  -i 'GT[0]="0/1" && GT[1]="0/0" && GT[2]="0/0" && CHROM!="X" && CHROM!="MT"' \
  step5.rare_variants.vcf.gz \
  -Oz -o step8.denovo_candidates.vcf.gz
 tabix -p vcf step8.denovo_candidates.vcf.gz
