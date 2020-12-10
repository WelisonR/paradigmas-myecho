#! /bin/sh
"exec" "gst" "$0" "--smalltalk-args" "$@"

Smalltalk at: #PACKAGE_NAME put: 'GNU coreutils' .
Smalltalk at: #PROGRAM_NAME put: 'echo'.
Smalltalk at: #PROGRAM_VERSION put: '1.00' .
Smalltalk at: #AUTHORS put: #('Welison Regis') .

Smalltalk at: #DEFAULT_ECHO_TO_XPG put: false .

Object subclass: Echo [
    | argc argv break_line escape_char message_start_position |

    Echo class >> new: args [
        | r |
        r := super new .
        r setupInitialStates .
        r setArguments: args .
        r init .
        ^r .
    ]

    init [
        self programInfo .
        self computeMessageStartPosition .
        self computeFlags .
        self echo .
        self evalLineBreak .
    ]

    setupInitialStates [
        self setBreakLine: true .
        self setEscapeChar: DEFAULT_ECHO_TO_XPG .
        self setMessageStartPosition: 1 .
    ]

    echo [
        (escape_char == true)
            ifTrue: [ self printWithSpecialChar ]
            ifFalse: [ self printWithoutSpecialChar ] .
    ]

    programInfo [
        (argc = 1) ifTrue: [
            ((argv at: 1) = '--help') ifTrue: [
                self showHelp .
                ObjectMemory quit: 0 .
            ] .
            ((argv at: 1) = '--version') ifTrue: [
                self showVersion .
                ObjectMemory quit: 0 .
            ] .
        ] .
    ]

    computeMessageStartPosition [
        | i word letter number_flags |

        i := 1 .
        (argc > 0) ifTrue: [word := (argv at: i) .] .

        [(i <= argc) and: [(word at: 1) == $-]] whileTrue: [
            word := (argv at: i) .
            number_flags := 0 .

            2 to: (word size) do: [ :j |
                letter := (word at: j) .
                
                ((letter ~= $e and: [letter ~= $E]) and: [letter ~= $n]) ifTrue: [
                    ^self .
                ] .

                number_flags := number_flags + 1 .
            ] .

            (number_flags == 0) ifTrue: [
                ^self .
            ] .

            i := i + 1 .
            self setMessageStartPosition: i .
        ] .
    ]

    computeFlags [
        | word letter |

        1 to: message_start_position-1 do: [ :i |
            word := (argv at: i) .

            2 to: (word size) do: [ :j |
                letter := (word at: j) .

                (letter == $e) ifTrue: [ self setEscapeChar: true . ] .
                (letter == $E) ifTrue: [ self setEscapeChar: false . ] .
                (letter == $n) ifTrue: [ self setBreakLine: false . ] .
            ] .
        ] .
    ]

    printWithSpecialChar [
        | word letter next_letter j kk |

        message_start_position to: argc do: [ :i |
            word := (argv at: i) .
            j := 1 .

            [j <= (word size)] whileTrue: [
                letter := (word at: j) .

                (letter == $\ and: [j+1 <= (word size)]) ifTrue: [ 
                    j := j + 1 .
                    letter := (word at: j) .

                    "Caracteres especiais:  \\, \a, \b, \c, \e, \f, \n, \r, \t e \v"
                    (letter = $/) ifTrue: [ letter := UnicodeString with: (Character codePoint: 92) ] .
                    (letter = $a) ifTrue: [ letter := UnicodeString with: (Character codePoint: 7) ] .
                    (letter = $b) ifTrue: [ letter := UnicodeString with: (Character codePoint: 8) ] .
                    (letter = $c) ifTrue: [ ObjectMemory quit: 0 ] .
                    (letter = $e) ifTrue: [ letter := UnicodeString with: (Character codePoint: 27) ] .
                    (letter = $f) ifTrue: [ letter := UnicodeString with: (Character codePoint: 12) ] .
                    (letter = $n) ifTrue: [ letter := UnicodeString with: (Character codePoint: 10) ] .
                    (letter = $r) ifTrue: [ letter := UnicodeString with: (Character codePoint: 13) ] .
                    (letter = $t) ifTrue: [ letter := UnicodeString with: (Character codePoint: 9) ] .
                    (letter = $v) ifTrue: [ letter := UnicodeString with: (Character codePoint: 11) ] .
                    (letter = $x) ifTrue: [
                        (j+1 <= (word size)) ifTrue: [
                            j := j + 1 .
                            next_letter := (word at: j) .
                            ((self isHexadecimalDigit: next_letter) == true)
                                ifTrue: [
                                    letter := (self hexadecimalToInteger: next_letter) .
                                    (j+1 <= (word size)) ifTrue: [
                                        j := j + 1 .
                                        next_letter := (word at: j) .

                                        ((self isHexadecimalDigit: next_letter) == true) ifTrue: [
                                            letter := (letter * 16 + (self hexadecimalToInteger: next_letter)) asInteger .
                                        ]
                                        ifFalse: [
                                            j := j - 1 .
                                        ] .
                                    ] .

                                    letter := UnicodeString with: (Character codePoint: letter) .
                                ]
                                ifFalse: [
                                    j := j - 1 .
                                    Transcript show: '\' asString .
                                ] .
                        ]
                        ifFalse: [
                            Transcript show: '\' asString .
                        ] .
                    ] .
                ] .

                Transcript show: letter asString .

                j := j + 1 .
            ] .

            (i ~= argc) ifTrue: [
                Transcript show: ' ' .
            ] .
        ] .
    ]

    printWithoutSpecialChar [
        message_start_position to: argc do: [ :i |
            Transcript show: (argv at: i) .
            (i ~= argc) ifTrue: [
                Transcript show: ' ' .
            ] .
        ] .
    ]

    evalLineBreak [
        (break_line == true) ifTrue: [
            Transcript cr .
        ] .
    ]

    isHexadecimalDigit: letter [
        | hexadecimalDigits hexadecimalLetters hexadecimals isHexadecimal |

        hexadecimalDigits := #($0 $1 $2 $3 $4 $5 $6 $7 $8 $9) .
        hexadecimalLetters := #($A $B $C $D $E $F $a $b $c $d $e $f) .
        hexadecimals := hexadecimalDigits, hexadecimalLetters .
        isHexadecimal := hexadecimals includes: letter .

        ^isHexadecimal .
    ]

    hexadecimalToInteger: letter [
        | intLetter |

        intLetter := ((letter asciiValue) - ($0 asciiValue)) .
        (letter == $a or: [letter == $A]) ifTrue: [ intLetter := 10 ] .
        (letter == $b or: [letter == $B]) ifTrue: [ intLetter := 11 ] .
        (letter == $c or: [letter == $C]) ifTrue: [ intLetter := 12 ] .
        (letter == $d or: [letter == $D]) ifTrue: [ intLetter := 13 ] .
        (letter == $e or: [letter == $E]) ifTrue: [ intLetter := 14 ] .
        (letter == $f or: [letter == $F]) ifTrue: [ intLetter := 15 ] .

        ^intLetter .
    ]

    setArguments: args [
        argc := args size .
        argv := args .
    ]

    setBreakLine: status [
        break_line := status .
    ]

    setEscapeChar: status [
        escape_char := status .
    ]

    setMessageStartPosition: position [
        message_start_position := position .
    ]

    getEnv: name [
        ^Smalltalk getenv: name
    ]

    showHelp [
        Transcript show: 'Uso: ', PROGRAM_NAME, ' [OPÇÃO-CURTA]... [TEXTO]...' ; cr .
        Transcript show: ' ou: ', PROGRAM_NAME, ' OPÇÃO-LONGA' ; cr ;
        show: 'Ecoa o(s) TEXTO(s) para a saída padrão.' ; cr ;
        cr ;
        show: '  -n             não emitir o caractere de nova linha do final do TEXTO' ; cr ;
        show: '  -e             habilita a interpretação de escape por barra invertida' ; cr .
        (DEFAULT_ECHO_TO_XPG = true) ifTrue: [
            Transcript show: '                   (padrão)' ; cr .
        ] .
        Transcript show: '  -E             desabilita a interpretação de escape por barra invertida' ; cr .
        (DEFAULT_ECHO_TO_XPG = false) ifTrue: [
            Transcript show: '                   (padrão)' ; cr .
        ] .
        Transcript show: '      --help     mostra esta ajuda e sai' ; cr ;
        show: '      --version  informa a versão e sai' ; cr ;
        show: '' ; cr ;
        show: 'Se -e estiver ativo, as seguintes sequências são reconhecidas:' ; cr ;
        show: '' ; cr ;
        show: '  \\     barra invertida' ; cr ;
        show: '  \a     alerta (bipe)' ; cr ;
        show: '  \b     backspace' ; cr ;
        show: '  \c     produz nenhuma outra saída' ; cr ;
        show: '  \e     escapa' ; cr ;
        show: '  \f     form feed (nova página)' ; cr ;
        show: '  \n     nova linha' ; cr ;
        show: '  \r     retorno de carro' ; cr ;
        show: '  \t     tabulação horizontal' ; cr ;
        show: '  \v     tabulação vertical' ; cr ;
        show: '  \0NNN   byte com valor octal NNN (1 a 3 dígitos)' ; cr ;
        show: '  \xHH    byte com valor hexadecimal HH (1 a 2 dígitos)' ; cr ; 
        cr ;
        show: 'NOTA: seu shell pode ter sua própria versão de echo, o que pode tornar' ; cr ;
        show: 'obsoleta a versão descrita aqui. Por favor, informe-se na documentação do seu' ; cr ;
        show: 'shell sobre a que opções ele oferece suporte.' ; cr ;
        cr ;
        show: 'Página de ajuda do GNU coreutils: <https://www.gnu.org/software/coreutils/>' ; cr ;
        show: 'Relate erros de tradução do echo: <https://translationproject.org/team/pt_BR.html>' ; cr ;
        show: 'Documentação completa em: <https://www.gnu.org/software/coreutils/echo>' ; cr ;
        show: 'ou disponível localmente via: info "(coreutils) echo invocation"' ; cr .
    ]

    showVersion [
        Transcript show: PROGRAM_NAME, ' (', PACKAGE_NAME, ') ', PROGRAM_VERSION ; cr ;
        show: 'Copyright (C) 2018 Free Software Foundation, Inc.' ; cr ;
        show: 'Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>' ; cr ;
        show: 'Este é um software livre: você é livre para alterá-lo e redistribuí-lo.' ; cr ;
        show: 'NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.' ; cr ;
        cr .
        self displayAuthors .
    ]

    displayAuthors [
        Transcript show: 'Escrito por ' .
        1 to: (AUTHORS size) do: [ :index |
            (index = 1)
                ifTrue: [
                    Transcript show: (AUTHORS at: 1) .
                ]
                ifFalse: [
                    ((index = AUTHORS size))
                        ifTrue: [
                            Transcript show: ' e ', (AUTHORS at: index) .
                        ]
                        ifFalse: [
                            Transcript show: ', ', (AUTHORS at: index) .
                        ] .
                ] .
        ] .
        Transcript show: '.' ; cr .
    ]

    printOn: stream [
        argc printOn: stream .
    ]
]

echo := Echo new: Smalltalk arguments .
" echo init . "
" echo showHelp . "
" echo printNl . "