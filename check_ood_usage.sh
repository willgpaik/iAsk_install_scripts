#!/bin/bash
# Script written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Date: 11/19/2019
# Last modified: 11/19/2019

# Check for inputs
if [[ $# -gt 1 ]]; then
        echo -e "Error: \tTo many inputs"
        echo -e "Usage: \t$(basename $0) <app> or <desktop>\n\tOr, $(basename $0) for desktop"
        echo " "
        exit 1
fi

input=${1}

echo " "

if [[ -z $input ]]; then
        input=desktop
        echo "Checking for OoD Interactive Desktop sessions"
else
        echo "Checking OoD $input sessions"
fi

echo " "

if [[ ! -z $input ]]; then
        qstat -n1t | grep open | grep comp-ic* >> tmp_ood_sessions

        less tmp_ood_sessions | grep R | grep g$input | wc -l | awk '{print "----->\tCurrently running OoD '$input' sessions: "$1}'
        less tmp_ood_sessions | grep Q | grep g$input | wc -l | awk '{print "----->\tCurrently queued OoD '$input' sessions: "$1}'
        echo " "
        less tmp_ood_sessions | grep R | wc -l | awk '{print "----->\t" $1 " out of 120 OoD sessions are in use now"}'
        rm tmp_ood_sessions
fi

echo " "

