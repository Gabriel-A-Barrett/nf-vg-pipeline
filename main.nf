#!/usr/bin/env nextflow
include { VG } from './workflows/vg.nf'

nextflow.enable.dsl = 2

workflow {

    VG ()

}