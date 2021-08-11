#!/usr/bin/env bash

cd /opt/ && mkdir -p Results

for exp in /opt/Udsf_Ops/Experiments/* ; 
do
    f1=`basename $exp`
    for subexp in $exp/* ; 
    do
        f2=`basename $subexp`
        mkdir -p /opt/Results/$f1/$f2/
        cmd = "scp -o StrictHostKeyChecking=no $subexp/* /opt/Results/$f1/$f2/"
        eval "$cmd"
    done
done

for nodexp in /opt/Node_Ops/* ; 
do
    f1=`basename $nodexp`
    for exp in $nodexp/* ; 
    do
        f2=`basename $exp`
        for subexp in $exp/* ; 
        do
            
            f3=`basename $subexp`
            mkdir -p /opt/Results/$f2/$f3/
            cmd = "scp -o StrictHostKeyChecking=no $subexp/* /opt/Results/$f2/$f3/"
            eval "$cmd"
        done
    done
done

for uexp in /opt/Ue_Ops/* ; 
do
    f1=`basename $uexp`
    for exp in $uexp/* ; 
    do
        f2=`basename $exp`
        for subexp in $exp/* ; 
        do
            
            f3=`basename $subexp`
            mkdir -p /opt/Results/$f2/$f3/
            cmd = "scp -o StrictHostKeyChecking=no $subexp/* /opt/Results/$f2/$f3/"
            eval "$cmd"
        done
    done
done
