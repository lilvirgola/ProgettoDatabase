library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", host="0.0.0.0", port="5432", user="postgres", password="S3cret")

png(file="../grafici/prezzo_compagnia.png")

view <- "
            CREATE OR REPLACE VIEW Prezzo_medio_volo_compagnia AS
            SELECT CA.nome AS nome_compagnia, AVG(DC.prezzo) AS prezzo_medio,V.id_volo, (V.orario_arrivo-V.orario_partenza) AS durata
            FROM Compagnia_aerea AS CA
            JOIN Volo AS V ON CA.id_compagnia = V.id_compagnia
            JOIN Dispone_Classe AS DC ON DC.volo = V.id_volo
            GROUP BY CA.nome, V.id_volo
            ORDER BY nome_compagnia ASC;
         "
result <- dbSendQuery(con, view)

query <- "
            SELECT nome_compagnia, AVG(prezzo_medio) AS prezzo_medio, COUNT(id_volo) AS numero_voli, AVG(durata) AS durata_media
            FROM Prezzo_medio_volo_compagnia
            GROUP BY nome_compagnia;
         "
df <- dbGetQuery(con, query)
for (i in 1:nrow(df)) {
    t1<-as.POSIXct(df$durata_media[i], "%H:%M:%OS", tz="UTC")
    t0<-as.POSIXct("0:0:0", "%H:%M:%OS", tz="UTC")
    df$durata_media[i]<- difftime(t1, t0, units="secs")
}
df$durata_media<-as.numeric(df$durata_media)
df$durata_media<-df$durata_media/60
#metto in prezzo medio il prezzo al minuto
#print(df$prezzo_medio)
df$prezzo_medio<-df$prezzo_medio/df$durata_media
#print(df$nome_compagnia)
par(mar=c(5,10,5,5))
barplot(height=df$prezzo_medio, names=df$nome_compagnia, horiz=T, las=1,xaxt="n", col="#69b3a2", xlab="Prezzo medio al minuto",  main="Prezzo medio al minuto per compagnia aerea")
title(ylab="Compagnia aerea", line=9, cex.lab=1.1)
axis(1,at=seq(0,max(df$prezzo_medio),max(df$prezzo_medio)/5),gettextf("%.2f€",seq(0,max(df$prezzo_medio),max(df$prezzo_medio)/5)))
par(mar=c(5,5,5,5))
#plot(, df$prezzo_medio, type="h", col="blue", xlab="Compagnia aerea", ylab="Prezzo medio al minuto", main="Prezzo medio al minuto per compagnia aerea")

dev.off()
dbDisconnect(con)