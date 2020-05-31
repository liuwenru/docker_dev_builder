#!/usr/bin/env bash

mach=$(uname -m)
if [[ ${mach} == "x86_64" ]]; then
  arch1="amd64"
  arch2="x64"
elif [[ ${mach} == "aarch64" ]]; then
  arch1="arm64"
  arch2="arm64"
else
  # Skip install on any arch other than amd64 and arm64
  exit 0
fi
#
# VS Code Server
#
echo "* * *  Installing VS Code Server"
# Get the most recent version tags from the vscode repo
repo="microsoft/vscode"
version_count=3 # Get the most recent 3 versions
all_tags=$(git ls-remote --tags https://github.com/${repo}.git | grep 'refs/tags/[0-9]')
recent_tags=($(echo "${all_tags}" | sed 's|.*/||' | grep -v '\^' | sort -rV | head -n${version_count}))
newest_ver=""
for tag_ver in "${recent_tags[@]}"; do
  # Account for both lightweight and annotated tags
  lines=$(echo "${all_tags}" | grep "${tag_ver}")
  if [[ $(echo "${lines}" | wc -l) -eq 1 ]]; then
    tag_sha=$(echo "${lines}" | awk '{print $1}')
  else
    tag_sha=$(echo "${lines}" | grep "${tag_ver}\^{}" | awk '{print $1}')
  fi
  if [[ -z ${newest_ver} ]]; then
    newest_ver=${tag_sha}
  fi
  echo "Installing code-server ${tag_ver} - ${tag_sha}"
  curl -fsSLo /tmp/vscs.tgz "https://update.code.visualstudio.com/commit:${tag_sha}/server-linux-${arch2}/stable"
  mkdir -p ~/.vscode-server/bin/"${tag_sha}"
  pushd ~/.vscode-server/bin/"${tag_sha}" >/dev/null
  tar xzf /tmp/vscs.tgz --no-same-owner --strip-components=1
  popd >/dev/null
  rm -f /tmp/vscs.tgz
done
echo "newest_ver=${newest_ver}"

#
# VS Code extensions
#
echo "* * *  Installing VS Code Extensions"
extensions=(
  akamud.vscode-theme-onedark
  alefragnani.Bookmarks
  bierner.docs-view
  christian-kohler.path-intellisense
  donjayamanne.python-environment-manager
  donjayamanne.python-extension-pack
  DotJoshJohnson.xml
  EditorConfig.EditorConfig
  esbenp.prettier-vscode
  fabiospampinato.vscode-diff
  foxundermoon.shell-format
  GitHub.copilot
  GitHub.copilot-chat
  GitHub.remotehub
  golang.go
  Gruntfuggly.todo-tree
  hangxingliu.vscode-systemd-support
  hediet.vscode-drawio
  ipedrazas.kubernetes-snippets
  josetr.cmake-language-support-vscode
  KevinRose.vsc-python-indent
  lunuan.kubernetes-templates
  mhutchie.git-graph
  ms-azuretools.vscode-docker
  ms-dotnettools.vscode-dotnet-runtime
  ms-kubernetes-tools.vscode-kubernetes-tools
  ms-python.autopep8
  ms-python.python
  ms-python.vscode-pylance
  ms-vscode-remote.remote-containers
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode-remote.remote-wsl
  ms-vscode-remote.remote-wsl-recommender
  ms-vscode-remote.vscode-remote-extensionpack
  ms-vscode.azure-repos
  ms-vscode.cmake-tools
  ms-vscode.cpptools
  ms-vscode.cpptools-extension-pack
  ms-vscode.cpptools-themes
  ms-vscode.hexeditor
  ms-vscode.makefile-tools
  ms-vscode.remote-explorer
  ms-vscode.remote-repositories
  ms-vscode.remote-server
  ms-vscode.vscode-typescript-next
  naco-siren.gradle-language
  PKief.material-icon-theme
  quicktype.quicktype
  redhat.fabric8-analytics
  redhat.java
  redhat.vscode-xml
  redhat.vscode-yaml
  richardwillis.vscode-gradle-extension-pack
  tadayosi.vscode-makefile-outliner
  tamasfe.even-better-toml
  twxs.cmake
  VisualStudioExptTeam.vscodeintellicode
  vscjava.vscode-gradle
  vscjava.vscode-java-debug
  vscjava.vscode-java-dependency
  vscjava.vscode-java-pack
  vscjava.vscode-java-test
  vscjava.vscode-maven
  vscode-icons-team.vscode-icons
  wholroyd.jinja
  zenghongtu.vscode-asciiflow2
)

export PATH=${PATH}:~/.vscode-server/bin/${newest_ver}/bin
for extname in "${extensions[@]}"; do
  code-server --install-extension ${extname}
done
