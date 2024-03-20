process PROPR_PROPD {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-propr:4.2.6':
        'biocontainers/r-propr:4.2.6' }"

    input:
    tuple val(meta), path(count)
    tuple val(meta2), path(samplesheet)
    val GSEA

    output:
    tuple val(meta), path("*.propd.rds"), emit: propd
    tuple val(meta), path("*.propd.tsv"), emit: results
    tuple val(meta), path("*.fdr.tsv")  , emit: fdr         , optional:true
    tuple val(meta), path("*.gct")  , emit: gct         , optional:true
    tuple val(meta), path("*.cls")  , emit: cls         , optional:true
    path "*.R_sessionInfo.log"          , emit: session_info
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    GSEAopt = GSEA.toString().toUpperCase() // R expects upper case
    template 'propd.R'
}
