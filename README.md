# Desafio3
================

Informações do aluno:
---------------------

-   **Nome**: Lucas E. O. Silva
-   **Programa**: Mestrado em Ciência Política
-   **Data de entrega**: 16/05/2017

Descrição da atividade
----------------------

O objetivo do trabalho é construir uma base de dados, a partir de diferentes fontes, desagregada por município. Para isso, foram selecionados quatro repositórios de informações públicas:

1.  [Perfil dos Municípios Brasileiros (IBGE)](http://www.ibge.gov.br/home/estatistica/economia/perfilmunic/2015/default.shtm);
2.  [Informações Financeiras e Fiscais dos Municípios (Tesouro Nacional)](https://siconfi.tesouro.gov.br/siconfi/pages/public/consulta_finbra/finbra_list.jsf);
3.  [Estatísticas sobre óbitos (DATASUS)](http://tabnet.datasus.gov.br/cgi/deftohtm.exe?sim/cnv/pobt10br.def);
4.  [Atlas Brasil (PNUD)](www.atlasbrasil.org.br/2013/pt/consulta/);

Com exceção dos dados do Atlas Brasil, que se referem ao censo de 2010, todos os demais são referentes ao ano de 2015.

Ao fim, pretendo criar uma base de dados que contenha informações dos municípios no que se refere à urbanização e governança municipal.

Variáveis selecionadas
----------------------

1.  IBGE

Do Perfil dos Municípios Brasileiros, foram selecionadas as variáveis refentes a cobrancas de Taxas Municipais:

1.  Taxa de iluminacaoo publica (variável categórica);
2.  Taxa de coleta de lixo (variável categórica);
3.  Taxa de incendio ou combate a sinistros (variável categórica);
4.  Taxa de limpeza urbana (variável categórica);
5.  Taxa de poder de policia (variável categórica).

<!-- -->

1.  Tesouro Nacional:

Em relação aos dados financeiros e fiscais dos municípios, selecionei as Despesas Orçamentárias - Pagas (Anexo I-D) referentes ao ano de 2015. A base está desagregada por transação, contudo interessa-me apenas o total gasto por cada administração (variável contínua).

1.  DATASUS:

No que se refere aos dados de óbitos, foram selecionados aqueles por residência e de acordo com o Capítulo CID-10 (variável discreta). Essa categoria médica trata de algumas doenças infecciosas e parasitárias.

1.  PNUD:

Por fim, foram escolhidos cinco indicadores de habitação do Atlas Brasil, são eles:

1.  % da população em domicílios com água encanada (variável contínua);
2.  % da população em domicílios com banheiro e água encanada (variável contínua);
3.  % da população em domicílios com coleta de lixo (variável contínua);
4.  % da população em domicílios com energia elétrica (variável contínua);
5.  % da população em domicílios com densidade &gt; 2 (variável contínua).

Estratégia de operacionalização dos dados
-----------------------------------------

Ao invés de realizar o procedimento de coleta das informações em um só arquivo, com o intuito de não poluir visualmente o Global Environment com diversos tipos de objetos, decidi por modularizar o processo.

Criei quatro arquivos, cada um com uma função referente à leitura e/ou download das informações em cada repositório. Todas elas possuem um parâmetro em comum, `caminho`, que trata do local onde as informações referentes aquela determinada fonte estão/ficarão armazenadas.Os procedimentos em cada função são similares, o que diferencia são os ajustes feitos em algumas variáveis em particular.

Basicamente, cada código:

1.  Lê os arquivos com as informações de cada base por meio da função `read.csv()` do `utils`. No caso dos dados do IBGE, foi utilizada a função `read_xls()` do `readxl` pelo fato do arquivo não estar em .csv;
2.  Seleciona e renomeia as variáveis de interesse por meio, respectivamente, das funções `select()` e `rename()` do `dplyr`;
3.  Reestrutura o conteúdo de algumas variáveis, seja alterando sua classe ou atribuindo determinados fatores, seja removendo ou extraindo conteúdos de interesse por meio da função `str_sub()` do `stringr`.

A ideia é fazer com que cada função esteja disponível no Global Environment do usuário para que, a partir disso, ele possa concatenar os frames de cada repositório de uma maneira mais fácil e prática. O código abaixo exemplica:

``` r
# definindo o caminho dos arquivos
caminho <- "C://Users//user03//Desktop//desafio3"

# criando um objeto com cada base
base_ibge <- Ibge(caminho)
base_siconfi <- Siconfi(caminho)
base_data_sus <- DataSus(caminho)
base_atlas <- AtlasBrasil(caminho)

# estalecendo uma lista com o nome de todas as bases
L <- list(base_ibge, base_siconfi, base_data_sus, base_atlas)

# a função join_all, do pacote plyr, concatena todos os frames simultaneamente
# selecionei o left para nivelar a base geral de acordo com os dados do ibge, que possuem
# mais casos
geral <- join_all(L, type='left', by = "CodIbge6", match = "first")
```

A função `join_all()` do `plyr` permite com que possamos mergir vários dataframes de uma só vez. Para isso, é necessária a criação de uma lista contento todos os frames de interesse e, em seguida, informar o tipo da junção e nome da *primary-key* (campo presente em todos os frames).

Ao fim, o frame resultante tem 5570 observações e 21 variáveis, conforme mostra o código abaixo:

``` r
str(geral)
```

    ## 'data.frame':    5570 obs. of  21 variables:
    ##  $ CodIbge6  : int  110001 110002 110003 110004 110005 110006 110007 110008 110009 110010 ...
    ##  $ CodIbge7  : int  1100015 1100023 1100031 1100049 1100056 1100064 1100072 1100080 1100098 1100106 ...
    ##  $ CodUf     : int  11 11 11 11 11 11 11 11 11 11 ...
    ##  $ CodMun    : int  15 23 31 49 56 64 72 80 98 106 ...
    ##  $ NomeMun   : chr  "ALTA FLORESTA DOESTE" "ARIQUEMES" "CABIXI" "CACOAL" ...
    ##  $ Regiao    : Factor w/ 5 levels "Centro-Oeste",..: 3 3 3 3 3 3 3 3 3 3 ...
    ##  $ Pop       : num  25578 104401 6355 87226 17986 ...
    ##  $ ClassPop  : Factor w/ 7 levels "Até 5000","5001 até 10000",..: 4 6 2 5 3 3 2 3 4 4 ...
    ##  $ IlumPub   : Factor w/ 3 levels "Não","Recusa",..: 3 3 3 3 NA 3 3 3 3 3 ...
    ##  $ ColLixo   : Factor w/ 3 levels "Não","Recusa",..: 3 3 3 3 NA 3 3 1 3 3 ...
    ##  $ IncSis    : Factor w/ 3 levels "Não","Recusa",..: 1 1 1 3 NA 1 1 1 1 1 ...
    ##  $ LimpUrb   : Factor w/ 3 levels "Não","Recusa",..: 1 1 3 1 NA 3 3 1 3 3 ...
    ##  $ Police    : Factor w/ 3 levels "Não","Recusa",..: 3 3 3 3 NA 3 3 1 3 3 ...
    ##  $ TotalDesp : num  4.53e+07 1.78e+08 1.85e+07 1.63e+08 4.64e+07 ...
    ##  $ TxObResInf: int  6 24 NA 14 NA 2 1 2 1 8 ...
    ##  $ TxObResTot: int  6 24 NA 14 NA 2 1 2 1 8 ...
    ##  $ AguaEnc   : num  93.7 98.5 95.5 98 97.5 ...
    ##  $ BanAguaEnc: num  80.2 85.3 91.6 93.4 86.9 ...
    ##  $ ColLixoPc : num  94 96.7 99.1 98.2 91.9 ...
    ##  $ EnergEle  : num  94 98.6 96.4 98.9 98.8 ...
    ##  $ Densidade : num  22.6 27.1 19.9 20.5 16.7 ...

Análise exploratória dos dados
------------------------------

O intuito dessa seção é examinar as relaçãos entre as variáveis presentes no frame agregado. Para isso, serão utilizados recursos analíticos como tabelas, gráficos e mapas.

Através da Tabela 1, podemos constatar que a taxa de iluminação pública é a tarifa mais cobrada nos municipios brasileiros. Aproximadamente, 4 a cada 5 prefeituras cobram esse tipo de imposto. Em contra partida, a taxa contra incêndios e sismos é a menos cobrada, menos de 5% dos municípios adotam esse tipo de imposto.

|      Parâmetro     |  Sim  |  Não  | Recusa | Total |
|:------------------:|:-----:|:-----:|:------:|:-----:|
| Iluminação pública | 78.31 | 21.67 |  0.02  |  100  |
|   Coleta de lixo   | 52.23 | 47.75 |  0.02  |  100  |
|  Incêndio e Sismos |  4.48 | 95.50 |  0.02  |  100  |
|   Limpeza urbana   | 36.27 | 63.71 |  0.02  |  100  |
|       Polícia      | 48.74 | 51.24 |  0.02  |  100  |

O Gráfico 1 ilustra a proporção de habitantes dos municípios brasileiros. Podemos constatar que aproximadamente 85% das cidades possuem até 50.000 habitantes. Os municípios que possuem mais do que 500.000 habitantes representam apenas 7% do total nacional.

![](documentacao_files/figure-markdown_github/unnamed-chunk-4-1.png)

O Gráfico 2 ilustra o número de mortes por infecção em cada região geográfica. Constatamos que a região Sudeste possui a maior frequência. Muito disso se deve ao fato dela possuir o maior número de habitantes.

![](documentacao_files/figure-markdown_github/unnamed-chunk-5-1.png)

Já o Gráfico 3 mostra a associação entre a porcentagem de municípios com água encanada e coleta de lixo. Podemos observar que nas regiões Centro-Oeste e Sul essas variáveis são mais correlacionadas, enquando nas regiões Norte e Nordeste elas se encontram mais dispersas.

![](documentacao_files/figure-markdown_github/unnamed-chunk-6-1.png)

Por sua vez, o Gráfico 4 representa a associação entre o gasto dos municípios e com o total de habitantes. Examinamos que quando maior o número de habitantes, maior o dispêndio das prefeituras. A linha de tendência nos auxilia a verificar isso.

![](documentacao_files/figure-markdown_github/unnamed-chunk-7-1.png)

Para finalizar, o Mapa abaixo ilustra a porcentagem de habitações com energia elétrica nos municípios brasileiros.

![](documentacao_files/figure-markdown_github/unnamed-chunk-8-1.png)
