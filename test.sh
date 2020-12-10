#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

ECHO_ARGUMENTS=(
    # Test with invalid flags
    '- -e Flags Flags'
    '-- -n Flags'
    '-nek Flags'
    '-- --n --e Flags'
    '--ne Flags'
    # Test with valid flags
    '-n -e Flags Flags "\t$PATH"'
    '-E -n'
    '-e - "\tFlags"'
    '-ne "Flags\t"'
    'Flags'
    '-neE "Flags\t"'
    '-n -Ee "Flags\t"'
    '-Ee Flags\t'
    # Test with special chars
    '-e "\\\\\\" "\\"'
    '-n -e "Teste \a"'
    '-Ee "Teste \b"'
    '-ne "Test\ce"'
    '-e "T\eeste"'
    '-n -e "T\feste"'
    '-Ee "T\neste"'
    '-ne "T\reste"'
    '-e "T\teste"'
    '-n -e "T\veste"'
    # Test without special chars
    '-E "\\\\\\" "\\"'
    '-n -E "Teste \a"'
    '-eE "Teste \b"'
    '-nE "Test\ce"'
    '-E "T\eeste"'
    '-n -E "T\feste"'
    '-eE "T\neste"'
    '-nE "T\reste"'
    '-n -E "T\veste"'
    '-E "T\teste"'
    # Test with invalid numeric conversitions
    '-e "\011"'
    '-e "\0999"'
    '-e "\01111"'
    '-e "\xJ"'
    '-e "\xJJ"'
    '-e "\xJJJ"'
    '-E "\xJJ"'
    # Test with valid numeric conversitions
    '-e "\0111"'
    '-e "\0101"'
    '-e "\x77"'
    '-e "\x77A"'
    '-E "\xAA"'
    # Teste com strings aleatórias
    '-e "Teste com uma string longa... Teste com uma string longa... Teste com uma string longa... Teste com uma string longa..."'
    '-ne "Teste com string aleatório fau\b" "Teste com uma string aleatória... \\" "\n\r..."'
)

# Remove output files if avaliable
rm -f -- myecho.out echo.out

# Execute env echo (pure echo) and myecho
for echo_argument in "${ECHO_ARGUMENTS[@]}"; do
    eval $"env echo $echo_argument" >>echo.out
    eval $"./myecho.st $echo_argument" >>myecho.out
done

# Show difference between files
sdiff --text --suppress-common-lines --minimal echo.out myecho.out

# Remove output files if avaliable
# rm -f -- myecho.out echo.out