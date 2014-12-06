#!/bin/bash

try () {
  "$@" || exit 1
}

# one method to deduplicate some symbol in libraries
function deduplicate() {
  fn=$(basename $1)
  echo "== Trying to remove duplicate symbol in $1"
  
  rm -Rf ddp
  
  try mkdir ddp
  try cd ddp
  try ar x $1
  try ar rc $fn *.o
  try ranlib $fn
  try rm -f $1
  try cp -f $fn $1
  try cd ..
  try rm -rf ddp

echo done
}
