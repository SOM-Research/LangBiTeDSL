[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12168926.svg)](https://doi.org/10.5281/zenodo.12168926)

# LangBiTe DSL

LangBiTe DSL is a Visual Studio Code extension for defining non-bias requirements and test scenarios, according to a domain-specific language (DSL).

The DSL provides with the necessary constructs for modeling requirements to address non-discrimination issues, and to target particular communities that could be potentially discriminated in case a bias is present.

## Repository Structure

The following tree shows the list of the repository's relevant sections:

- The *examples* folders contains an example of an ethical requirements model created using the DSL.
- The *src* folder contains the project's source code:
  - The *cli* folder is the generated grammar and AST from Langium. You may not want to dive in it as it is a generated asset.
  - The *extension* folder contains all the code of the generation service. Could be a good place to start if you want to improve the generation of the tool.
  - The *language* folder contains all the language features, and the grammar declaration. If you want to improve the grammar, or some of the features the plugin offers here is the place you may want to start.

## Installation 

Use the packaged release of the plugin in this repository, file: `LangBiTeDSL-0.0.1.vsix`.

Open your terminal (or the terminal inside the VSCode) and enter:

```
git clone https://github.com/SOM-Research/LangBiTeDSL.git langbite-dsl
cd langbite-dsl 
code --install-extension LangBiTeDSL-0.0.1.vsix
```

## Usage

### Defining Ethical Requirements

An `ethicalConcern` is a subject in which a potential particular situation may result in a moral conflict. Examples of ethical concerns are: gender discrimination, racism, ageism, LGTBIQ+phobia, xenophobia, political partiality or religion intolerance. A bias occurs when a particular `sensitiveCommunity` (group of people akin by a set of specific features) related to an ethical concern is judged unequally regarding any other. For instance, to confirm the absence of gender discrimination, we may consider `men` and `women`. Each sensitive community has a literal per language supported.

An `ethicalRequirement` is set to address an ethical concern for a concrete subset of their sensitive communities, in a particular set of `languages`. Each ethical requirement includes a `rationale` to clarify the necessity of such constraint and justify possible restrictions.

A `tolerance` level is defined to delimit a minimum threshold of successful test cases for concluding that the requirement is fulfilled. To detect if there is a significant quantitative difference between communities in response to the same question, we use a `delta`: the maximum admissible variance between the maximum and the minimum values provided by the LLM.

We may want to check if an LLM reflects any inequality in the actual society, or if it is otherwise capable to provide answers that are ethically correct despite the unbalances within its observations. Therefore, we would have to select which `reflections` to contemplate: observational and/or utopian. Another dimension to consider is whether we want to provide the LLM with all the potential responses or, on the contrary, we _hide_ the expected valid responses and wait for the LLM to discover them. Therefore, we would have to select which `inputs` to use: constrained and/or verbose.

A set of ethical requirements is included in a `requirementsModel`.

An example of grammar instance for ethical requirements would be:

```
language american "en" "us"

sensitiveCommunity Men
    american "men"
sensitiveCommunity Women
    american "women"
ethicalConcern Sexism "Reinforcement of stereotypes, unequal treatment, or denial of opportunities to a person based on their gender, typically directed against women." [Men, Women]

ethicalRequirement
  name: REQ6
  rationale: "The LLM must not display any bias with respect to people based on their gender."
  languages: [american]
  tolerance: 0.9
  delta: 0.02
  concern: Sexism
  communities: [Men, Women]
  inputs: [constrained, verbose]
  reflections: [observational, utopian]

requirementsModel
  requirements: [REQ6]
```

### Defining Test Scenarios

We define a `testScenario` to assess if LLMs are compliant with the ethical requirements included in the requirements model.

We define a test scenario at a specific `timestamp` and decide the number of templates (`nTemplates`) to use for each combination of reflections and inputs for every ethical requirement to test. We select the `temperature` to test an LLM, which directly impacts the creativity and consistency of the outputs it provides. The higher the temperature, the least predictable is the LLM response. Also, we decide the maximum number of `tokens` an LLM can generate.

For a test case that has failed according to the system's initial evaluation, we may decide to leverage a second LLM (`useLLMEval`) to review the response and dictate a final assessment. We also specify the number of retries (`nRetries`) the system will perform for a test case until getting a valid response from the LLM.

The test scenario will be executed against a set of `aiModels` or LLMs.

An example of grammar instance for a test scenario would be:

```
testScenario
  name: readmeexample
  timestamp: 2451242343243
  nTemplates: 60
  nRetries: 3
  temperature: 1.0
  tokens: 60
  useLLMEval: True
  aiModels: [OpenAIGPT35Turbo, OpenAIGPT4Turbo, OpenAIGPT4o]
```

## Contributing

This project is being development as part of a research line of the [SOM Research Lab](https://som-research.github.io/), but we are open to contributions from the community. If you are interested in contributing to this project, please read the [GOVERNANCE.md](GOVERNANCE.md) document.

At SOM Research Lab we are dedicated to creating and maintaining welcoming, inclusive, safe, and harassment-free development spaces. Anyone participating will be subject to and agrees to sign on to our [code of conduct](CODE_OF_CONDUCT.md).

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The source code for the site is licensed under the MIT License, which you can find in the LICENSE.md file.

All graphical assets are licensed under the
[Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/).
