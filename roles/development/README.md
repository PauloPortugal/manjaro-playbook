# Development Role

Development tools and programming language environments for software engineering.

## Description

The `development` role installs a comprehensive development stack including:
- Programming languages (Go, Node.js, Ruby, Scala, Clojure)
- Build tools (Maven, Gradle, SBT, Leiningen)
- Container tools (Docker, Docker Compose, Kubernetes)
- Cloud tools (AWS CLI, Terraform)
- Code editors configuration (Emacs)
- OCR tools (Tesseract)
- Version control enhancements
- Database tools (DBeaver, MongoDB, Robo3T)

## Requirements

- Manjaro/Arch Linux system
- `sudo` privileges
- `base` role completed (provides utilities)
- Internet connection
- Sufficient disk space (~5-10 GB for all tools)

## Variables

All variables are defined in `group_vars/all`:

### Package Lists

| Variable | Type | Description |
|----------|------|-------------|
| `developer_stack` | list | Dev tools from official repos |
| `developer_stack_aur` | list | Dev tools from AUR |
| `tesseract` | list | OCR engine and language data |

### User Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `user_name` | Yes | Username for configuration |

## Dependencies

- `base` role - Provides essential utilities

## Tasks

### Main Tasks (tasks/main.yml)

1. **Install Developer Tools**
   - Installs packages from `developer_stack` list
   - Includes: ansible, docker, go, jdk, kubectl, maven, terraform, etc.

2. **Configure Go**
   - Imports `go.yml` tasks
   - Sets up Go workspace and environment

3. **Install AUR Developer Tools**
   - Installs packages from `developer_stack_aur` list
   - Uses custom AUR installation script
   - Includes: AWS CLI, MongoDB tools, Lens, Postman, etc.

4. **Install Node Version Manager (NVM)**
   - Imports `nvm.yml` tasks
   - Installs NVM for Node.js version management

5. **Configure Docker**
   - Imports `docker-config.yml` tasks
   - Adds user to docker group
   - Enables docker service

6. **Configure Emacs**
   - Imports `emacs-config.yml` tasks
   - Sets up Emacs Prelude configuration

7. **Configure Tesseract**
   - Imports `tesseract.yml` tasks
   - Installs OCR engine and language data

## Installed Packages

### Official Repositories (developer_stack)

**Core Development:**
- ansible, ansible-lint - Infrastructure as code
- docker, docker-compose - Containerization
- git - Version control (from base role)

**Programming Languages:**
- go, go-tools - Go language
- ruby - Ruby language
- clojure - Clojure language
- jdk8-openjdk, jdk11-openjdk, jdk17-openjdk - Java SDKs
- jre8-openjdk, jre11-openjdk, jre17-openjdk - Java runtimes

**Build Tools:**
- maven - Java build tool
- gradle - Build automation
- sbt - Scala build tool
- leiningen - Clojure build tool
- npm, yarn - JavaScript package managers

**Cloud & Infrastructure:**
- kubectl - Kubernetes CLI
- kubectx - Kubernetes context switcher
- minikube - Local Kubernetes
- terraform - Infrastructure as code

**Utilities:**
- hub - GitHub CLI helper
- jq, go-yq - JSON/YAML processors
- dbeaver - Database GUI

### AUR (developer_stack_aur)

**Cloud Tools:**
- aws-cli-v2-bin - AWS command line
- aws-session-manager-plugin - AWS SSM
- google-cloud-sdk - (from cloud role)

**Container & Kubernetes:**
- lens-bin - Kubernetes IDE
- kubefwd-bin - Kubernetes port forwarding

**Go Tools:**
- golangci-lint - Go linter
- go-swagger-bin - Swagger/OpenAPI for Go
- nancy-bin - Dependency vulnerability scanner

**Databases:**
- mongodb-bin, mongodb-tools-bin - MongoDB database
- mongosh-bin - MongoDB shell
- robo3t-bin - MongoDB GUI

**Development Tools:**
- postman-bin - API testing
- nvm - Node version manager
- heroku-cli - Heroku deployment
- scala - Scala language
- tfswitch-bin - Terraform version manager

## Subtasks

### Go Configuration (tasks/go.yml)
- Sets up GOPATH
- Configures Go workspace
- Sets environment variables

### NVM Installation (tasks/nvm.yml)
- Fetches latest NVM version from GitHub
- Installs NVM for user
- Configures shell integration
- **Note**: Requires shell restart to use

### Docker Configuration (tasks/docker-config.yml)
- Adds user to `docker` group
- Enables and starts docker service
- **Note**: Requires logout/login for group changes

### Emacs Configuration (tasks/emacs-config.yml)
- Checks for existing Emacs Prelude configuration
- Installs Emacs Prelude if not present
- Sets up Emacs modules

### Tesseract (tasks/tesseract.yml)
- Installs Tesseract OCR engine
- Installs English language data
- Ready for text recognition tasks

## Tags

- `development` - All development role tasks
- `dev-tools` - Official repository tools
- `dev-tools-aur`, `development-aur` - AUR tools
- `aur` - All AUR-related tasks

## Example Usage

### Install complete development stack

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags development \
  --ask-become-pass
```

### Install only official repo tools (skip AUR)

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags dev-tools \
  --skip-tags aur \
  --ask-become-pass
```

### Install only AUR development tools

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags dev-tools-aur \
  --ask-become-pass
```

## Post-Installation

### Docker

After installation, logout and login for docker group membership:

```bash
# Verify docker group
groups | grep docker

# Test docker
docker run hello-world
```

### NVM (Node Version Manager)

After installation, restart your shell or source the profile:

```bash
# Source NVM
source ~/.nvm/nvm.sh

# Install Node.js
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

### Go

Verify Go installation:

```bash
go version
go env GOPATH
```

### Kubernetes Tools

```bash
# Verify kubectl
kubectl version --client

# Start minikube
minikube start

# Verify
kubectl cluster-info
```

## Common Workflows

### Java Development

Multiple JDK versions installed. Switch between them:

```bash
# List available Java versions
archlinux-java status

# Set default
sudo archlinux-java set java-17-openjdk

# Verify
java -version
```

### Docker Development

```bash
# Build image
docker build -t myapp .

# Run container
docker run -p 8080:8080 myapp

# Use docker-compose
docker-compose up
```

### Go Development

```bash
# Create Go project
mkdir -p ~/go/src/myproject
cd ~/go/src/myproject

# Initialize module
go mod init myproject

# Build
go build
```

### Node.js Development with NVM

```bash
# Install specific Node version
nvm install 18
nvm install 20

# Switch versions
nvm use 18

# List installed versions
nvm list
```

## Troubleshooting

### Docker Permission Denied

```bash
# Ensure user is in docker group
groups | grep docker

# If not, re-login or:
newgrp docker

# Test
docker ps
```

### NVM Command Not Found

```bash
# Source NVM in your shell profile
echo 'source ~/.nvm/nvm.sh' >> ~/.zshrc
source ~/.zshrc

# Or for bash
echo 'source ~/.nvm/nvm.sh' >> ~/.bashrc
source ~/.bashrc
```

### Kubernetes Tools

```bash
# Start minikube if not running
minikube start

# Check status
minikube status

# Stop minikube
minikube stop
```

### AUR Package Installation Issues

```bash
# Check if package exists
pamac search <package-name>

# Try manual installation
pamac build <package-name>

# Check for conflicts
pamac list | grep <package-name>
```

## Notes

- **Disk Space**: This role installs many tools; ensure adequate disk space
- **Time**: First run can take 15-30 minutes depending on connection
- **Docker**: Requires logout/login for group membership to take effect
- **NVM**: Requires shell restart to be available in PATH
- **Java**: Multiple JDK versions can coexist; use `archlinux-java` to switch

## Security Considerations

- Docker daemon runs with root privileges
- Review AUR PKGBUILDs before installation
- Keep tools updated regularly
- Use `tfswitch` to manage Terraform versions securely

## Author

Paulo Portugal

## License

See LICENSE file in repository root.
