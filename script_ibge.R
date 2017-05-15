Ibge <- function(path){
  # definindo o wd onde os arquivos baixados serao armazenados
  setwd(path)
  
  # link da base do ibge "Perfil dos Municipios Brasileiros 2015"
  ibge_link <- "ftp://ftp.ibge.gov.br/Perfil_Municipios/2015/Base_de_Dados/Base_MUNIC_2015_xls.zip"
  
  # criando o arquivo temporario para "armazenar" o download
  temp <- tempfile()
  
  # baixando a base
  download.file(ibge_link,temp)
  
  # descompactando, ja que ela vem no formato .zip
  unzip(temp)
  
  # escolhi trabalhar com as informacoes referentes aos "Recursos de gestao"
  base_ibge1 <- readxl::read_xls("Base_MUNIC_2015.xls", sheet = 4, na = "-")
  
  # mais especificamente, irei trabalhar com as seguintes variaveis, refentes a cobrancas...
  # de taxas municipais: a) Taxa de iluminacaoo publica (A73), b) Taxa de coleta de lixo (A74),
  # c) Taxa de incendio ou combate a sinistros (A75) d) Taxa de limpeza urbana (A76) e
  # e) Taxa de poder de policia (A77)
  recursos_gestao <- base_ibge1 %>%
    dplyr::select(A1, Codigouf, Codigomunicipio, Nome, A73, A74, A75, A76, A77)
  
  # esse procedimento eh realizado para capturar as informacoes populacionais dos municipios, que...
  # se encontram em uma outra tabela
  base_ibge2 <- readxl::read_xls("Base_MUNIC_2015.xls", sheet = 8, na = "-")
  populacao <- base_ibge2 %>%
               select(A1, A199, A203, A204)
  
  # mergindo os dois frames as informacoes do ibge
  informacoes_ibge <- recursos_gestao %>%
                      inner_join(populacao, by = "A1")
  
  # realizarei alguns ajustes estilisticos na base
  
  ## 1 - renomear as variaveis
  informacoes_ibge <- informacoes_ibge %>%
    dplyr::rename(CodIbge7 = A1, 
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
  ## 2 - criarei a variavel ibge6, que sera util para mergir as outras bases
  informacoes_ibge$CodIbge6 <- str_sub(informacoes_ibge$CodIbge7, 1, nchar(informacoes_ibge$CodIbge7)-1)
  
  ## 2.1 - padronizando para fazer com que todas as variáveis pk sejam integer 
  informacoes_ibge$CodIbge6 <- as.integer(informacoes_ibge$CodIbge6) 
  informacoes_ibge$CodIbge7 <- as.integer(informacoes_ibge$CodIbge7)
  informacoes_ibge$CodUf <- as.integer(informacoes_ibge$CodUf)
  informacoes_ibge$CodMun <- as.integer(informacoes_ibge$CodMun)
    
  
  ## 3 - mudando a ordem das variaveis
  informacoes_ibge <- informacoes_ibge %>%
    dplyr::select(CodIbge7, CodIbge6, CodUf, CodMun, NomeMun, Regiao, Pop, ClassPop,
                             IlumPub, ColLixo, IncSis, LimpUrb, Police)
  
  ## 4 - retirando os caracteres indesejaveis de algumas variaveis
  informacoes_ibge$Regiao <- str_sub(informacoes_ibge$Regiao, 5, nchar(informacoes_ibge$Regiao))
  informacoes_ibge$Regiao <- factor(informacoes_ibge$Regiao)
  
  informacoes_ibge$ClassPop <- str_sub(informacoes_ibge$ClassPop, 5, nchar(informacoes_ibge$ClassPop))
  informacoes_ibge$ClassPop <- factor(informacoes_ibge$ClassPop, levels = c("Até 5000", "5001 até 10000", "10001 até 20000", "20001 até 50000", "50001 até 100000", "100001 até 500000", "Maior que 500000"))
  
  informacoes_ibge$IlumPub <- factor(informacoes_ibge$IlumPub, levels = c("Não","Recusa", "Sim"))
  informacoes_ibge$ColLixo <- factor(informacoes_ibge$ColLixo, levels = c("Não","Recusa", "Sim"))
  informacoes_ibge$IncSis <- factor(informacoes_ibge$IncSis, levels = c("Não","Recusa", "Sim"))
  informacoes_ibge$LimpUrb <- factor(informacoes_ibge$LimpUrb, levels = c("Não","Recusa", "Sim"))
  informacoes_ibge$Police <- factor(informacoes_ibge$Police, levels = c("Não","Recusa", "Sim"))
  return(informacoes_ibge)
}
