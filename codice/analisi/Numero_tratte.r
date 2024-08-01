library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", host="0.0.0.0", port="5432", user="postgres", password="S3cret")
png(file="../grafici/numero_tratte.png")

view <- "
            CREATE OR REPLACE VIEW Numero_tratte AS
            SELECT P.id_passeggero, COUNT(IT.id_tratta) AS Numero_tratte
            FROM Passeggero AS P
            JOIN Prenotazione AS PR ON P.id_passeggero = PR.Passeggero
            JOIN Comprende AS C ON PR.id_prenotazione = C.id_prenotazione
            JOIN Istanza_Tratta as IT ON C.id_tratta = IT.id_tratta
            GROUP BY P.id_passeggero;
         "
result <- dbSendQuery(con, view)
query <- "
            SELECT numero_tratte, COUNT(*) AS numero_passeggeri
            FROM Numero_tratte
            GROUP BY numero_tratte
            ORDER BY numero_tratte ASC;
         "
df <- dbGetQuery(con, query)
dbDisconnect(con)
barplot(name=df$numero_tratte, height=df$numero_passeggeri, ylim=c(0,max(df$numero_passeggeri)+5), xlab="Numero tratte", ylab="Numero passeggeri", main="Numero tratte prenotate per passeggero")


dev.off()
dbDisconnect(con)