# VEP command line settings

docker run --rm -i \
  -v ~/.vep:/opt/vep/.vep \
  ensemblorg/ensembl-vep \
  vep \
  --format vcf \
  --vcf \
  --cache \
  --offline \
  --assembly GRCh37 \
  --symbol \
  --canonical \
  --nearest symbol \
  --af_gnomad \
  -o STDOUT \
  < step3.trio_complete.vcf \
  > step3.trio_complete.vep.vcf
