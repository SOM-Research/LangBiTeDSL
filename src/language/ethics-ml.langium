grammar EthicsMl


terminal ID: /[_a-zA-Z][\w_]*/;
//terminal BOOLEAN: /true|false/;
terminal STRING: /"[^"]*"|'[^']*'/;
terminal FLOAT returns number: /1.0|0.[0-9]+/;
terminal INT returns number: /[1-9][0-9]*/;


hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

entry Model:
    (languages+=Language)+
    (ethicalConcerns+=EthicalConcern | sensitiveCommunities+=SensitiveCommunity)+
    (ethicalRequirements+=EthicalRequirement)+
    //ethicalRequirementCombinations+=EthicalRequirementCombination |
    requirementsModel=RequirementsModel
    (testScenarios+=TestScenario)+;// |
    //aiModels+=AIModel)*;


// ************************************************
// *** MASTER: ETHICAL CONCERNS AND COMMUNITIES ***
// ************************************************

BOOLEAN returns string: 'True' | 'False';

// PromptType returns string: 'Open' | 'Adversarial';
// AssessmentType returns string: 'Observational' | 'Utopian';
InputKind returns string: 'constrained'|'verbose';
ReflectionKind returns string: 'observational'|'utopian';

EthicalConcern:
    'ethicalConcern'
    name=ID
    description=STRING
    ('[' (communities+=[SensitiveCommunity:ID])
        ((','communities+=[SensitiveCommunity:ID])*']'))?;

SensitiveCommunity:
    'sensitiveCommunity'
    name=ID
    (description=STRING)?
    literals+=(SensitiveCommunityLiteral)+;

SensitiveCommunityLiteral:
    language=[Language:ID]
    literal=STRING;


// ****************************************************
// *** END-USER DEFINED: ETHICAL REQUIREMENTS MODEL ***
// ****************************************************

Language:
    'language'
    name=ID
    code=STRING
    region=STRING;

EthicalRequirement:
    'ethicalRequirement'
    'name:' name=ID
    'rationale:' rationale=STRING
    'languages:' ('[' (languages+=[Language:ID])
        ((','languages+=[Language:ID])*']'))?
    'tolerance:' tolerance=FLOAT
    'delta:' delta=FLOAT
    'concern:' concern=[EthicalConcern:ID]
    ('communities:' '[' (communities+=[SensitiveCommunity:ID])
        ((','communities+=[SensitiveCommunity:ID])*']')?)?
    'inputs:' '[' inputs+=InputKind
        ((','inputs+=InputKind)*']')?
    'reflections:' '[' reflections+=ReflectionKind
        ((','reflections+=ReflectionKind)*']')?;

fragment Requirements:
    'requirements:' ('[' (requirements+=[EthicalRequirement:ID])
        ((','requirements+=[EthicalRequirement:ID])*']'))?;

RequirementsModel:
    'requirementsModel'
    //'name:' name=ID
    Requirements;


// ****************************************
// *** END-USER DEFINED: TEST SCENARIOS ***
// ****************************************

AIModel returns string:
    'HuggingFaceFlanT5Base' | 'HuggingFaceFlanT5Large' | 'HuggingFaceFlanT5XXL' |
    'HuggingFaceMT5Base' | 'HuggingFaceMT5Large' |
    'HuggingFaceGemma2BIT' |
    'HuggingFaceMistral7B02Instruct' | 'HuggingFaceMistral7B01' | 'HuggingFaceMixtral8x7B01Instruct' |
    'HuggingFaceFalcon7BInstruct' |
    'Llama27BChat' | 'Llama213BChat' | 'Llama270BChat' |
    'OpenAIGPT35Turbo' | 'OpenAIGPT35Turbo0613' | 'OpenAIGPT35Turbo1106' |
    'OpenAIGPT40613' | 'OpenAIGPT4' | 'OpenAIGPT4Turbo' | 'OpenAIGPT4o';

TestScenario:
    'testScenario'
    'name:' name=ID
    //'requirementsModel:' requirementsModel=[RequirementsModel:ID]
    'timestamp:' timestamp=INT // millis
    'nTemplates:' nTemplates=INT
    'nRetries:' nRetries=INT
    'temperature:' temperature=FLOAT
    ('tokens:' tokens=INT)?
    'useLLMEval:' useLLMEval=BOOLEAN
    'aiModels:' '[' (aiModels+=AIModel)
        ((','aiModels+=AIModel)*']')?;
