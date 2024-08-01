library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", host="0.0.0.0", port="5432", user="postgres", password="S3cret")
png(file="../grafici/distribuzione_orari.png")

orari_arrivo <-  dbGetQuery(con, "SELECT EXTRACT(EPOCH FROM (orario_arrivo)) AS orario FROM Tratta")$orario;
par(mar=c(7,4,4,4))
plot(density(orari_arrivo),las=2,xaxt="n",xlab="",yaxt="n",ylab="",xlim=c(0,24*60*60),main="Distribuzione arrivo in base all'orario")
axis(1,at=seq(0,24*60*60,3*60*60),gettextf("%02d:00",0:8*3), las=2)
title(xlab="Orari arrivo", line=4, cex.lab=1.1)
title(ylab="Densità", line=1, cex.lab=1.1)

dev.off()
dbDisconnect(con)