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
    # '-e "\u"'
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
    # Test with invalid numeric conversitions with flag -e
    '-e "\011"'
    '-e "\0999"'
    '-e "\01111"'
    '-e "\xJ"'
    '-e "\xJJ"'
    '-e "\xJJJ"'
    '-E "\xJJ"'
    '-e "\xFG"'
    '-e "\x"'
    '-e "\xF"'
    '-e "\x \xFG"'
    '-e "\08"'
    '-e "\0"'
    # Test with valid numeric conversitions with flag -e
    '-e "\0111"'
    '-e "\0101"'
    '-e "\0137"'
    '-e "\x77"'
    '-e "\x77A"'
    '-e "\x5f"'
    # Test with numeric conversitions with flag -E
    '-E "\0111"'
    '-E "\x77"'
    '-E "\x77A"'
    '-E "\0999"'
    '-E "\01111"'
    '-E "\xJ"'
    '-E "\xJJJ"'
    '-E "\xFG"'
    '-E "\x"'
    '-E "\xF"'
    '-E "\x \xFG"'
    '-E "\08"'
    '-E "\0"'
    # Test with random strings
    '-e "Teste com uma string longa... Teste com uma string longa... Teste com uma string longa... Teste com uma string longa..."'
    '-ne "Teste com string aleatório fau\b" "Teste com uma string aleatória... \\" "\n\r..."'
    '-nEe "\n\a\a\t" "123\t0tt9 12\\12039 \x11 \x55 \x5f \0137" "\xTTF \0111111 \09999 \123123 \1239 \adksh \y \g \h\h\h\g\\h\h\\\h"'
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
