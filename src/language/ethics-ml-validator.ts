import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { Model, EthicalRequirement, EthicsMlAstType } from './generated/ast.js';
import type { EthicsMlServices } from './ethics-ml-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: EthicsMlServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.EthicsMlValidator;
    const checks: ValidationChecks<EthicsMlAstType> = {
        // Well-formed rules
        // 1. Selected communities for a requirement are of its concern
        EthicalRequirement: validator.checkCommunitiesAreOfEthicalConcern,
        // 2. Unique IDs for each entity
        Model: [validator.checkEthicalConcernsAreUnique, validator.checkSensitiveCommunitiesAreUnique, validator.checkEthicalRequirementsAreUnique]
    };
    registry.register(checks, validator);
}


export class EthicsMlValidator {

    checkCommunitiesAreOfEthicalConcern(req: EthicalRequirement, accept: ValidationAcceptor): void {
        const concern = req.concern;
        const concernCommunities = concern.ref?.communities.map(c => c.$refText);

        if (concernCommunities == undefined) return;

        req.communities.forEach(c => {
            if (!concernCommunities.includes(c.$refText)) {
                accept(
                    'error',
                    `Sensitive community '${c.$refText}' does not belong to ethical concern '${concern.$refText}' communities.`,
                    {node: req, property: 'name'});
            }
        });
    }

    checkEthicalConcernsAreUnique(model: Model, accept: ValidationAcceptor): void {
        this.checkElementsAreUnique(model, accept, model.ethicalConcerns);
    }

    checkSensitiveCommunitiesAreUnique(model: Model, accept: ValidationAcceptor): void {
        this.checkElementsAreUnique(model, accept, model.sensitiveCommunities);
    }

    checkEthicalRequirementsAreUnique(model: Model, accept: ValidationAcceptor): void {
        this.checkElementsAreUnique(model, accept, model.ethicalRequirements);
    }

    checkElementsAreUnique(model: Model, accept: ValidationAcceptor, elements: any[]): void {
        const reported = new Set();
        elements.forEach(e => {
            if (reported.has(e.name)) {
                accept('error', `Element '${e.$type}' has non-unique name: '${e.name}'.`,  {node: e, property: 'name'});
            }
            reported.add(e.name);
        });
    }
}
