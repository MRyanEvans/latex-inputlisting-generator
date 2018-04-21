#!/bin/bash

printUsage() { echo "Usage: $0 [-o <string>] [-d <string string string ...>] [-e <string string string ...>] " 1>&2; exit 1; }

constructLanguageOption() {
    extension=$1

    declare -A langMap
    langMap=(
        [sh]="Bash"
        [php]="PHP"
        [py]="Python"
        [java]="Java"
    )

    lang=${langMap[${extension}]}
    if [ ! -z "${lang}" ] ; then
        printf "language=%s, " ${lang}
    fi
}

findFilesByExtension() {
    #Find all files within the given search directories which have the specified file extensions

    extensionsPipeSeparated=$(echo "${extensions}" | tr ' ' '|')
    find ${search_dir} \
        -regextype posix-extended -regex "^.*("${extensionsPipeSeparated}")$" \
         | sort  \
         | uniq
}

constructListingTag() {
    # Generate the \lstinputlisting tag from the given file path

    path=$1

    name=$(basename ${path})
    caption=${name}
    label=$(echo ${name} | cut -d'.' -f1)

    extension=$(echo ${name} | awk -F . '{if (NF>1) {print $NF}}')
    languageOption=$(constructLanguageOption ${extension})

    echo "\\lstinputlisting[${languageOption}label={lst:${label}}, caption={${caption}}]{${path}}"
}

while getopts ":o:d:e:" arg; do
    case "${arg}" in
        o)
            outfile=${OPTARG}
            ;;
        d)
            search_dir=${OPTARG}
            ;;
        e)
            extensions=${OPTARG}
            ;;
        *)
            printUsage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${search_dir}" ] || [ -z "${extensions}" ] ; then
    printUsage
fi

files=$(findFilesByExtension)
commands=()

while read -r f ; do
    if [ -z "${f}" ] ; then
          continue
    fi
    command=$(constructListingTag ${f})
    commands+=("${command}")
done <<< "${files}"

commandsAsString=$( IFS=$'\n'; echo "${commands[*]}" )
if [ ! -z "${outfile}" ] && [ ! -z "${commandsAsString}" ] ; then
    echo "${commandsAsString}" > ${outfile}
fi
echo "${commandsAsString}"