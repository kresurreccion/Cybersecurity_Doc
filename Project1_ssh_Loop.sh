#!/bin/bash

x=1

while  [ $x -le  3 ]
do
ssh sysadmi@10.0.0.5
ssh sysadmi@10.0.0.6
(( x++ ))
done