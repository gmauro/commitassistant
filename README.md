# Git Commit Message Assistant

This script automates the generation of git commit messages using a Large Language Model (LLM). It leverages the `llm` command-line tool from [Datasette](https://llm.datasette.io/en/stable/) and its plugins, along with the `ollama` library to interact with a local LLM.

The current prompt has been assembled to produce commit messages that adhere to the Conventional Commits format (https://www.conventionalcommits.org/en/v1.0.0/).

## Features
- Automatically generates a commit message based on the changes in the repository.
- Configurable LLM model and prompt template.
- User confirmation before committing the changes.

## Dependencies

- [llm](https://llm.datasette.io/en/stable/)
- [Ollama](https://ollama.ai/)
- `mistral-nemo` model

## Installation

1. **Install llm and its plugins**:
   ```bash
   pip install llm llm-ollama
   ```

2. **Install Ollama**:
   Follow the instructions on the [Ollama website](https://ollama.ai/) to install the necessary dependencies.

3. **Download the `mistral-nemo` model**:
   Ensure you have the `mistral-nemo:12b-instruct-2407-q3_K_L` model available and configured for use with the `llm` command-line tool.
   You can pull the model from Ollama
   ```bash
   ollama pull mistral-nemo:12b-instruct-2407-q3_K_L
   ```

## Usage

1. **Clone the repository**:
   ```bash
   git clone https://github.com/gmauro/commitassistant.git
   cd commitassistant
   ```

2. **Make the script executable**:
   ```bash
   chmod +x commit.sh
   ```

3. **Run the script**:
   ```bash
   ./commit.sh
   ```

4. **Configure the script (optional)**:
   - **Model**: Modify the `MODEL` variable at the top of the `commit.sh` script to use a different LLM model.
   - **Prompt Template**: Modify the `PROMPT_TEMPLATE` variable to customize the prompt message.


5. **Add the script to your PATH (optional)**:
   ```bash
   export PATH=$PATH:/path/to/commitassistant/
   ```
   Replace `/path/to/commitassistant/` with the actual path to the directory containing the `commit.sh` script.


6. **Edit the message (optional)**:

   After the commit has been made, you can edit the commit message using `git commit --amend` if needed.


## Example

```bash

# Add the script to your PATH
export PATH=$PATH:/path/to/commitassistant/

# Navigate to your git repository
cd /path/to/your/repo

# add your changes to the staging area
git add .

# Run the commit script
commit.sh
```

The script will:
1. Check if the current directory is a git repository.
2. Check for any changes in the repository.
3. Generate a commit message using the configured LLM model and prompt template.
4. Display the generated commit message and ask for user confirmation.
5. Commit the changes if the user confirms.

## Configuration

- **Model**: Set the `MODEL` environment variable to use a different LLM model.
  ```bash
  export MODEL="your-model-name"
  ```

- **Prompt Template**: Set the `PROMPT_TEMPLATE` environment variable to customize the prompt message.
  ```bash
  export PROMPT_TEMPLATE="Your custom prompt message here."
  ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

