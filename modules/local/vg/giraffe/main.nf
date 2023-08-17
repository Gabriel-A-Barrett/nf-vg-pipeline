process VG_GIRAFFE {
    tag "$meta.id"
    label 'process_medium'
    
    conda "bioconda::vg=1.45.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vg:1.45.0--h9ee0642_0':
        'biocontainers/vg:1.45.0--h9ee0642_0' }"
    
    input:
    tuple val(meta),  path(fq)
    tuple val(meta2), path(gbz)
    tuple val(meta3), path(min)
    tuple val(meta4), path(dist)

    output:
    tuple val(meta), path("*.gam"), emit: gam, optional: true
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg giraffe \\
        --threads ${task.cpus} \\
        -Z ${gbz} \\
        -m ${min} \\
        -d ${dist} \\
        -f ${fq[0]} \\
        -f ${fq[1]} \\
        -p \\
        > ${prefix}.gam
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(echo \$(vg 2>&1 | head -n 1 | sed 's/vg: variation graph tool, version v//;s/ ".*"//' ))
    END_VERSIONS    
    """
    
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(echo \$(vg 2>&1 | head -n 1 | sed 's/vg: variation graph tool, version v//;s/ ".*"//' ))
    END_VERSIONS
    """
}