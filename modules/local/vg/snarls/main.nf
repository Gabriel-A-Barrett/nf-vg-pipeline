process VG_SNARLS {
    tag "$meta.id"
    label 'process_high_memory'
    
    conda "bioconda::vg=1.50.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vg:1.50.1--h9ee0642_0':
        'biocontainers/vg:1.50.1--h9ee0642_0' }"
    
    input:
    tuple val(meta),  path(xg)

    output:
    tuple val(meta), path("*.snarls"), emit: snarls
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg snarls \\
        ${xg} \\
        ${args} \\
        > ${prefix}.snarls
    
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