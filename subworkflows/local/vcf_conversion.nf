/* --    IMPORT LOCAL MODULES/SUBWORKFLOWS     -- */
include { LIFTOVER   }             from '../../modules/local/liftover.nf'

workflow vcf_conversion {

    take:
    vcfs

    main:
        //
        // filter sites
        //
        FILTER_VCF (

        )
/*
        //
        // liftover to hg38
        //
        LIFTOVER (
            mtx_matrices,
            txp2gene,
            star_index
        )

        //
        // combine all vcfs
        //
        MTX_TO_SEURAT (
            mtx_matrices
        )

        // prepare versions outpout
        ch_versions = ch_versions.mix(LIFTOVER.out.versions)
*/
    emit:
    ch_versions
    vcf = FILTER_VCF.out.vcf

}
