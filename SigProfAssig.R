library(SigProfilerAssignmentR)
library(devtools)
library(reticulate)
use_python("/nobackup/fbsev/bioinformatics-tools/miniconda3/envs/SigProfAssignR_py3.10_v0.1.7/bin/python")
install("GRCh38", rsync=FALSE, bash=TRUE)
#### PDES and CLs ####
## SBS
cosmic_fit(samples="./SBScontext/", output="./SBScontext/output/", input_type='vcf', context_type="96", collapse_to_SBS96=TRUE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh38")
## DBS
cosmic_fit(samples="./DBScontext/", output="./DBScontext/output/", input_type='vcf', context_type="DINUC", collapse_to_SBS96=FALSE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh38")
## ID
cosmic_fit(samples="./IDcontext/", output="./IDcontext/output/", input_type='vcf', context_type="ID", collapse_to_SBS96=FALSE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh38")

#### BOCA public dataset ####
install("GRCh37", rsync=FALSE, bash=TRUE)
## SBS
cosmic_fit(samples="./inputVCFs_novelFromVEP/", output="./SBSrun_novel/", input_type='vcf', context_type="96", collapse_to_SBS96=TRUE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh37")
## DBS
cosmic_fit(samples="./inputVCFs_novelFromVEP/", output="./DBSrun_novel/", input_type='vcf', context_type="DINUC", collapse_to_SBS96=FALSE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh37")
## ID
cosmic_fit(samples="./inputVCFs_novelFromVEP/", output="./IDrun_novel/", input_type='vcf', context_type="ID", collapse_to_SBS96=FALSE, cosmic_version=3.3, exome=FALSE, genome_build="GRCh37")
q()
