import nextflow.Nextflow
import java.nio.file.Paths
import java.nio.file.Files
import java.util.ArrayList
import java.util.List

class WorkflowVG {

    public static ArrayList removeIdFromGroovyMap(meta, path) {    
        def metaf = [:]
        metaf.region = meta.region
        return [ metaf ] + path.flatten()
    }
    public static ArrayList insertIndvIdIntoChannel(meta, path) {    
        def metaf = [:]
        metaf.id = path[0].simpleName
        metaf.region = meta.region
        return [ metaf ] + path.flatten()
    }
    public static ArrayList convertFaiToBed(meta, faiFilePath) {
        // Constructing the output file path
        String bedFilePath = faiFilePath.toString().replace(".fai", ".bed").toString()

        try {
            List<String> bedLines = new ArrayList<>()
            
            // Read the FAI file and convert each line to BED format
           faiFilePath.eachLine { line ->
                def parts = line.split(/\t/)
                String refName = parts[0]
                String size = parts[1]
                bedLines.add("${refName}\t0\t${size}")
            }
            
            
            // Write the BED file
            Files.write(Paths.get(bedFilePath), bedLines)
            return [meta, bedFilePath]
        } catch (Exception e) {
            e.printStackTrace()
            return null
        }
    }
    public static ArrayList splitBedFile(params, log, bed) {
        def meta = bed[0]
        def inputLines = bed[1]

        def outputFilePath = inputLines.getParent() + '/split_bed_files'
        outputFilePath.mkdir()
        def outputFilePaths = []

        def linesPerFile = params.splitNLines
        def outputLines = []
        def fileCounter = 0

        inputLines.eachLine { line ->
            outputLines << line

            if (outputLines.size() == linesPerFile) {
                def outputFile = new File("${outputFilePath}/split_${fileCounter}.bed")
                outputFile.withWriter { writer ->
                    outputLines.each { outputLine ->
                        writer.writeLine(outputLine)
                    }
                }
                outputFilePaths << outputFile
                outputLines.clear()
                fileCounter++
            }
        }

        if (!outputLines.isEmpty()) {
            def outputFile = new File("${outputFilePath}/split_${fileCounter}.bed")
            outputFile.withWriter { writer ->
                outputLines.each { outputLine ->
                    writer.writeLine(outputLine)
                }
            }
            outputFilePaths << outputFile
        }

        return [meta, outputFilePaths]
    }
}