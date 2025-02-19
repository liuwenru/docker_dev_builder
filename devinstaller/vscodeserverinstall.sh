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
repo="microsoft/vscode"
needver="1.85.2"
needtagsha=$(git ls-remote --tags https://github.com/${repo}.git | grep 'refs/tags/[0-9]' | sed 's/refs\/tags\//''/g' | grep -v '\^' | sort -k 2 -rV | awk '{print $2 " " $1}' | grep ${needver} | awk '{print $2}')
echo "Installing code-server ${needver} - ${needtagsha}"
curl -fsSLo /tmp/vscs.tgz "https://update.code.visualstudio.com/commit:${needtagsha}/server-linux-${arch2}/stable"
mkdir -p ~/.vscode-server/bin/"${needtagsha}"
pushd ~/.vscode-server/bin/"${needtagsha}" >/dev/null
tar xzf /tmp/vscs.tgz --no-same-owner --strip-components=1
popd >/dev/null
rm -f /tmp/vscs.tgz

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
  EditorConfig.EditorConfig
  esbenp.prettier-vscode
  felipecaputo.vscode-go-gvm
  foxundermoon.shell-format
  GitHub.remotehub
  golang.go
  Gruntfuggly.todo-tree
  hangxingliu.vscode-systemd-support
  hediet.vscode-drawio
  jaycetyle.vscode-gnu-global
  jiapeiyao.tab-group
  josetr.cmake-language-support-vscode
  Kelvin.vscode-sshfs
  KevinRose.vsc-python-indent
  llvm-vs-code-extensions.vscode-clangd
  mhutchie.git-graph
  ms-azuretools.vscode-docker
  ms-dotnettools.vscode-dotnet-runtime
  ms-kubernetes-tools.vscode-kubernetes-tools
  ms-python.autopep8
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-pylance
  ms-vscode-remote.remote-containers
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode-remote.vscode-remote-extensionpack
  ms-vscode.cmake-tools
  ms-vscode.cpptools
  ms-vscode.cpptools-extension-pack
  ms-vscode.cpptools-themes
  ms-vscode.hexeditor
  ms-vscode.makefile-tools
  ms-vscode.remote-explorer
  ms-vscode.remote-repositories
  ms-vscode.vscode-typescript-next
  naco-siren.gradle-language
  PKief.material-icon-theme
  quicktype.quicktype
  redhat.java
  redhat.vscode-xml
  redhat.vscode-yaml
  richardwillis.vscode-gradle-extension-pack
  suhay.vscode-editor-group-minimizer
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
)

export PATH=${PATH}:~/.vscode-server/bin/${needtagsha}/bin
for extname in "${extensions[@]}"; do
  code-server --install-extension ${extname}
done
