#!/bin/bash
rubies=( 1.9.2-p290 1.9.3-p125 )
gemset="rails_best_practices"

for x in ${rubies[*]}
do
  echo $x@$gemset
  rvm $x@$gemset do bundle exec rake spec
done
