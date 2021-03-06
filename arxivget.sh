#!/bin/bash

# arXivGet is a minimalistic command line program.
# Run it with "arxivget", add a paper's arXiv ID, 
# and it will save the pdf file and/or source 
# on a folder named after the paper's arXiv ID.

# Default definitions
arXivGetDir="arXivGet" # Name of the parent folder
downloadoptdef="pdf" # Default download option
adddotdef="yes" # Default option for autocorrecting missing dot in ID

clear
echo -ne "\nWelcome to arXivGet! 
The minimalistic download agent for arXiv.org.
            --Created by L. Trifyllis at 2018.\n\n\n"

while true; do
    # Read paperID or other option from user:
    echo "NOTE: for papers older than April 1 2007 type \"older\"." 
    echo -ne "To exit arXivGet type \"quit\".\n\n"
    echo "  Please insert paper's arXiv ID or other option and press enter: "
    read -e paperID
    # turn input to lowercase for simplicity
    paperID="$(tr '[:upper:]' '[:lower:]' <<< "$paperID")"
    # Check if user wants to exit the program:
    if [ $paperID = "q" -o $paperID = "quit" ]; then
        break
    fi
    # Check if user wants to get a paper older than April 1 2007 (identifier is different in this case). 
    # Please visit https://arxiv.org/help/arxiv_identifier for more details. 
    if [ $paperID = "o" -o $paperID = "old" -o $paperID = "older" ]; then
        echo -ne "\n\nVersion using old identifier.\n"
        echo "  Please give archive and subject class (e.g. hep-th, astro-ph, math, econ etc): "
        read -e oldasc
        # turn input to lowercase for simplicity
        oldasc="$(tr '[:upper:]' '[:lower:]' <<< "$oldasc")"
        echo -ne "\n  Please give numerical identifier: \n"
        read -e oldnum
        # turn input to lowercase for simplicity
        oldnum="$(tr '[:upper:]' '[:lower:]' <<< "$oldnum")"
        paperID="$oldasc/$oldnum"
    fi
    # Sometimes . character is ommited by user in paper's ID. 
    # Autocorrect that but only for versions after April 1 2007:
    if [[ $paperID != *"."* && $paperID != *"/"* ]]; then 
        echo "Do you mean ${paperID:0:4}.${paperID:4} [Y/n]?"
        read -e adddot
        # turn input to lowercase for simplicity
        adddot="$(tr '[:upper:]' '[:lower:]' <<< "$adddot")"
        # set default option for dot autocorrection if there is no user input
        adddot=${adddot:-$adddotdef}
        if [ $adddot = "y" -o $adddot = "yes" ]; then
            paperID="${paperID:0:4}.${paperID:4}"
        fi
    fi
    # Create propriate directory and name for paper: 
    if [[ $paperID = *"/"* ]]; then 
        paperDIR="$oldasc-$oldnum"
        paperNAME="$oldnum"
    else
        paperDIR="$paperID"
        paperNAME="$paperID"
    fi
    mkdir -p ~/$arXivGetDir/$paperDIR
    cd ~/$arXivGetDir/$paperDIR
    echo "Download pdf [p] (default), source [s] or both [b]? " 
    read -e downloadopt
    # turn input to lowercase for simplicity
    downloadopt="$(tr '[:upper:]' '[:lower:]' <<< "$downloadopt")"
    # set default download option if there is no user input
    downloadopt=${downloadopt:-$downloadoptdef}
    if [ $downloadopt = "p" -o $downloadopt = "pdf" ]; then
        clear
        echo "Downloading pdf... "
        wget --user-agent=Mozilla/5.0 https://arxiv.org/pdf/"$paperID".pdf
        wait $(jobs -p)
    elif [ $downloadopt = "s" -o $downloadopt = "src" -o $downloadopt = "source" ]; then
        clear
        echo "Downloading source... "
    	wget --user-agent=Mozilla/5.0 https://arxiv.org/src/"$paperID"
    	wait $(jobs -p)
        # Note that gunzip is performed automatically with mozilla, 
        # and that received file has no extension (in most cases).
        # Just rename received file to .tar extension to avoid extra trouble. 
        mv "$paperNAME" "$paperNAME".tar
        tar -xvf "$paperNAME".tar
    elif [ $downloadopt = "b" -o $downloadopt = "both" ]; then
        clear
        echo "Downloading pdf... "
        wget --user-agent=Mozilla/5.0 https://arxiv.org/pdf/"$paperID".pdf
        echo "Downloading source... "
    	wget --user-agent=Mozilla/5.0 https://arxiv.org/src/"$paperID"
    	wait $(jobs -p)
        mv "$paperNAME" "$paperNAME".tar
        tar -xvf "$paperNAME".tar
    else 
        echo "Error: unknown option. Operation failed."
        rmdir ~/$arXivGetDir/"$paperDIR"
    fi
    cd -
    echo -ne "\n\n\n\n"
done
clear
