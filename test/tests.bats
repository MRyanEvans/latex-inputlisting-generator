#!/usr/bin/env bats

outdir="out"
tmpdir="tmp"
tmpdir2="tmp2"

setup() {
  mkdir -p ${outdir}
  mkdir -p ${tmpdir}
  mkdir -p ${tmpdir2}
}

teardown() {
  rm -rf ${outdir}
  rm -rf ${tmpdir}
  rm -rf ${tmpdir2}
}

@test "Writes to given output file" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -o ${outfile} -d ${tmpdir} -e "sh"
    [ -f ${outfile} ]
}

@test "Writes to stdout" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "sh"
    grepped_output=$(echo ${output} | grep ".*lstinputlisting.*$")
    [ ! -z "${grepped_output}" ]
}

@test "Sets language if known" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "sh"
    grepped_output=$(echo ${output} | grep "language=Bash")
    [ ! -z "${grepped_output}" ]
}

@test "Does not set language if unknown" {
    outfile=${outdir}/listings.tex
    testfile=temp.notaknownextension
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "notaknownextension"
    [ "${output}" == "\lstinputlisting[label={lst:temp}, caption={temp.notaknownextension}]{tmp/temp.notaknownextension}" ]
}

@test "Sets caption" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "sh"
    grepped_output=$(echo ${output} | grep "caption={${testfile}}")
    [ ! -z "${grepped_output}" ]
}

@test "Sets label" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "sh"
    grepped_output=$(echo ${output} | grep "label={lst:temp}")
    [ ! -z "${grepped_output}" ]
}

@test "Sets file path" {
    outfile=${outdir}/listings.tex
    testfile=temp.sh
    touch ${tmpdir}/${testfile}
    run ./generate.sh -d ${tmpdir} -e "sh"
    grepped_output=$(echo ${output} | grep ".*{tmp/temp.sh}$")
    [ ! -z "${grepped_output}" ]
}

@test "Handles multiple files" {
    outfile=${outdir}/listings.tex
    touch ${tmpdir}/temp1.sh
    touch ${tmpdir}/temp2.sh
    run ./generate.sh -d ${tmpdir} -e "sh"
    linecount=$(echo "${output}" | wc -l )
    [ "${linecount}" -eq 2 ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp/temp1.sh}$")" ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp/temp2.sh}$")" ]
}

@test "Handles multiple languages" {
    outfile=${outdir}/listings.tex
    touch ${tmpdir}/temp1.sh
    touch ${tmpdir}/temp2.py
    run ./generate.sh -d ${tmpdir} -e "sh py"
    linecount=$(echo "${output}" | wc -l )
    [ "${linecount}" -eq 2 ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp/temp1.sh}$")" ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp/temp2.py}$")" ]
}

@test "Handles multiple languages" {
    outfile=${outdir}/listings.tex

    touch ${tmpdir}/temp1.sh
    touch ${tmpdir2}/temp2.py
    touch ${tmpdir2}/temp3.java

    run ./generate.sh -d "${tmpdir} ${tmpdir2}" -e "sh py java"

    linecount=$(echo "${output}" | wc -l )
    [ "${linecount}" -eq 3 ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp/temp1.sh}$")" ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp2/temp2.py}$")" ]
    [ ! -z "$(echo "${output}" | grep ".*{tmp2/temp3.java}$")" ]
}
