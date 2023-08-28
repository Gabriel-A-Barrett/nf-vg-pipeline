include { VG_CONSTRUCT } from '../modules/nf-core/vg/construct/main.nf'
include { VG_INDEX } from '../modules/nf-core/vg/index/main'
include { VG_AUTOINDEX } from '../modules/local/vg/autoindex/main.nf'
include { VG_GIRAFFE } from '../modules/local/vg/giraffe/main.nf'
include { VG_FILTER } from '../modules/local/vg/filter/main.nf'
include { VG_PACK } from '../modules/local/vg/pack/main.nf'
include { VG_SNARLS } from '../modules/local/vg/snarls/main.nf'
include { VG_CALL } from '../modules/local/vg/call/main.nf'
include { BCFTOOLS_SORT } from '../modules/nf-core/bcftools/sort/main'
include { BCFTOOLS_INDEX } from '../modules/nf-core/bcftools/index/main'
include { BCFTOOLS_REHEADER } from '../modules/nf-core/bcftools/reheader/main'
include { BCFTOOLS_CONCAT } from '../modules/nf-core/bcftools/concat/main'
include { BCFTOOLS_MERGE } from '../modules/nf-core/bcftools/merge/main'

workflow VARIANT_GRAPH_WORKFLOW {


    ch_vcf_tbi_insfasta = Channel.fromPath ( params.vcf ).map { vcf -> 
                tuple ([id:vcf.simpleName], vcf, params.tbi, []) }

    ch_fasta = Channel.fromPath ( params.fasta ).map { genome -> 
                tuple ([id:genome.simpleName], genome) }

    ch_fai = Channel.fromPath ( params.fai ).map { fai -> 
                tuple ([id:fai.simpleName], fai) }

    VG_CONSTRUCT ( ch_vcf_tbi_insfasta, ch_fasta, ch_fai )

    VG_INDEX ( VG_CONSTRUCT.out.graph )

    VG_AUTOINDEX ( ch_vcf_tbi_insfasta, ch_fasta, ch_fai, 'giraffe' )

    ch_fq = Channel.fromFilePairs(params.fq).map {id, fq ->
                tuple ([id:fq[0].simpleName], fq)}
    
    VG_GIRAFFE ( ch_fq, VG_AUTOINDEX.out.gbz.first(), VG_AUTOINDEX.out.min.first(), VG_AUTOINDEX.out.dist.first() )

    VG_FILTER ( VG_GIRAFFE.out.gam, VG_INDEX.out.xg.first() )

    //VG_AUGMENT ( VG_GIRAFFE.out.gam, vg )

    VG_SNARLS ( VG_INDEX.out.xg )

    // pre-compute gt support
    VG_PACK ( VG_FILTER.out.gam, VG_INDEX.out.xg.first() )

    // call indv. genotypes
    VG_CALL ( VG_PACK.out.pack, VG_INDEX.out.xg.first(), VG_SNARLS.out.snarls.first() )
    
    BCFTOOLS_SORT ( VG_CALL.out.vcf )

    BCFTOOLS_REHEADER ( BCFTOOLS_SORT.out.vcf )

    BCFTOOLS_INDEX ( BCFTOOLS_REHEADER.out.vcf )

    // rewrite meta.id based on letters before number for grouping
    ch_vcf_tbi = BCFTOOLS_REHEADER.out.vcf
    .join( BCFTOOLS_INDEX.out.tbi )
    .map { meta, vcf, tbi ->
        def metaG = [:]
        metaG.id = meta.id.split(/[^\p{L}]/)[0]
        [[ id:metaG.id ], vcf, tbi ]
    }
    .groupTuple(by:0)


    BCFTOOLS_MERGE ( ch_vcf_tbi )

}