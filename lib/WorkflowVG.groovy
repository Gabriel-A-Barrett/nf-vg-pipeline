import nextflow.Nextflow
import java.nio.file.Paths

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
}