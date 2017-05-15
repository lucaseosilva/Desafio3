AtlasBrasil <- function(path){
# definindo o wd onde os arquivos baixados serao armazenados
setwd(path)

# A base selecionada foi extraida do site do Atlas Brasil: http://www.atlasbrasil.org.br/2013/pt/consulta/
# Parâmetros selecionados:
## 1) Espacialidade: Municípios
## 2) Indicadores: Habitação (Todos)
### % da população em domicílios com água encanada
### % da população em domicílios com banheiro e água encanada
### % da população em domicílios com coleta de lixo
### % da população em domicílios com energia elétrica
### % da população em domicílios com densidade > 2
# A linha referente ao total do Brasil foi excluída
atlas <- read.csv("AtlasBrasil_Consulta.csv", header = T, sep=";", stringsAsFactors = F)

# realizando as modicações nas variáveis
## desagregando a variável uf
atlas$uf <- str_sub(atlas$Lugar, nchar(atlas$Lugar)-4, nchar(atlas$Lugar))
atlas$uf <- str_replace(atlas$uf,"\\(","")
atlas$uf <- str_replace(atlas$uf,"\\)","")

## mudando a variável da cidade
atlas$Lugar <- str_sub(atlas$Lugar, 1, nchar(atlas$Lugar)-5)

# assim como foi feito nas outras, também será feita aqui a renomeação e a reordenação

atlas <- atlas %>%
  dplyr::rename(NomeMun = Lugar,
                SiglaUF = uf,
                CodIbge6 = COD.IBGE,
                AguaEnc = X..da.população.em.domicílios.com.água.encanada..2010.,
                BanAguaEnc = X..da.população.em.domicílios.com.banheiro.e.água.encanada..2010.,
                ColLixoPc = X..da.população.em.domicílios.com.coleta.de.lixo..2010.,
                EnergEle = X..da.população.em.domicílios.com.energia.elétrica..2010.,
                Densidade = X..da.população.em.domicílios.com.densidade...2..2010.)
  
atlas <- atlas %>%
  dplyr::select(CodIbge6, AguaEnc, BanAguaEnc, ColLixoPc, EnergEle, Densidade)

# por fim, o próximo procedimento é mudar o tipo das variáveis númericas que vieram
# como string por causa da vírgula
atlas$AguaEnc <- as.numeric(str_replace(atlas$AguaEnc,",","."))
atlas$BanAguaEnc <- as.numeric(str_replace(atlas$BanAguaEnc,",","."))
atlas$ColLixoPc <- as.numeric(str_replace(atlas$ColLixoPc,",","."))
atlas$EnergEle <- as.numeric(str_replace(atlas$EnergEle,",","."))
atlas$Densidade <- as.numeric(str_replace(atlas$Densidade,",","."))

return (atlas)
}