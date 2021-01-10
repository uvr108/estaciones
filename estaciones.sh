#!/bin/bash

source $HOME/.bashrc

cd $HOME/estaciones

pwd

# YR=`date "+%Y" -d "yesterday"`
# MO=`date "+%m" -d "yesterday"`
# DA=`date "+%d" -d "yesterday"`
# JL=`date "+%j" -d "yesterday"`

YR=`date "+%Y"`
MO=`date "+%m"`
DA=`date "+%u"`
JL=`date "+%j"`

echo $JL $YR $DA

# for i in {1..9}
# do
#    var=$(printf '%03d' $i) 
#    echo $var
#    ./listar.pl $var 2021 1
# done

./listar.pl $JL $YR $DA
