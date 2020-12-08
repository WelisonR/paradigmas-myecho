#! /bin/sh
"exec" "gst" "$0" "--smalltalk-args" "$@"

Smalltalk at: #PACKAGE_NAME put: 'GNU coreutils' .
Smalltalk at: #PROGRAM_NAME put: 'echo'.
Smalltalk at: #PROGRAM_VERSION put: '1.00' .
Smalltalk at: #AUTHORS put: #('Welison Regis') .

Smalltalk at: #DEFAULT_ECHO_TO_XPG put: false .

Object subclass: Echo [
    | argc argv |

    Echo class >> new: args [
        | r |
        r := super new .
        r setArguments: args .
        ^r .
    ]

    init [
        (argc = 1) ifTrue: [
            ((argv at: 1) = '--help') ifTrue: [
                self showHelp .
            ] .
            ((argv at: 1) = '--version') ifTrue: [
                self showVersion .
            ] .
        ] .
    ]

    setArguments: args [
        argc := args size .
        argv := args .
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
echo init .
" echo showHelp . "
" echo printNl . "