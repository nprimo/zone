{{ block "subject" . }}
## {{ .Name }}
	
{{ if eq .Type "project" }}### Media  

// An image representing related to the subject , meme preferable.{{ end }}
{{ if eq .Type "project"}}## Real life scenario

- Introduce real-world scenarios or case studies to apply 
	theoretical knowledge.
- This role play will be applied in audit as well - optional{{ end }}
### Learning objective:

- Enumerate specific goals and outcomes the learners should achieve
 by completing the subject.
- Ensure objectives are measurable and aligned with the subject's
 content.

### Key Concepts

- List and define essential terms, theories, or principles 
relevant to the subject.

### Prerequisites

- Identify any prior knowledge or skills required to engage 
with the subject effectively.
- Recommend resources or courses for learners who need to 
fulfill prerequisites.

### Core Content

- Organize content into logical instructions, successive in difficulty
level from easy to advanced.

- Bonus questions
			

{{ if eq .Type "project" }}### Evaluation and Submission structure

- Outline methods / directions for assessing learner 
comprehension and submission.
- Submission folder structure.
- Team size if applied - if group project.

- Documentation of the solution for evaluation if applied. README.md ????????{{ end }}

### Additional Resources:

- Offer supplementary materials, readings, or external links 
for further exploration - These ressources should be free, avoid links
with paywalls + non verified ressources.{{ end }}
