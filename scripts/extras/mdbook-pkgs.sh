
function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
        cargo install $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}

# Docker Image url: 
# https://github.com/Michael-F-Bryan/mdbook-docker-image
	
install mdbook
install mdbook-linkcheck
install mdbook-epub
install mdbook-plantuml
install mdbook-mermaid
install mdbook-graphviz
install mdbook-toc
