# Copyright (C) 2023 GIP-RECIA, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

files=$(find ./lib/ ./scripts/ \
  \( \
    -name '*.dart' -o \
    -name '*.sh' \
  \) -type f -print)

check() {
  docker run --rm -t --name licence -v ${PWD}:/src \
    ghcr.io/google/addlicense -check -f ./etc/header.template ${files}
}

generate() {
  docker run --rm -t --name licence -v ${PWD}:/src \
    ghcr.io/google/addlicense -f ./etc/header.template ${files}
}

commit() {
  if [ $(git status --porcelain *.vue *.ts *.scss *.java *.xml *.sh) ]; then
    git add ./src/
    git add ./scripts/
    git commit -m "docs: generate missing license headers"
    git push
  fi
}

if [ "$1" != "" ]; then
  choice="$1"
else
  echo "1 -> check"
  echo "2 -> generate"
  echo "3 -> commmit"
  echo ""

  read -r -p "Action: " choice
fi

case ${choice} in

1) check ;;
2) generate ;;
3) commit ;;
*) echo "Unknown choice" ;;

esac
