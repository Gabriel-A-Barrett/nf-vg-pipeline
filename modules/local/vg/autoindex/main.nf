process VG_AUTOINDEX {
    tag "$meta.id"
    label 'process_medium'
    
    conda "bioconda::vg=1.45.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vg:1.45.0--h9ee0642_0':
        'biocontainers/vg:1.45.0--h9ee0642_0' }"
    
    input:
    tuple val(meta),  path(vcf), path(tbi), path(insertions_fasta)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(fai)
    val type

    output:
    tuple val(meta), path("*.dist")       , emit: dist, optional: true
    tuple val(meta), path("*.giraffe.gbz"), emit: gbz , optional: true
    tuple val(meta), path("*.min")        , emit: min , optional: true    
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg autoindex \\
        --threads ${task.cpus} \\
        --workflow ${type} \\
        --prefix ${prefix} \\
        --ref-fasta ${fasta} \\
        --vcf ${vcf}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(echo \$(vg 2>&1 | head -n 1 | sed 's/vg: variation graph tool, version v//;s/ ".*"//' ))
    END_VERSIONS    
    """
    
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.min

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(echo \$(vg 2>&1 | head -n 1 | sed 's/vg: variation graph tool, version v//;s/ ".*"//' ))
    END_VERSIONS
    """
}