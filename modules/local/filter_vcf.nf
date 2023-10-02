process FILTER_VCF {
    label 'process_low'

    conda "conda-forge::tabix=1.11"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tabix:1.11--hdfd78af_0' :
        'biocontainers/tabix:v1.9-11-deb_cv1' }"

    input:
    tuple val(sampleid), path(vcf)

    output:
    path "*.vcf.gz"       , emit: vcf
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    # restrict to chromosome 1-22,X,Y,MT
    zcat ${vcf} \
        |egrep -v "^#" \
        |awk 'BEGIN {OFS="\t"};{if($7 == "PASS" && $1 ~ /[1-9]|1[0-9]|2[0-2]|X|Y|MT/  ) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'  \
        |egrep -v "ACGTNacgtnPLUS" \
        > PASS.tmp

    #cleanup header
    zcat ${vcf} |head -n 100000|grep "^##" \
        |egrep -v "##contig=<ID=GL0" \
        |egrep -v "##contig=<ID=NC_007605,length=171823>" \
        |egrep -v "##contig=<ID=hs37d5,length=35477943>" \
        |egrep -v "##contig=<ID=phiX174,length=5386>" \
        > header.txt

    echo -e "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t${sampleid}"  >> header.txt

    #write and compress vcf
    cat header.txt > PASS.vcf
    cat  PASS.tmp >>  PASS.vcf
    bgzip -f PASS.vcf
    tabix PASS.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
