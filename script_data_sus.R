DataSus <- function(path){

  # definindo o wd onde os arquivos baixados serao armazenados
  setwd(path)
  
  # A base selecionada foi extraida do site do DataSus com os seguintes paramentros:
  ## Óbitos p/Residênc por Capítulo CID-10 segundo Município
  ## Capítulo CID-10: I. Algumas doenças infecciosas e parasitárias
  ## Período: 2015
  ## Obs.: As linhas com valores "Total" e "Municipio ignorado - GO" foram removidas
  data_sus <- read.csv("data_sus.csv", header = T, sep="\t", stringsAsFactors = F)
  data_sus$Cod <- str_sub(data_sus$Município, 1, 6)
  data_sus$Município <- str_sub(data_sus$Município, 7, nchar(data_sus$Município))
  
  # renomear as variaveis para padroniza-las com as demais bases
  data_sus <- data_sus %>%
    dplyr::rename(NomeMun = Município, TxObResInf = Cap.I, 
                     TxObResTot = Total, CodIbge6 = Cod)
  
  # ordenar as variaveis 
  data_sus <- data_sus %>%
    dplyr::select(CodIbge6, TxObResInf, TxObResTot)
  
  # mudando o tipo do CodIbge6
  data_sus$CodIbge6 <- as.integer(data_sus$CodIbge6)
  
  return (data_sus)
}
