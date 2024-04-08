import { AstNode, LangiumParser} from 'langium';
import { createEthicsMlServices } from '../language/ethics-ml-module.js';
import { Model, isModel } from '../language/generated/ast.js';
import { NodeFileSystem } from 'langium/node';


export interface Generator {
    // Load the Abstract Syntax Tree of the .ethics active file
    generate(model : string | AstNode) : string | undefined;
    // Receives the parsed AST, generates the JSON string, and returns it
    model2Json(model : Model) : string | undefined;
}
 
/**
* JSON generator service main class
*/
export class DocumentationGenerator implements Generator {

    private readonly parser: LangiumParser;

    constructor() {       
        const services = createEthicsMlServices(NodeFileSystem);
        this.parser = services.EthicsMl.parser.LangiumParser;
    }

    generate(model : string) : string | undefined { // | AstNode) : string | undefined {
        //const astNode = (typeof(Model) == 'string' ? this.parser.parse(Model).value : Model);
        //return (isModel(astNode) ? this.model2Html(astNode) : undefined);
        const astNode = this.parser.parse(model).value;
        return (isModel(astNode) ? this.model2Json(astNode) : undefined);
    }

    // Generation of the output JSON string
    model2Json(model : Model) : string | undefined {

        //if (!isTestScenario(model.testScenario)) return undefined;
        //if (!isRequirementsModel(model.testScenario.requirementsModel)) return undefined;

        const testScenario = model.testScenarios[0];
        const requirementsModel = model.requirementsModel;
        const requirements = model.ethicalRequirements;

        // collect all requirements from the model in an array,
        // so that it could be assigned to the scenario Object and be JSON.stringified
        let modelReqIds = requirementsModel.requirements.map(r => r.$refText);
        let reqs = new Array();
        modelReqIds.forEach(function(reqId: string) {
            let req = requirements.find(r => r.name === reqId);
            if (req != undefined) {
                const requirement = {
                    name: req.name,
                    rationale: req.rationale,
                    languages: req.languages.map(c => c.$refText), // get the name:IDs of the referenced Languages
                    tolerance: req.tolerance,
                    delta: req.delta,
                    concern: req.concern.$refText, // get the name:ID of the referenced EthicalConcern
                    communities: req.communities.map(c => c.$refText), // get the name:IDs of the referenced SensitiveCommunities
                    inputs: req.inputs,
                    reflections: req.reflections
                };
                reqs.push(requirement);    
            }
        });
        
        const scenario = {
            timestamp : testScenario.timestamp,
            nTemplates : testScenario.nTemplates,
            nRetries : testScenario.nRetries,
            temperature : testScenario.temperature,
            tokens : testScenario.tokens,
            useLLMEval : testScenario.useLLMEval,
            aiModels : testScenario.aiModels,
            requirements : reqs
        };

        return JSON.stringify(scenario);
    }
}
 