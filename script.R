### nome <- "Lucas E. O. Silva"
### programa <- "Mestrado em Ciência Política"
### n_usp <- 1023663
### data_entrega: "XX/XX/2017"

require(dplyr)
require(openxlsx)
require(stringr)


# definindo o wd onde os arquivos baixados serão armazenados
setwd("C://Users//user03//Desktop//desafio3")

# link da base do ibge "Perfil dos Municípios Brasileiros 2015"
ibge_link <- "ftp://ftp.ibge.gov.br/Perfil_Municipios/2015/Base_de_Dados/Base_MUNIC_2015_xls.zip"

# criando o arquivo temporário para "armazenar" o download
temp <- tempfile()

# baixando a base
download.file(ibge_link,temp)

# descompactando, já que ela vem no formato .zip
unzip(temp)

# escolhi trabalhar com as informações referentes aos "Recursos de gestão"
base_ibge1 <- readxl::read_xls("Base_MUNIC_2015.xls", sheet = 4, na = "-")

# mais especificamente, irei trabalhar com as seguintes variáveis, refentes à cobrança...
# de taxas municipais: a) Taxa de iluminação pública (A73), b) Taxa de coleta de lixo (A74),
# c) Taxa de incêndio ou combate a sinistros (A75) d) Taxa de limpeza urbana (A76) e
# e) Taxa de poder de polícia (A77)
recursos_gestao <- base_ibge %>%
                   select(A1, Codigouf, Codigomunicipio, Nome, A73, A74, A75, A76, A77)

# esse procedimento é só para capturar as informações populacionais dos municípios, que...
# se encontram em uma outra tabela
base_ibge2 <- readxl::read_xls("Base_MUNIC_2015.xls", sheet = 8, na = "-")
populacao <- base_ibge2 %>%
             select(A1, A199, A203, A204)

# mergindo os dois frames as informações do ibge
informacoes_ibge <- recursos_gestao %>%
                    inner_join(populacao, by = "A1")

# realizarei alguns ajustes estilísticos na base

## 1 - renomear as variáveis
informacoes_ibge <- informacoes_ibge %>%
                    rename(CodIbge7 = A1, 
                           CodUf = Codigouf,
                           CodMun = Codigomunicipio,
                           NomeMun = Nome,
                           IlumPub = A73,
                           ColLixo = A74,
                           IncSis = A75,
                           LimpUrb = A76,
                           Police = A77,
                           Regiao = A199,
                           ClassPop = A203,
                           Pop = A204)
## 2 - criarei a variável ibge6, que será útil para mergir as outras bases
informacoes_ibge$CodIbge6 <- str_sub(informacoes_ibge$CodIbge7, 1, nchar(informacoes_ibge$CodIbge7)-1)

## 3 - mudando a ordem das variáveis
informacoes_ibge <- informacoes_ibge %>%
                    select(CodIbge7, CodIbge6, CodUf, CodMun, NomeMun, Regiao, Pop, ClassPop,
                           IlumPub, ColLixo, IncSis, LimpUrb, Police)

## 4 - retirando os caracteres indesejáveis de algumas variáveis
informacoes_ibge$Regiao <- str_sub(informacoes_ibge$Regiao, 5, nchar(informacoes_ibge$Regiao))
informacoes_ibge$Regiao <- factor(informacoes_ibge$Regiao)

informacoes_ibge$ClassPop <- str_sub(informacoes_ibge$ClassPop, 5, nchar(informacoes_ibge$ClassPop))
informacoes_ibge$ClassPop <- factor(informacoes_ibge$ClassPop, levels = c("Até 5000", "5001 até 10000", "10001 até 20000", "20001 até 50000", "50001 até 100000", "100001 até 500000", "Maior que 500000"))
