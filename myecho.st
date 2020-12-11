#! /bin/sh
"exec" "gst" "$0" "--smalltalk-args" "$@"

Smalltalk at: #PACKAGE_NAME put: 'GNU coreutils'.
Smalltalk at: #PROGRAM_NAME put: 'echo'.
Smalltalk at: #PROGRAM_VERSION put: '1.00'.
Smalltalk at: #AUTHORS put: #('Welison Regis').

" If true, interpret backslash escapes by default. "
Smalltalk at: #DEFAULT_ECHO_TO_XPG put: false.

Object subclass: System [
    | package_name program_name program_version program_authors |

    System class >> new: package program_name: program program_version: version program_authors: authors [
        | r |
        r := super new.
        r setPackageName: package.
        r setProgramName: program.
        r setProgramVersion: version.
        r setProgramAuthors: authors.
        ^r.
    ]

    showVersion [
        Transcript show: program_name, ' (', package_name, ') ', program_version ; cr ;
        show: 'Copyright (C) 2020 Welison Regis' ; cr ;
        show: 'Licença GPLv3+: GNU GPL versão 3 ou posterior <https://gnu.org/licenses/gpl.html>' ; cr ;
        show: 'Este é um software livre: você é livre para alterá-lo e redistribuí-lo.' ; cr ;
        show: 'NÃO HÁ QUALQUER GARANTIA, na máxima extensão permitida em lei.' ; cr ;
        cr.
        self displayAuthors.
    ]

    displayAuthors [
        Transcript show: 'Escrito por '.
        1 to: (program_authors size) do: [ :index |
            (index == 1) ifTrue: [
                Transcript show: (program_authors at: 1).
            ] ifFalse: [
                (index == (program_authors size)) ifTrue: [
                    Transcript show: ' e ', (program_authors at: index).
                ] ifFalse: [
                    Transcript show: ', ', (program_authors at: index).
                ].
            ].
        ].
        Transcript show: '.' ; cr.
    ]

    getEnv: name [
        ^Smalltalk getenv: name.
    ]

    setPackageName: package [
        package_name := package.
    ]

    setProgramName: program [
        program_name := program.
    ]

    setProgramVersion: version [
        program_version := version.
    ]

    setProgramAuthors: authors [
        program_authors := authors.
    ]
]

System subclass: Echo [
    | argc argv message_start_argc string_index allow_options has_break_line_option has_escape_option is_env_echo |

    Echo class >> new: args [
        | r |
        r := super new: PACKAGE_NAME program_name: PROGRAM_NAME program_version: PROGRAM_VERSION program_authors: AUTHORS.
        r setArguments: args.
        r setPosixlyCorrect.
        r setDefaultStates.
        r echo.
        ^r.
    ]

    setArguments: args [
        argc := args size.
        argv := args.
    ]

    setPosixlyCorrect [
        | posixly_correct has_expected_options use_options |

        " From command info '(coreutils) echo invocation':
        If the ‘POSIXLY_CORRECT’ environment variable is set, then when ‘echo’’s first argument
        is not ‘-n’ it outputs option-like arguments instead of treating them as options.
        For example, ‘echo -ne hello’ outputs ‘-ne hello’ instead of plain ‘hello’. "
        posixly_correct := (self getEnv: 'POSIXLY_CORRECT').
        has_expected_options := (((DEFAULT_ECHO_TO_XPG == false) and: [argc >= 1]) and: [(argv at: 1) = '-n']).
        use_options := ((posixly_correct isNil) or: [has_expected_options]).

        self setAllowOptions: use_options.
    ]

    setDefaultStates [
        self setBreakLine: true.
        self setEnvEcho: true.
        self setEspaceOption: DEFAULT_ECHO_TO_XPG.
        self setMessageStartPosition: 1.
    ]

    echo [
        self programInfo.
        (allow_options == true) ifTrue: [
            self computeMessageStartPosition.
            self computeFlags.
        ].
        self displayCharacters.
        self evalLineBreak.
    ]

    programInfo [
        (argc == 1 and: [allow_options == true]) ifTrue: [
            ((argv at: 1) = '--help') ifTrue: [
                self showHelp.
                ObjectMemory quit: 0.
            ].
            ((argv at: 1) = '--version') ifTrue: [
                self showVersion.
                ObjectMemory quit: 0.
            ].
        ].
    ]

    computeMessageStartPosition [
        | i word letter number_flags |

        i := 1.
        (argc > 0) ifTrue: [ word := (argv at: i) ].

        [((i <= argc) and: [(word size) > 0]) and: [(word at: 1) == $-]] whileTrue: [
            word := (argv at: i).
            number_flags := 0.

            2 to: (word size) do: [ :j |
                letter := (word at: j).
                ((letter ~= $e and: [letter ~= $E]) and: [letter ~= $n]) ifTrue: [ ^self ].
                number_flags := number_flags + 1.
            ].

            (number_flags == 0) ifTrue: [ ^self ].

            i := i + 1.
            self setMessageStartPosition: i.
        ].
    ]

    computeFlags [
        | word letter |

        1 to: message_start_argc-1 do: [ :i |
            word := (argv at: i).

            2 to: (word size) do: [ :j |
                letter := (word at: j).

                (letter == $e) ifTrue: [ self setEspaceOption: true. ].
                (letter == $E) ifTrue: [ self setEspaceOption: false. ].
                (letter == $n) ifTrue: [ self setBreakLine: false. ].
            ].
        ].
    ]

    displayCharacters [
        (has_escape_option == true)
            ifTrue: [ self printWithSpecialChar ]
            ifFalse: [ self printWithoutSpecialChar ].
    ]

    printWithSpecialChar [
        | word letter next_letter specialLetterDictionary temporary is_valid_backslash |

        message_start_argc to: argc do: [ :i |
            word := (argv at: i).
            string_index := 1.

            [string_index <= (word size)] whileTrue: [
                letter := (word at: string_index).

                (letter == $\ and: [string_index+1 <= (word size)]) ifTrue: [
                    self setStringIndex: string_index+1.
                    letter := (word at: string_index).
                    self setEnvEcho: true.
                    is_valid_backslash := (self isExpectedBackslash: letter).

                    "Special characters: \a, \b, \c, \e, \f, \n, \r, \t e \v"
                    specialLetterDictionary := (self getSpecialCharacterDictionary).
                    (specialLetterDictionary includesKey: letter) ifTrue: [
                        temporary := (specialLetterDictionary at: letter).
                        letter := UnicodeString with: (Character codePoint: temporary).
                    ].
                    (letter == $c) ifTrue: [
                        ObjectMemory quit: 0
                    ].
                    (letter == $x) ifTrue: [
                        temporary := (self getHexadecimalValue: word).
                        (temporary ~= -1) ifTrue: [ letter := temporary ].
                    ].
                    (letter == $0) ifTrue: [
                        letter := (self getFirstOctalDigit: word).
                    ].
                    ((is_env_echo == true)  and: [(#($0 $1 $2 $3 $4 $5 $6 $7) includes: letter) == true]) ifTrue: [
                        letter := (self getSpecialDigitValue: word current_letter: letter).
                    ].

                    "Default behaviour: print a backslash"
                    ((is_valid_backslash == false) and: [(letter ~= $\)]) ifTrue: [
                        Transcript show: '\' asString .
                    ].
                ].

                Transcript show: letter asString.

                self setStringIndex: string_index+1.
            ].

            (i ~= argc) ifTrue: [
                Transcript show: ' '.
            ].
        ].
    ]

    printWithoutSpecialChar [
        message_start_argc to: argc do: [ :i |
            Transcript show: (argv at: i).
            (i ~= argc) ifTrue: [
                Transcript show: ' '.
            ].
        ].
    ]

    evalLineBreak [
        (has_break_line_option == true) ifTrue: [
            Transcript cr.
        ].
    ]

    getSpecialCharacterDictionary [
        | specialLetterDictionary |

        specialLetterDictionary := Dictionary new.
        specialLetterDictionary add: $a->7;
                                add: $b->8;
                                add: $e->27;
                                add: $f->12;
                                add: $n->10;
                                add: $r->13;
                                add: $t->9;
                                add: $v->11; yourself. 

        ^specialLetterDictionary.
    ]

    isHexadecimalDigit: letter [
        | hexadecimalDigits hexadecimalLetters hexadecimals isHexadecimal |

        hexadecimalDigits := #($0 $1 $2 $3 $4 $5 $6 $7 $8 $9).
        hexadecimalLetters := #($A $B $C $D $E $F $a $b $c $d $e $f).
        hexadecimals := hexadecimalDigits, hexadecimalLetters.
        isHexadecimal := hexadecimals includes: letter.

        ^isHexadecimal.
    ]

    hexadecimalToInteger: letter [
        | intLetter |

        intLetter := ((letter asciiValue) - ($0 asciiValue)).
        (letter == $a or: [letter == $A]) ifTrue: [ intLetter := 10 ].
        (letter == $b or: [letter == $B]) ifTrue: [ intLetter := 11 ].
        (letter == $c or: [letter == $C]) ifTrue: [ intLetter := 12 ].
        (letter == $d or: [letter == $D]) ifTrue: [ intLetter := 13 ].
        (letter == $e or: [letter == $E]) ifTrue: [ intLetter := 14 ].
        (letter == $f or: [letter == $F]) ifTrue: [ intLetter := 15 ].

        ^intLetter.
    ]

    getHexadecimalValue: word [
        | letter next_letter temporary |

        letter := -1.
        (string_index+1 <= (word size)) ifTrue: [
            self setStringIndex: string_index+1.
            next_letter := (word at: string_index).
            ((self isHexadecimalDigit: next_letter) == true) ifTrue: [
                letter := (self hexadecimalToInteger: next_letter).
                (string_index+1 <= (word size)) ifTrue: [
                    self setStringIndex: string_index+1.
                    next_letter := (word at: string_index).
                    ((self isHexadecimalDigit: next_letter) == true) ifTrue: [
                        temporary := (self hexadecimalToInteger: next_letter).
                        letter := (letter * 16 + temporary) asInteger.
                    ] ifFalse: [
                        self setStringIndex: string_index-1.
                    ].
                ].
                letter := UnicodeString with: (Character codePoint: letter).
            ] ifFalse: [
                self setStringIndex: string_index-1.
                Transcript show: '\' asString.
            ]
        ] ifFalse: [
            Transcript show: '\' asString.
        ].

        ^letter.
    ]

    isOctalDigit: letter [
        | isOctal |

        ((letter >= $0) and: [letter <= $7]) ifTrue: [
            isOctal := true.
        ] ifFalse: [
            isOctal := false.
        ].

        ^isOctal.
    ]

    getFirstOctalDigit: word [
        | letter next_letter |
        letter := UnicodeString with: (Character codePoint: 0).
        (string_index+1 <= (word size)) ifTrue: [
            self setStringIndex: string_index+1.
            next_letter := (word at: string_index).
            ((self isOctalDigit: next_letter) == true) ifTrue: [
                letter := next_letter.
            ] ifFalse: [
                self setStringIndex: string_index-1.
                self setEnvEcho: false.
            ].
        ].

        ^letter.
    ]

    getSpecialDigitValue: word current_letter: current_letter [
        | letter next_letter temporary |
        (string_index+1 <= (word size)) ifTrue: [
            letter := ((current_letter asciiValue) - ($0 asciiValue)).
            self setStringIndex: string_index+1.
            next_letter := (word at: string_index).
            temporary := ((next_letter asciiValue) - ($0 asciiValue)).
            letter := (letter * 8 + temporary) asInteger.
            (string_index+1 <= (word size)) ifTrue: [
                self setStringIndex: string_index+1.
                next_letter := (word at: string_index).
                temporary := ((next_letter asciiValue) - ($0 asciiValue)).
                letter := (letter * 8 + temporary) asInteger.
            ].
            letter := UnicodeString with: (Character codePoint: letter).
        ].

        ^letter.
    ]

    isExpectedBackslash: letter [
        | conversion_letters interrupt_letters special_letters all_letters |

        special_letters := #($a $b $e $f $n $r $t $v).
        interrupt_letters := #($c).
        conversion_letters := #($x $0 $1 $2 $3 $4 $5 $6 $7).
        all_letters := special_letters, interrupt_letters, conversion_letters.

        ^(all_letters includes: letter).
    ]

    setAllowOptions: status [
        allow_options := status.
    ]

    setMessageStartPosition: position [
        message_start_argc := position.
    ]

    setEspaceOption: status [
        has_escape_option := status.
    ]

    setBreakLine: status [
        has_break_line_option := status.
    ]

    setStringIndex: index [
        string_index := index.
    ]

    setEnvEcho: status [
        is_env_echo := status.
    ]

    showHelp [
        Transcript show: 'Uso: ', PROGRAM_NAME, ' [OPÇÃO-CURTA]... [TEXTO]...' ; cr.
        Transcript show: ' ou: ', PROGRAM_NAME, ' OPÇÃO-LONGA' ; cr ;
        show: 'Ecoa o(s) TEXTO(s) para a saída padrão.' ; cr ;
        cr ;
        show: '  -n             não emitir o caractere de nova linha do final do TEXTO' ; cr ;
        show: '  -e             habilita a interpretação de escape por barra invertida' ; cr.
        (DEFAULT_ECHO_TO_XPG == true) ifTrue: [
            Transcript show: '                   (padrão)' ; cr.
        ].
        Transcript show: '  -E             desabilita a interpretação de escape por barra invertida' ; cr.
        (DEFAULT_ECHO_TO_XPG == false) ifTrue: [
            Transcript show: '                   (padrão)' ; cr.
        ].
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
        show: 'ou disponível localmente via: info "(coreutils) echo invocation"' ; cr.
    ]
]

echo := Echo new: Smalltalk arguments.
