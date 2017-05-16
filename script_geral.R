### nome <- "Lucas E. O. Silva"
### programa <- "Mestrado em Ciência Política"
### n_usp <- 1023663
### data_entrega: "XX/XX/2017"

require(dplyr)
require(openxlsx)
require(stringr)
require(plyr)
require(ggplot2)
require(scales)
require(tmap)
require(leaflet)

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

# tabela com a frequência das variáveis categóricas do ibge
freq_ibge <- rbind(prop.table(table(geral$IlumPub,geral$ClassPop)),
                   prop.table(table(geral$ColLixo)),
                   prop.table(table(geral$IncSis)),
                   prop.table(table(geral$LimpUrb)),
                   prop.table(table(geral$Police)))
freq_ibge <- data.frame(freq_ibge)
freq_ibge <- freq_ibge*100
freq_ibge$Parâmetro <- c("Iluminação pública","Coleta de lixo","Incêndio e Sismos","Limpeza urbana","Polícia")
freq_ibge$Total <- freq_ibge$Não+freq_ibge$Recusa+freq_ibge$Sim
freq_ibge <- freq_ibge %>%
              select(Parâmetro, Sim, Não, Recusa, Total)
freq_ibge$Sim <-  as.numeric(sprintf("%0.2f", freq_ibge$Sim))
freq_ibge$Não <-  as.numeric(sprintf("%0.2f", freq_ibge$Não))
freq_ibge$Recusa <-  as.numeric(sprintf("%0.2f", freq_ibge$Recusa))
freq_ibge$Total <-  as.numeric(sprintf("%0.2f", freq_ibge$Total))

g <- ggplot(geral)

# proporção da populacao dos municipios
g+
  geom_bar(mapping = aes(x = ClassPop, y = ..prop.., group = 1))+
  labs(x = NULL, y = NULL,  subtitle = "teste")+
  coord_flip()+
  scale_y_continuous(labels = percent)

# frequencia dos obitos por infeccao
g+
  geom_bar(mapping = aes(x = reorder(Regiao, -TxObResInf), y = TxObResInf, fill=Regiao),
           stat = "identity")+
  labs(x = NULL, y = "Número de óbitos por infecção", fill="Região") +
  coord_flip()#+
  #scale_y_continuous(labels = percent)

# associação entre agua encanada e coleta de lixo por por
g+
  geom_point(mapping = aes(x = AguaEnc, y = ColLixoPc, color=Regiao))
  
# associacao entre gasto e populacao
g+
  geom_point(aes(x=log10(Pop),y=log10(TotalDesp)),position = "jitter")+
  geom_smooth(aes(x=log10(Pop),y=log10(TotalDesp)))

# criando o mapa

uf_shape <- read_shape("UFEBRASIL.shp")
mun_shape <- read_shape("MUNBRASIL.shp")
mun_shape@data$codigo_ibg <- as.integer(mun_shape@data$codigo_ibg)

qtm(mun_shape)
View(mun_shape@data)

mun_shape <- mun_shape[order(mun_shape@data$codigo_ibg),]
geral2 <- geral[order(geral$CodIbge7),]

#verificando se as duas coisas estão iguais
identical(mun_shape@data$codigo_ibg,geral2$CodIbge7)

#mergindo
map.completo <- tmap::append_data(mun_shape, geral2, key.shp = "codigo_ibg", key.data="CodIbge7",
fixed.order = F)

tm_shape(map.completo)+
  tm_fill("EnergEle")+
  tm_borders(alpha = 0.2)+
tm_shape(uf_shape)+
  tm_fill(alpha = 0)+
  tm_borders(alpha = 1)
