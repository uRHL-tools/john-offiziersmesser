#!/bin/bash

# Update: Now john does not allow to use your own pot file, show option --pot=results/john.pot was removed from the command

# ============================| CONSTANTS |================================

divider="=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n"
banner="$divider\t========================\n\t-----| SE - Lab 1 |-----\n\t========================\n\tPassword craking with John the Ripper, by @uRHL\n$divider"

exit_program="0. Exit the program"

first_opt="1. New cracking session"
second_opt="2. Restore a previous cracking session"
third_opt="3. View attack log"
fourth_opt="4. Check current results"
fifth_opt="5. Check current session progress"
sixth_opt="6. Crack a new set of passwords"

usage="Usage: bash crack_me_if_you_can.sh [-h|--help] [--lab]\n  --lab\t\tLab mode (only for Security Engineer university course)\n  -h|--help\tPrints usage information\n\nIf no argument is provided it will run in normal mode."
no_sessions="\nThere are no uncompleted sessions. Select 'New craking session' in the menu\n"

#Defaul value for user input
selected_opt=9

# Find the executables
JOHN=$(which john)
UNSHADOW=$(which unshadow)

# ============================| GLOBAL |================================

root_dir=$(pwd)
session_dir="$root_dir/sessions/uncompleted"
pw_file="$root_dir/results/unshadow"
log_file="$root_dir/logs/attack.log"
gr=0

# ============================| AUX |================================

function reset() {
    cd $root_dir
    rm -fr logs/* sessions/uncompleted/* sessions/completed/* results/*
}

function checkJohnInstall() {
    if [[ $(which john) == "" ]]; then
        echo -e "Missing John installation. Try sudo apt install john"
        exit 1
    fi
    
}

function moveCompletedSessions() {
    for i in $(ls $session_dir)
    do
        session="$session_dir/$i"
        # grep returns 0 if something is found
        ls $session | grep .rec > /dev/null
        if [[ ! $? -eq 0 ]]; then
            # REC file does not exists => session completed
            mv $session/$i.log $root_dir/sessions/completed/$(date +%F)/ 2> /dev/null
            rmdir $session
        fi
        # Else: REC file exists => session not completed
    done
    
}

function unshadowPasswords() {

    pw_path=""
    shadow_path=""

	echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=\nCraking a new set of passwords.\n"
    opt=9
    while : ;
    do
        echo -e "An unshadowed password file is needed. Please select an option:\n\t1. Unshadow passwords\n\t2. Use your own unshadowed password file\n\n\t0. Cancel"
        read opt
        case $opt in
            0)
                echo -e "Operation cancelled\nNo unshadow password file provided. Exiting..."
                exit 0
                ;;
            1)
                # Unshadow
                echo -e "Indicate the path to the password and shadow files"
                echo -e "\nPassword file path:\t"
	            read pw_path
                echo -e "\nShadow file path:\t"
                read shadow_path
	
                sudo $UNSHADOW $pw_path $shadow_path > $pw_file
                # Check the result of UNSHADOW or CP
                if [[ $? -eq 0 ]]; then
                    echo -e "\nPasswords unshadowed correctly (~/results/unshadow)\n"
                    break
                else
                    echo -e "\nError unshadowing passwords\n"
                    opt=9
                fi
                ;;
            2)
                # Custom hash file
                echo -e "\nUnshadow file path:\t"
	            read us_path
                cp $us_path $pw_file
                # Check the result of UNSHADOW or CP
                if [[ $? -eq 0 ]]; then
                    echo -e "\nPasswords unshadowed correctly (~/results/unshadow)\n"
                    break
                else
                    echo -e "\nError unshadowing passwords\n"
                    opt=9
                fi                
                ;;
            *)
                echo -e "Option '$opt' not recognized. Select a valid option"
                opt=9
            ;;
        esac
    done
    touch $log_file
}

# This function only works for the course lab (lab mode)
function unshadowLabPasswords() {

	echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=\nCraking a new set of LAB passwords. Group number '$1'\n"
	#unshadow the passwords
	touch $log_file

	mkdir tmp
	unzip $(find $HOME -nowarn -name "grupo_$gr.zip") -d tmp
	$UNSHADOW $(find ./ -name "*_passwd") $(find ./ -name "*_shadow") > pw_group_$gr
	if [[ $? -eq 0 ]];
    then
    	mv "pw_group_$gr" $pw_file\_$gr
        echo -e "\nPasswords unshadowed correctly (~/results/unshadow_gr_$gr)\n"
    else
        echo -e "\nError unshadowing passwords\n"
    fi
	rm -fr tmp
}

# ============================| MAIN |================================

if [[ $1 == "-h" || $1 == "--help" ]];
then
    echo -e $usage
    exit 0
fi

# Verify that John the Ripper is installed
checkJohnInstall
mkdir -p $root_dir/results 2> /dev/null
mkdir -p $root_dir/logs 2> /dev/null

echo -e "$banner\n"

# Verify that there are passwords unshadowed
if [[ $1 == "--lab" ]];
then
    echo -e "MODE: lab"
    echo -e "Please enter your group number"
    read gr
    if [ -e ./results/unshadow_$gr ];
    then
        echo -e "Unshadowed passwords found\n"
    else
        unshadowLabPasswords $gr
    fi
    pw_file+="_$gr"
    
    
else
    echo "MODE: normal"
    
    if [ ! -e ./results/unshadow ];
    then
        unshadowPasswords
    else
        echo -e "Unshadowed passwords found\n"    
    fi
fi


# Main loop
while [ $selected_opt -gt 0 ];
do
    moveCompletedSessions
    cd $root_dir
    sleep 2s
	echo -e "$divider\nUsing password file:$pw_file\n\nSelect an option:\n\n$first_opt\n$second_opt\n$third_opt\n$fourth_opt\n$fifth_opt\n\n$sixth_opt\n\n$exit_program"
    read selected_opt
    case $selected_opt in

    0)
        echo -e "\nEnding the program..."
        ;;
    1)
        echo -e "\nYou selected $first_opt\n\nEnter a name for the new cracking session"        
	    read ss_name
	    mkdir -p $root_dir/sessions/uncompleted/$ss_name
        $JOHN
	    echo -e "\n---\nSpecify the options of the  attack:\n\nBase command: john --node=1-3/4 --session:$ss_name\nPasswords file:$pw_file\n"
	    read command_opt
	    echo -e "[$(date +%F-%H-%M)] Starting session: $ss_name; Attack options: $command_opt" | tee -a $log_file
	    cd $root_dir/sessions/uncompleted/$ss_name
        if [[ -n $command_opt ]];
        then
            $JOHN --node=1-3/4 --session=$ss_name $command_opt $pw_file
        else
            $JOHN --node=1-3/4 --session=$ss_name $pw_file
        fi
	    
	    # If there are no .rec files of the current session it means it has been completed
        if [[ -e $root_dir/sessions/uncompleted/$ss_name/$ss_name.rec ]];
        then
		    echo -e "[$(date +%F-%H-%M)] ***Session $ss_name stopped" | tee -a $log_file
        elif [[ $? -eq 0 ]];
        then
            echo -e "[$(date +%F-%H-%M)] ***Session $ss_name completed" | tee -a $log_file
        else
		    echo -e "[$(date +%F-%H-%M)] !!!Session $ss_name aborted" | tee -a $log_file
	    fi;
	;;
    2)
        echo -e "\nYou selected $second_opt\n\nSelect the session to be restored:"

	    # Verify that there are sessions uncompleted
        if [ "$(ls -A $session_dir)" ]; then
		    # Show session files
            echo ">"
            for i in $(ls $session_dir)
            do
                echo $i
            done
            echo ">"
		    ss_name=""
		    read ss_name
		    # restore the crackin session
		    echo -e "[$(date +%F-%H-%M)] Restoring session: $ss_name" | tee -a $log_file
		    cd $session_dir/$ss_name 2> /dev/null
		    
		    $JOHN --restore=$ss_name

            # If there are no .rec files of the current session it means it has been completed
            if [[ -e $session_dir/$ss_name/$ss_name.rec ]];
            then
	            echo -e "[$(date +%F-%H-%M)] ***Session $ss_name stopped" | tee -a $log_file
            elif [[ $? -eq 0 ]];
            then
                echo -e "[$(date +%F-%H-%M)] ***Session $ss_name completed" | tee -a $log_file
            else
	            echo -e "[$(date +%F-%H-%M)] !!!Session $ss_name aborted" | tee -a $log_file

            fi;
	    else
            echo -e "$no_sessions"
	    fi;
    ;;
    3)
        echo -e "\nYou selected $third_opt\n"
        if [ -s $log_file ]; then
        	more $log_file
        else
            echo -e "Log file is empty\n"
        fi
    ;;
    4)
        echo -e "\nYou selected $fourth_opt\n"
	    $JOHN --show $pw_file
	;;
    5)
        echo -e "\nYou selected $fifth_opt\n"
        # Verify that there are sessions uncompleted
        if [ "$(ls -A $session_dir)" ]; then
            echo -e "Select a session to check its progress\n>"
            for i in $(ls $session_dir)
            do
                echo $i
            done
            echo -e ">"
            read ss_name
            echo -e "Session '$ss_name' progress:"
            $JOHN --status="$session_dir/$ss_name/$ss_name"
        else
            echo -e "$no_sessions"
        fi
    ;;    
    6)
        echo -e "\nYou selected $sixth_opt\n"
        reset=""
        while [[ "$reset" != 'y' && "$reset" != 'n' ]];
        do
            echo -e "Warning: session data will be lost. The attack results will be saved in the directory 'old-attacks'. Do you want to continue? [y/n]\n"
            read reset
            case $reset in
                'y')
                    echo -e "Saving attack results...reseting the program..."
                    save_name=$(date +%F-%H-%M)
                    mkdir $root_dir/old-attacks/$save_name
                    mv $log_file $root_dir/old-attacks/$save_name/
                    mv $root_dir/results/* $root_dir/old-attacks/$save_name/
                    reset
                    unshadowPasswords
                    ;;
                'n')
                    
                    ;;
                *)
                    echo -e "Please enter [y/]\n"
                    reset=""
                    ;;
            esac
        done
	;;
    *)
        #non recognized option. Restore the default value
        echo -e "\nOption $selected_opt not recognized\n"
        selected_opt=9
        echo -e "$divider"
    ;;
    esac            
done
exit 0
