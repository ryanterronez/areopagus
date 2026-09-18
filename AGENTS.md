# Repository instructions

## Project documentation

- `PROJECT_STATUS.md` is the canonical concise snapshot of current project
  progress, architecture decisions, active work, next steps, and blockers.
- Keep `PROJECT_STATUS.md` current whenever a change materially affects project
  progress, architecture, completed milestones, active work, or next steps.
- Keep `README.md` focused on project purpose, repository orientation, and
  user/developer instructions; do not duplicate status history there.

## Local Python

- Use Windows Command Prompt (`cmd`) for local command examples and commands.
- Use the Python version selected by pyenv. Create the project environment with
  `pyenv exec python -m venv .venv`.
- Always activate `.venv` before running local Python tools, dependencies,
  tests, or the application: `.venv\Scripts\activate.bat`.
- Do not use the system Python or install Python dependencies globally for this
  repository.
