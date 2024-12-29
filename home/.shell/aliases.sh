pip3() {
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}



# Create a directory and cd into it
mkd() {
    mkdir "${1}" && cd "${1}"
}

path() {
  echo -e "${PATH//:/\\n}"
}
