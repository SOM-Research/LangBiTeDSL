grammar EthicsMl


hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;
terminal STRING: /"[^"]*"|'[^']*'/;
terminal FLOAT returns number: /1.0|0.[0-9]+/;
terminal INT returns number: /[1-9][0-9]*/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

entry Model:
    (ethicalConcerns+=EthicalConcern | sensitiveCommunities+=SensitiveCommunity)+
    (ethicalRequirements+=EthicalRequirement)+
    //ethicalRequirementCombinations+=EthicalRequirementCombination |
    requirementsModel=RequirementsModel
    (testScenarios+=TestScenario)+;// |
    //aiModels+=AIModel)*;


// ************************************************
// *** MASTER: ETHICAL CONCERNS AND COMMUNITIES ***
// ************************************************

PromptType returns string: 'Open' | 'Adversarial';
AssessmentType returns string: 'Observational' | 'Utopian';

EthicalConcern:
    'ethicalConcern'
    name=ID
    description=STRING
    ('[' (communities+=[SensitiveCommunity:ID])
        ((','communities+=[SensitiveCommunity:ID])*']'))?;

SensitiveCommunity:
    'sensitiveCommunity'
    name=ID
    description=STRING;


// ****************************************************
// *** END-USER DEFINED: ETHICAL REQUIREMENTS MODEL ***
// ****************************************************

EthicalRequirement:
    'ethicalRequirement'
    'name:' name=ID
    'rationale:' rationale=STRING
    'severity:' severity=FLOAT
    'tolerance:' tolerance=FLOAT
    'delta:' delta=FLOAT
    ('cost:' cost=FLOAT)?
    'concern:' concern=[EthicalConcern:ID]
    ('communities:' '[' (communities+=[SensitiveCommunity:ID])
        ((','communities+=[SensitiveCommunity:ID])*']')?)?
    'prompts:' '[' prompts+=PromptType
        ((','prompts+=PromptType)*']')?
    'assessments:' '[' assessments+=AssessmentType
        ((','assessments+=AssessmentType)*']')?;

fragment Requirements:
    'requirements:' ('[' (requirements+=[EthicalRequirement:ID])
        ((','requirements+=[EthicalRequirement:ID])*']'))?;

EthicalRequirementCombination:
    'combination' Requirements;

RequirementsModel:
    'requirementsModel'
    //'name:' name=ID
    Requirements;


// ****************************************
// *** END-USER DEFINED: TEST SCENARIOS ***
// ****************************************

AIModel returns string:
    'HuggingFaceGPT2' | 'HuggingFaceGPT2Large' | 'HuggingFaceGPT2XLarge' |
    'HuggingChat' |
    'OpenAITextDaVinci002' | 'OpenAITextDaVinci003' |
    'OpenAIGPT35Turbo';

TestScenario:
    'testScenario'
    'name:' name=ID
    //'requirementsModel:' requirementsModel=[RequirementsModel:ID]
    'timestamp:' timestamp=INT // millis
    'numTests:' numTests=INT
    'temperature:' temperature=FLOAT
    ('tokens:' tokens=INT)?
    'aiModels:' '[' (aiModels+=AIModel)
        ((','aiModels+=AIModel)*']')?;
