STORAGE_ALLOCATION=hirbea

# Define local path and NXF_HOME
Local_path="/storage1/fs1/${STORAGE_ALLOCATION}/Active/lyu.yang"
PY_function_path=${Local_path}/PY_function
Outdir="$PWD/results"
Ref_path="/storage1/fs1/${STORAGE_ALLOCATION}/Active/WGS_GEM_reference"
Project_path="/storage1/fs1/hirbea/Active/MGI_240806-SR005025"
mutect2_table="$Project_path/mutect2_bam_pairs.csv"
GATK_HOME="/storage1/fs1/hirbea/Active/MGI_240806-SR005025/gatk"
export GATK_HOME
export PATH=$GATK_HOME:$PATH
# Correct path mapping for LSF_DOCKER_VOLUMES
export LSF_DOCKER_VOLUMES="/opt/thpc:/opt/thpc /scratch1/fs1/ris:/scratch1/fs1/ris ${Local_path}/Nextflow:${Local_path}/Nextflow /storage1/fs1/${STORAGE_ALLOCATION}/Active:/storage1/fs1/${STORAGE_ALLOCATION}/Active"

# Define a port if it is not already set (default example)
#port=8408  # Default port, replace if necessary
#export LSF_DOCKER_PORTS="$port:$port"

# Environment settings
timeLimit="168"   # Time limit in hours
memory="128G"     # Memory requirement, minimum 16G
cores="16"         # Number of cores, minimum 4
#docker="ghcr.io/washu-it-ris/ris-thpc:runtime"         # Docker image (to be set in loop)
docker="19781121/strelka2-manta:v4"

tail -n +2 "$mutect2_table" | while IFS=$'\t' read -r tumor_BAM normal_BAM variant_calling_out Sample_ID

do
    job_name="${Sample_ID}_germline_calling"
     bsub -cwd "$GATK_HOME" -q general -n "$cores" -M "$memory" -G compute-hirbea \
       -a "docker($docker)" -W "${timeLimit}:00" \
       -o "$GATK_HOME/output_$(date +%Y%m%d_%H%M%S)_${Sample_ID}__Germline_calling.txt" \
       -J "$job_name" \
       -R "span[hosts=1] rusage[mem=$memory]" /bin/bash $PY_function_path/Germline_variant_calling.sh "$tumor_BAM" "$normal_BAM" "$variant_calling_out"
       
       
 
 done
    
