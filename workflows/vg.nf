include { VG_TOOLKIT } from '../subworkflows/local/vg_toolkit'
include { VG_RADSEQ_FILTERS } from '../subworkflows/local/vg_radseq_filters'

workflow VG {

    VG_TOOLKIT (  )

    VG_RADSEQ_FILTERS ( VG_TOOLKIT.out.norm_vcf )

}