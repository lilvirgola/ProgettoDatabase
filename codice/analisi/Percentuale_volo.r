# calcolare la percentuale di tempo in volo medio in base al numero di tratte
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", host="0.0.0.0", port="5432", user="postgres", password="S3cret")

png(file="../grafici/tempo_volo.png")
tempo_volo <-  dbGetQuery(con, "select extract(epoch from (sum(orario_arrivo-orario_partenza))) as tempo,id_volo FROM Tratta T join Compone C on T.id_tratta=C.id_tratta group by id_volo order by id_volo");
tempo_totale <- dbGetQuery(con, "select extract(epoch from (sum(orario_arrivo-orario_partenza))) as tempo,id_volo FROM Volo GROUP BY id_volo order by id_volo");
numero_tratte <- dbGetQuery(con, "Select max(progressivo_tratta) as numero, id_volo from compone group by id_volo order by id_volo");

tempi_volo <- data.frame(
    volo = aggregate(tempo_volo$tempo, by=list(a= numero_tratte$numero),FUN=sum)$x,
    totale = aggregate(tempo_totale$tempo, by=list(a= numero_tratte$numero),FUN=sum)$x,
    numero = aggregate(numero_tratte$numero, by=list(a= numero_tratte$numero),FUN=sum)$a
)

tempi_volo$percentuale <-  tempi_volo$volo /tempi_volo$totale
pl <- barplot(tempi_volo$percentuale*100,names=tempi_volo$numero,xlab="Numero tratte",ylab="Percentuale tempo in volo",ylim=c(0,104));
text(pl,tempi_volo$percentuale*100+2, gettextf("%.1f %%",tempi_volo$percentuale*100),cex=1)

dev.off()
dbDisconnect(con)