process CELLPOSE {
    tag "$meta.id"
    label 'process_medium'

    container "docker.io/biocontainers/cellpose:2.2.2_cv2"

    input:
    tuple val(meta), path(image)
    path(model)

    output:
    tuple val(meta), path("*masks.tif") ,   emit: mask
    tuple val(meta), path("*flows.tif") ,   emit: flows, optional: true
    path "versions.yml"                 ,   emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "I did not manage to create a cellpose module in Conda that works in all OSes. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def model_command = model ? "--pretrained_model $model" : ""
    def VERSION = '2.2.2'
    """
    cellpose \\
        --image_path $image \\
        --save_tif \\
        --verbose \\
        $model_command \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cellpose: $VERSION
    END_VERSIONS
    """
    stub:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "I did not manage to create a cellpose module in Conda that works in all OSes. Please use Docker / Singularity / Podman instead."
    }
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "2.2.2" // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    def name = image.name
    def base = name.lastIndexOf('.') != -1 ? name[0..name.lastIndexOf('.') - 1] : name
    """
    touch ${base}_cp_masks.tif

        cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cellpose: $VERSION
    END_VERSIONS
    """

}
