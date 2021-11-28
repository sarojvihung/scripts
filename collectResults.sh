#!/usr/bin/env bash

cd /proj/sfcs-PG0/opt/ && mkdir -p Results

for exp in /proj/sfcs-PG0/mongo_op/* ; 
do
    f1=`basename $exp`
    for subexp in $exp/* ; 
    do
        f2=`basename $subexp`
        mkdir -p /proj/sfcs-PG0/opt/Results/$f1/$f2/
        cmd="scp -o StrictHostKeyChecking=no $subexp/* /proj/sfcs-PG0/opt/Results/$f1/$f2/"
        eval "$cmd"
    done
done

for nodexp in /proj/sfcs-PG0/opt/Node_Ops/* ; 
do
    f1=`basename $nodexp`
    for exp in $nodexp/* ; 
    do
        f2=`basename $exp`
        for subexp in $exp/* ; 
        do
            
            f3=`basename $subexp`
            mkdir -p /proj/sfcs-PG0/opt/Results/$f2/$f3/
            cmd="scp -o StrictHostKeyChecking=no $subexp/* /proj/sfcs-PG0/opt/Results/$f2/$f3/"
            eval "$cmd"
        done
    done
done

for uexp in /proj/sfcs-PG0/opt/Ue_Ops/* ;
do
    f1=`basename $uexp`
    for exp in $uexp/* ;
    do
        f2=`basename $exp`
        for subexp in $exp/* ;
        do
            f3=`basename $subexp`
            mkdir -p /proj/sfcs-PG0/opt/Results/$f2/$f3/
            for filename in $subexp/* ; 
            do
                f4=`basename $filename`
                cmd="scp -o StrictHostKeyChecking=no $subexp/$f4 /proj/sfcs-PG0/opt/Results/$f2/$f3/${f4}_${f1}"
                eval "$cmd"
            done
        done
    done
done
