process FREEBAYES {
    tag "$meta.region"
    label 'process_medium'

    conda "bioconda::freebayes=1.3.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/freebayes:1.3.5--py38ha193a2f_3' :
        'quay.io/biocontainers/freebayes:1.3.5--py38ha193a2f_3' }"

    input:
    tuple val(meta), path(bam), path(bai), val(chromosome), path(fasta), path(fai)
    path samples
    path populations
    path cnv

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path  "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def region           = chromosome     ? "-r ${chromosome}"             : ""
    def samples_file     = samples        ? "--samples ${samples}"         : ""
    def populations_file = populations    ? "--populations ${populations}" : ""
    def cnv_file         = cnv            ? "--cnv-map ${cnv}"             : ""
    """
    freebayes \\
        -f $fasta \\
        $samples_file \\
        $populations_file \\
        $cnv_file \\
        $args \\
        $bam > ${chromosome}.vcf
    
    bgzip ${chromosome}.vcf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freebayes: \$(echo \$(freebayes --version 2>&1) | sed 's/version:\s*v//g' )
    END_VERSIONS
    """
}