Siconfi <- function(path){
  
  # definindo o wd onde os arquivos baixados serao armazenados
  setwd(path)

  # em relação aos dados do tesouro, selecionei as Despesas Orçamentárias - Pagas (Anexo I-D)
  # referentes ao ano de 2015. O intuito é analisar os valores gastos pelos municípios.
  # Obs.: a base está desagregada por transação, contudo há linhas que contém o total
  siconfi <- read.csv("finbra.csv", header = T, sep=";", stringsAsFactors = F)
  
  siconfi <- siconfi[siconfi$Conta=="Total Geral da Despesa",]
  siconfi$Valor <- as.numeric(str_replace(siconfi$Valor,",","."))
  
  # agora o passo é renomear, reestruturar e selecionar variáveis de interesse
  siconfi <- siconfi %>%
          dplyr::rename(CodIbge7 = Cod.IBGE,
                    SiglaUf = UF,
                    TotalDesp = Valor)
  
  siconfi$CodIbge6 <- str_sub(siconfi$CodIbge7, 1, nchar(siconfi$CodIbge7)-1)
  siconfi$CodIbge6 <- as.integer(siconfi$CodIbge6)
  
  
  siconfi <- siconfi %>%
    dplyr::select(CodIbge7, CodIbge6, TotalDesp)
  
  return (siconfi)
}