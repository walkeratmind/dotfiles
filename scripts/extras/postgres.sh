#!bin/sh

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
        brew install $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}

install postgres
install pgsql
