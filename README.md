# Variant Graph NextFlow Workflow

Will construct a variant graph, align reads with giraffe, call genotypes with freebayes and vg call.

**Minimum Usage**: `nextflow run main.nf --fasta </path/to/fastq> --vcf </path/to/vcf> --fq </path/to/*.{1,2}.fq.gz> -profile test,<singularity|conda|docker>`

## Full Usage

Parameters can be adjusted in a `nextflow.config` or within the command line with two dashes `--min_primary_score=0.80`

#### Recommended to **range** the maximum number of nodes you are able to construct in a variant graph with `--max_nodes` equivilent to `vg construct -m <arg>`. Higher node sizes require additional resources. 

#### Parameter contents of `nextflow.config`
```groovy
nextflow run (main.nf|nf-vg-pipeline) --fasta </path/to//fasta> --vcf </path/to/vcf> <>
    fasta = null
    fai   = null
    vcf   = null
    tbi   = null
    fq    = null

    // vg construct
    max_nodes = 32

    // vg filter
    min_primary_score = 0.90
    norm_based_on_length = true
    use_sub_counts = true
    min_end_matches = 1
    min_map_qual = 15
    defray_ends = 999

    // vg pack
    min_mapping_quality = 5
    ignore_first_last_bps = 0
    expected_coverage = null

    // which genotyper do you want to use? both?
    // use freebayes
    enable_freebayes = true
    // use vg call
    enable_vgcall    = true

    // bcftools index
    enable_tbi = true

    // bcftools norm
    normalize_variants = true
    atomize_variants = true
    split_multiallelic = '-any'
    check_reference_alleles = 'w'

    // VCF Filtering Options
    fraction_missingness_list      = [0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95]
    minor_allele_count_list        = [3, 6, 9, 12, 15]
    fraction_genotypes_missing     = '.95'
    minor_allele_count             = '3'
    minimum_genotype_depth         = '5'
    maximum_genotype_depth         = null
```


