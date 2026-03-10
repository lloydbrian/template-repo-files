# Python Project Dev Workflow
*** This is for scenarios where pyproject.toml and other config files exists for ready usage ***
*** This works for container-first approach, but it also works perfectly in the local set-up ***

## SET-UP
### A. One-time pre-requisites (host or container base) - This is for the development environment.
#### 1. Install python in container base image or via mise locally
#### 2. Install brew packages
```
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
brew install --cask font-jetbrains-mono-nerd-font   # or any Nerd Font
brew install mise
echo 'eval "$(mise activate zsh)"' >>~/.zshrc
source ~/.zshrc
brew install uv
brew install pre-commit
brew install --cask visual-studio-code --appdir=~/Applications
brew doctor
brew cleanup -s
```

- `uv` = uv is a modern Python package manager and environment tool created by Astral (the team behind Ruff). It’s designed to be a faster, cleaner, and more ergonomic replacement for tools like pip, pipx, `virtualnv, and sometimes even poetry or pipenv. It has become popular because it dramatically speeds up Python workflows and simplifies environment management.
- `wget` = command-line file downloader  
- `jq` = JSON processor (example: curl -s https://api.github.com/repos/homebrew/brew | jq '.stargazers_count')  
- `tree` = directory tree viewer  
- `ripgrep (rg)` = fast text search for text inside files, used to search codebases  
- `fd` = modern alternative to find
- `fzf` — fuzzy finder is an interactive fuzzy search tool (search files, search command history, build interactive menus, integrate with git, ripgrep, fd, and etc.)
- `bat` — enhanced cat, bat is like cat, but with syntax highlighting, line numbers, git integration, paging

#### 3. Configure Terminal or Console

Copy templates:
```
cp ../template-terminal/starship.toml ~/.config/starship.toml #copy template to .config
cat ../template-terminal/starship_zsh_integration.zsh >> ~/.zshrc #append starship config to zsh
source ~/.zshrc
```

Install font to your terminal:
Terminal.app (macOS default):
```
Terminal → Settings → Profiles
Click Change... next to the font
Search JetBrainsMono Nerd Font → select it
```

VS Code integrated terminal:
Update settings.json and add line if does not exist
```
"terminal.integrated.fontFamily": "JetBrainsMono Nerd Font" 
```

#### 4. Install visual studio code extensions
```
GitHub Copilot Chat
Dev Containers
Python
Pylance
Python Debugger
Extension Pack for Java
Debugger for Java
Even Better TOML
GitHub Theme
```


## INITIALIZATION (Reusable Steps)
### Project Repository Initialization

#### 1. Create folder for the project and standard directory/files
```
mkdir my-ai-intelligence-project
cd my-ai-intelligence-project
mkdir src
mkdir tests
touch README.md
```


#### 2. Put `pyproject.toml` to the root project folder. This toml file contains all baseline python packages required for the project. During official initialization, those packages will be installed. 

#### 3. Put `.pre-commit-config.yaml` in the root of your Git repository (same level as .git/, pyproject.toml, README.md). Put `.mise.toml` file in the root of your Git repository (same level as .git/, pyproject.toml, README.md).

```
repo/
    .devcontainer/
    .docker/
    .git/
    .env
    .gitignore
    .mise.toml
    .pre-commit-config.yaml
    pyproject.toml
    README.md
    src/
    tests/
```

Why repo root?
	• pre-commit looks for .pre-commit-config.yaml starting from the current directory and walking up; the root is the standard, unambiguous place.
	• The config should be version-controlled and shared by everyone who clones the repo.

Important distinction: config file vs “installation”

	• The YAML file is committed to the repo.
	• The actual hook is installed into your local checkout here:
	• .git/hooks/pre-commit

You install the hook by running (from repo root): Why repo root?

	• pre-commit looks for .pre-commit-config.yaml starting from the current directory and walking up; the root is the standard, unambiguous place.
	• The config should be version-controlled and shared by everyone who clones the repo.


Important distinction: config file vs “installation”

	• The YAML file is committed to the repo.
	• The actual hook is installed into your local checkout here:
	• .git/hooks/pre-commit

#### 4. Put `.gitignore` in the root of your Git repository (same level as .git/, pyproject.toml, README.md). 

#### 5. Run uv env command and setup Visual Studio Code interpreter
```
uv venv
mkdir .vscode
cd .vscode
touch settings.json
```

Edit .vscode/settings.json file and add these:
```
{
 "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
 "python.terminal.activateEnvironment": true
}
```

Go back to the root repo folder and create .env file. This is for env-specific parameters
```
cd ..
touch .env
```


#### 6. Since this is initialization, it is assumed you have no uv.lock file. As such, run the command below (bootstrapping)
```
uv lock
uv sync --dev
```

#### 7. Clone a git project. Sample below or start a fresh project
```
gh repo clone github/gitignore
```

#### 8. run pre-commit install command while in the project folder
```
uv run pre-commit install
uv run pre-commit run --all-files
```

#### 9. Set-up minimum docker folder/files by executing this command at the root repo folder
```
mkdir .docker
cd .docker
touch docker-compose.yaml
touch Dockerfile.dev
cd ..
```

#### 10. The underlying project structure should look like:
```
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
    src/
    tests/
```

## Continuous Delivery
### Recommended pattern for your container-first workflow
Recommended pattern for your container-first workflow
Use repo-root execution as your standard:

```
cd /workspaces/my-repo
uv sync --dev
uv run ruff check .
uv run pytest -q
git add -A
git commit -m "..."
git push

uv sync --dev
uv run pre-commit run --all-files
uv run pytest
```