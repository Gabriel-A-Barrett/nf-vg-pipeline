#!/usr/bin/env nextflow
include { VARIANT_GRAPH_WORKFLOW } from './workflows/vg_workflow.nf'

nextflow.enable.dsl = 2

workflow {

    VARIANT_GRAPH_WORKFLOW ()

}