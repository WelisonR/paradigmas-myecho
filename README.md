# Utilitário echo em Smalltalk

**Disciplina**: Paradigmas de Programação (UnB/FGa) - Professor Edson Alves.<br>
**Tópicos**: portabilidade de código, gnu coreutils echo, orientação a objetos, c, smalltalk.<br>

## Sobre o Projeto

**Vídeo sobre o projeto no youtube**: [GNU echo em Smalltalk](https://youtu.be/jkfuAePcw0s).

O trabalho tem por objetivo realizar o porte do código do utilitário _echo_ do _GNU coreutils_ da linguagem _C_ para a linguagem _Smalltalk_ (GNU) com foco no paradigma de Orientação a Objetos, baseado na [documentação oficial da ferramenta](https://www.gnu.org/software/coreutils/manual/html_node/echo-invocation.html#echo-invocation) e no código-fonte disponibilizado no [GitHub](https://github.com/wertarbyte/coreutils/blob/master/src/echo.c). O programa foi desenvolvido com técnicas de Test-driven development (TDD) com testes definidos no script _test.sh_.

Observação: conforme documentado na página oficial do GNU, a fim de evitar interferências do _shell_, deve-se invocar o _echo_ com o comando `env echo`.

## Instalação do GNU Smalltalk

Instale o GNU Smalltalk pelo gerenciador de pacotes:

```
$   sudo apt-get install gnu-smalltalk
```

## Execução do Projeto

Para executar o projeto, faça o clone do repositório e confira os comandos disponíveis:

```
$   ./myecho.st --help
```

*   Verifique mais detalhes de uso na [documentação oficial do echo](https://www.gnu.org/software/coreutils/manual/html_node/echo-invocation.html#echo-invocation).

Para verificar a integridade do porte do código, execute os testes definidos em _script_:

```
$   ./test.sh
```

*   Caso haja alguma diferença entre as saídas do programa oficial e do programa em Smalltalk, serão apresentadas comparações linha a linha com as divergências de texto.

Observações:

*   Caso necessário, dê permissão de execução ao programa e ao _script_ de teste com o comando: `chmod +x [file_path]`.

## Autor

|Matrícula | Estudante |
| -- | -- |
| 17/0024121  |  Welison Lucas Almeida Regis |

## Referências

[1] ALVES, Edson. Paradigmas de Programação - Orientação a Objetos em Smalltalk. Disponível em: [Paradigmas - Orientação a Objetos](https://github.com/edsomjr/Paradigmas). Acesso em: 08/12/2020.

[2] GROVER, Jigyasa. Learn X in Y minutes - Smalltalk. Disponível em: [Learn X in Y minutes - Smalltalk](https://learnxinyminutes.com/docs/smalltalk/). Acesso em: 12/12/2020.

[3] GNU. echo invocation (GNU coreutils). Disponível em: [coreutils echo](https://www.gnu.org/software/coreutils/manual/html_node/echo-invocation.html#echo-invocation). Acesso em: 12/12/2020.
