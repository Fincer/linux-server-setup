###########################################################
# List files and directories which are not owned by any package in a Debian system
# Scripted by Fincer (~Pekka Helenius), 2017

echo -e "\nSearch for files & folders which are not owned by any installed package.\n" 

if [[ $# -eq 0 ]]; then
    read -r -p "Folder path: " BASEDIR
    #Substitute $ symbol from environmental variables for printenv input
    if [[ $BASEDIR == *"$"* ]]; then
        BASEDIR=$(echo $(printenv $(echo ${BASEDIR} | sed 's/\$//g')))
    fi
else
    BASEDIR=$1
fi

if [[ ! $(file --mime-type "${BASEDIR}" | grep "inode/directory" | wc -l) -eq 1 ]]; then
    echo "ERROR: Use full folder path as an input value!"
elif [[ $# -gt 1 ]]; then
    echo "ERROR: Only one argument accepted!"
else

    echo -e "Search depth:\n1 = "${BASEDIR}"\n2 = "${BASEDIR}" & subfolders\n3 = "${BASEDIR}", subfolders & 2 folder levels below\n4 = no limit\n"
    read -r -p "Which depth value you prefer? [Default: 1] " response

    case $response in
        1)
            depth="-maxdepth 1 "
            depthstr="${BASEDIR}"
            ;;
        2)
            depth="-maxdepth 2 "
            depthstr="${BASEDIR} and subfolders"
            ;;
        3)
            depth="-maxdepth 3 "
            depthstr="${BASEDIR}, subfolders and 2 folder levels below"
            ;;
        4)
            depth=""
            depthstr="${BASEDIR} and all subfolders"
            ;;
        *)
            echo -e "\nUsing default value [1]"
            depth="-maxdepth 1 "
            depthstr="${BASEDIR}"
    esac

    echo -e "\nSearching unowned files in $depthstr\n"

    function counter() {
        i=0
        n=1
        COUNT=$(echo "$DATASET" | wc -l)
        IFS=$'\n'
        for data in $DATASET; do

            echo -ne "Scanning $data_name $n ($(( 100*$n/$COUNT ))%) of all $type ($COUNT) in $depthstr\r"
        
            if [[ $(dpkg -S "${data}" &>/dev/null || echo "no path found matching pattern" | wc -l) -eq 1 ]]; then
                DATA_ARRAY[$i]="$(( $i + 1)) - ${data}"
                let i++  
            fi
            let n++

        done
        unset IFS
        if [[ $i -gt 0 ]]; then
            echo -e "\nThe following $i of $COUNT $type is not owned by any installed package in $depthstr:\n"
            IFS=$'\n'
            echo -e "${DATA_ARRAY[*]}\n"
            unset IFS
            unset DATA_ARRAY
        else
            echo -e "\nAll $type are owned by system packages in $depthstr.\n"
        fi
    }

    function files() {
        DATASET=$(find "${BASEDIR}" ${depth} -type f)
        type="files"
        data_name="file"
        counter
    }

    function folders() {
        DATASET=$(find "${BASEDIR}" ${depth} -type d)
        type="folders"
        data_name="folder"
        counter
    }

    files; folders
fi
