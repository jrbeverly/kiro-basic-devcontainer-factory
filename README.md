# kiro-basic-devcontainer-factory

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

> [!WARNING]
> This experiment is effectively abandoned. The generated material is retained primarily as a research artifact.

Explores a Kiro-driven factory that reads an epic, breaks it into individual work items, and runs each one as a Kiro session inside the target repository's Dev Container, recording what it hits to `AI_NOTES`.

```sh
bash bootstrap.sh
bash smoke.sh
bash pdlc.sh ACME-1234
bash execute.sh ACME-1234
bash stash.sh ACME-1234
bash validate-branching.sh
```

## Shape

`epics/<epic-id>.md` is written by hand: a goal, the constraints it has to hold to, the open questions, and the stories as high-level outcomes. `pdlc.sh` turns it into `plans/<epic-id>/NN-<slug>.md`, one file per work item, ordered by the number prefix. `execute.sh` walks those files in order and gives each one to its own Kiro session.

The top level holds only the executors: `bootstrap.sh`, `smoke.sh`, `pdlc.sh`, `execute.sh`, `stash.sh`, `validate-branching.sh`. `lib/` holds the branching and Dev Container operations they share, and `prompts/` holds every prompt the factory sends, rendered with `envsubst`.

`references/` is the starting point and `repos/` is the working copy. Kiro never runs in the workspace container; every session runs inside the repository's own Dev Container, and the factory drives those containers, owns the git branches, and collects what the sessions produce.

A reference carries the conventions its sessions have to write to, in `.kiro/steering/*.md`, referenced from `.kiro/agents/factory.json` and named again in the prompts. The epic and the plans say what to build; the steering says what the result has to look like, so neither has to repeat it.

`references/acme-iac` is shaped as a module: `versions.tf`, `variables.tf` and `outputs.tf` are stubbed, no provider is configured at the root, and `examples/default` is the deployable configuration a check reads its values out of with `terraform output`.

Each `execute.sh` run takes the next number under `AI_NOTES/<epic-id>/`, so notes land in `AI_NOTES/<epic-id>/<run>/<work-item>.md` and a run never appends to an earlier one. `.factory/` is cleared in the repository before the run and after every work item. `stash.sh` then freezes the run into `samples/<epic-id>/<run>/`: the repository, the work items it carried out, and the notes it wrote, so runs can be compared as the prompts and steering change.

`references/` holds three repositories of the same shape: `acme-iac`, the target of ACME-1234, `acme-transcribe`, the target of ACME-12345, and `acme-waf`, stubbed for an epic not yet written. Each carries its own copy of the steering, so a repository that needs a rule the others do not — `acme-transcribe` keeps helpers in `scripts/` — says so in its own copy rather than in a shared one.

## Notes

- effort to create an extremely lightweight AI Factory / Hero
- goal; small modular factory rather than large general-purpose system
- current Factory is much broader; many use cases/capabilities
- this experiment aimed for minimal rhythm; input → plan → execute
- keep structure as basic as possible
- main learning; system seems to benefit heavily from iteration looping
- build first version
- give it a real task
- observe where it fails badly
- use that failed implementation as reference material
- rebuild/refine against same or different task
- repeat loop
- repeated iterations seem to improve the system more effectively than designing everything up front
- each pass cuts waste, unnecessary machinery, over-engineering, bad assumptions
- task pressure reveals what the system actually needs
- repeated question becomes; do I really need this component/process to complete the task?
- refinement loop gradually reduces excess while preserving useful capability
- potentially valuable direction for evolving the Factory architecture
- useful as a starter/bootstrap model
- current implementation on its own still does not fully reach the desired end state
