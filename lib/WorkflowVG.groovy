import nextflow.Nextflow
import java.nio.file.Paths

class WorkflowVG {

    public static ArrayList createMetaMap(meta, path) {    
        def metaf = [:]
        metaf.id = meta.id
        metaf.region = path.name.toString().tokenize('.')[0].tokenize('_')[-1]

        return [metaf, path]

    }
}