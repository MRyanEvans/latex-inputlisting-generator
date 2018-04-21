#!/bin/bash

usage() { echo "Usage: $0 [-o <string>] [-d <string string string ...>] [-e <string string string ...>] " 1>&2; exit 1; }

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
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${search_dir}" ] || [ -z "${extensions}" ] ; then
    usage
fi

# Concatenate extensions, separated by '|' to be used in the regex
exts_or_concat=$(echo "${extensions}" | tr ' ' '|')

# Recursively find all files in
files=$(find ${search_dir} \
    -regextype posix-extended -regex "^.*("${exts_or_concat}")$" \
     | sort | uniq)


commands=()

while read -r f ; do
    if [ -z "${f}" ] ; then
          continue
    fi

    name=$(basename ${f})
    caption=${name}
    label=$(echo ${name} | cut -d'.' -f1)
    extension=$(echo ${name} | awk -F . '{if (NF>1) {print $NF}}')

    languageOption=$(constructLanguageOption ${extension})

    command="\\lstinputlisting[${languageOption}label={lst:${label}}, caption={${caption}}]{${f}}"
    commands+=("${command}")

done <<< "${files}"

commands_as_string=$( IFS=$'\n'; echo "${commands[*]}" )

if [ ! -z "${outfile}" ] && [ ! -z "${commands_as_string}" ] ; then
    echo "${commands_as_string}" > ${outfile}
fi
echo "${commands_as_string}"