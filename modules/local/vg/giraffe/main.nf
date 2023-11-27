process VG_GIRAFFE {
    tag "$meta.id"
    label 'process_medium'
    
    conda "bioconda::vg=1.50.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vg:1.50.1--h9ee0642_0':
        'biocontainers/vg:1.50.1--h9ee0642_0' }"
    
    input:
    tuple val(meta), path(fq), path(gbz), path(min), path(dist)

    output:
    tuple val(meta), path("*.gam"), emit: gam, optional: true
    tuple val(meta), path("*.bam"), emit: bam, optional: true
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def indv = "${meta.id.toString().tokenize('_')[0]}" + '_' + "${meta.id.toString().tokenize('_')[1]}"
    """
    vg giraffe \\
        --threads ${task.cpus} \\
        -Z ${gbz} \\
        -m ${min} \\
        -d ${dist} \\
        -f ${fq[0]} \\
        -f ${fq[1]} \\
        -R $indv \\
        -N $indv \\
        -p \\
        > ${prefix}.gam
    
    vg surject \\
        -x ${gbz} \\
        -b ${prefix}.gam \\
        > ${prefix}.bam

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