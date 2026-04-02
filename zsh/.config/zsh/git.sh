gis() {
  git status
}

gim() {
  git commit -m "$*"
  git push
}

gif() {
  git fetch
  git pull
}
