# JupyterLab + VS Code Hybrid (Professional) Setup Guide (macOS + uv)

This guide defines a **portable, reusable, per-repo** development setup optimized for:
- **JupyterLab-first exploration** (browser)
- **VS Code for engineering** (src/, tests, packaging, Git, CI)
- **uv + lockfile** for fast, deterministic installs
- Optional **Docker** scaffolding for container-first workflows

> **Multi-root workspace note:** If you have multiple repos under a parent folder, each repo should have its own `.venv` and its own `.vscode/settings.json` so the interpreter never “flips” on restart.

---

## SET-UP

### A. One-time prerequisites (host or container base)

#### 1) Python runtime strategy
Choose one:
- **Local-first:** Use `mise` to manage per-repo Python versions.
- **Container-first:** Pin Python in the container base image; still use `uv` + `.venv` per repo for isolation.

#### 2) Install Homebrew packages
```bash
brew update
brew upgrade
brew cleanup -s
brew doctor

brew install colima
brew install docker docker-compose

brew install git gh wget jq tree ripgrep fd fzf bat
brew install coreutils gnu-sed
brew install openssl readline zlib sqlite

brew install zsh-autosuggestions zsh-syntax-highlighting starship

brew install mise
echo 'eval "$(mise activate zsh)"' >>~/.zshrc
source ~/.zshrc

brew install uv
brew install pre-commit

# Useful for Jupyter/data workflows (optional but common)
brew install pandoc
brew install graphviz

brew install --cask visual-studio-code --appdir=~/Applications

brew doctor
brew cleanup -s
```

#### 3) VS Code extensions (hybrid pro setup)
Install these because VS Code is your “engineering layer” even if notebooks run in JupyterLab:
- Python
- Pylance
- Jupyter
- Python Debugger
- Dev Containers (only if you use container-first dev)
- Even Better TOML
- GitHub Copilot Chat (optional)
- GitHub Theme (optional)

If you also do Java in this same workspace:
- Extension Pack for Java
- Debugger for Java

---

## INITIALIZATION (Reusable Steps)

### Project repository initialization (JupyterLab + VS Code Hybrid)

#### 1) Create project folder and standard directories/files
```bash
mkdir my-jupyter-ai-project
cd my-jupyter-ai-project

mkdir -p src tests notebooks data docs
touch README.md
```

#### 2) Add `pyproject.toml` (root)
Your `pyproject.toml` should include:
- `[project].dependencies` for runtime libraries
- `[project.optional-dependencies].dev` for ruff/pytest/pre-commit/etc.
- `[project.optional-dependencies].jupyter` for `jupyterlab`, `ipykernel`, notebook tooling

#### 3) Add `.pre-commit-config.yaml` (root)
Place it at the repo root (same level as `.git/`, `pyproject.toml`, `README.md`).

#### 4) Add `.gitignore` (root)
Minimum notebook-related ignores:
```gitignore
.venv/
.env
__pycache__/
.ipynb_checkpoints/
data/
dist/
build/
*.egg-info/
```

#### 5) Create uv environment and pin VS Code interpreter (per repo)
```bash
uv venv
mkdir -p .vscode
touch .vscode/settings.json
```

Edit `.vscode/settings.json`:
```json
{
 "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
 "python.terminal.activateEnvironment": true
}
```

> **Multi-root workspace:** Put this file inside **each repo folder**, not only the parent folder.

#### 6) Create `.env` (root) for env-specific parameters (do not commit)
```bash
touch .env
```

#### 7) Bootstrap dependencies (first-time)
Since initialization assumes no `uv.lock` yet:
```bash
uv lock
uv sync --dev #--extra jupyter
```

#### 8) Register a Jupyter kernel for this repo (recommended)
This ensures JupyterLab and VS Code can both select the exact environment:
```bash
uv run python -m ipykernel install --user \
  --name my-jupyter-ai-project \
  --display-name "Python (my-jupyter-ai-project)"
```

#### 9) Initialize Git (or clone)
Fresh repo:
```bash
git init
git add -A
git commit -m "chore: initial scaffold"
```

Or clone:
```bash
gh repo clone <org>/<repo>
cd <repo>
```

#### 10) Install pre-commit hooks
```bash
uv run pre-commit install
uv run pre-commit run --all-files
```

#### 11) Add minimum Docker folder/files (optional but aligned with portability)
```bash
mkdir -p .docker
touch .docker/docker-compose.yaml
touch .docker/Dockerfile.dev
touch .docker/Dockerfile.prod  #can also be Dockerfile.runtime
```

#### 12) Resulting structure
```text
repo/
  .devcontainer/
  .docker/
  .git/
  .vscode/
  .venv/
  .env
  .gitignore
  .mise.toml
  .pre-commit-config.yaml
  pyproject.toml
  README.md
  uv.lock
  notebooks/
  src/
  tests/
  data/
  docs/
```

---

## JupyterLab Workflow (Day-to-day)

### Start JupyterLab using the uv environment
From repo root:
```bash
uv run jupyter lab --no-browser
```

If inside Docker/remote:
```bash
uv run jupyter lab --ip=0.0.0.0 --port 8888 --no-browser
```

### In JupyterLab
- Select kernel: **Python (my-jupyter-ai-project)**
- Keep reusable logic in `src/` (notebooks call into modules)
- Keep notebooks lean; avoid committing huge outputs unless necessary

---

## Continuous Delivery (Hybrid)

Use repo-root execution as your standard.

### Start of day / after pull
```bash
cd /workspaces/my-repo
uv sync --dev #--extra jupyter
```

### Inner loop (engineering gates)
```bash
uv run ruff check .
uv run pytest -q
```

### Commit/push
```bash
git add -A
git commit -m "..."
git push
```

### CI enforcement (same checks, deterministic)
```bash
uv sync --dev --extra jupyter
uv run pre-commit run --all-files
uv run pytest
```

---

## Optional: Professional notebook hygiene in Git
Recommended if notebooks are committed:
- Strip notebook outputs before commit (reduces noisy diffs)
- Enforce consistent formatting and basic checks via pre-commit

If you want, add `nbstripout` (or similar) into `.pre-commit-config.yaml`.
