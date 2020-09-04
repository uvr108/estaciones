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
DA=`date "+%d"`
JL=`date "+%j"`

echo $JL $YR

./listar.pl $JL $YR
