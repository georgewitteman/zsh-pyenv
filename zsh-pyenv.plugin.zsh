#!/usr/bin/env zsh

pyenv_zsh_refresh() {
  # From https://github.com/pyenv/pyenv#choosing-the-python-version
  if [[ -n "$PYENV_VERSION" ]]; then
    PYENV_ZSH_PYTHON_VERSIONS+=("$PYENV_VERSION")
    return
  fi

  local working_dir="$PWD"
  until [[ -f "$working_dir/.python-version" ]] || [[ "$working_dir" = "/" ]]; do
    working_dir="${working_dir:a:h}"
  done

  local version_file="$working_dir/.python-version"
  if [[ ! -f "$version_file" ]]; then
    version_file="$PYENV_ROOT/version"
  fi

  if [[ -f "$version_file" ]]; then
    # This is the fastest way to read a file into zsh. Using cat or another
    # program will start a subshell and is much slower. See
    # georgewitteman/zsh-prompt for some scripts that test the speed.
    PYENV_ZSH_PYTHON_VERSIONS=("${(f)$(<$version_file)}")
  else
    PYENV_ZSH_PYTHON_VERSIONS=()
  fi

  path=(${path:#$PYENV_ROOT/versions/*})
  path=(${path:#$PYENV_ROOT/shims})

  # (Oa) reverses the array (O = reverse of the order specified in the next flag,
  # a = normal array order)
  local version
  for version in ${(Oa)PYENV_ZSH_PYTHON_VERSIONS}; do
    local entry="$PYENV_ROOT/versions/$version/bin"
    if [[ -d "$entry" ]]; then
      path=("$entry" $path)
    fi
  done
}

# Set up the initial $path during shell initialization
pyenv_zsh_refresh

preexec_functions+=(pyenv_zsh_refresh)
