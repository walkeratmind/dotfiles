
function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
        npm install -g $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}

install yarn
install @vue/cli
install @angular/cli
install yo
install alacritty-themes

