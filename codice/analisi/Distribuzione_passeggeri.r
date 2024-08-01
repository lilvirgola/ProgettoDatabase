library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", host="0.0.0.0", port="5432", user="postgres", password="S3cret")

png(file="../grafici/distribuzione_passeggeri.png")

# Creazione vista Distribuzione_passeggeri
query <- "
            CREATE OR REPLACE VIEW Distribuzione_passeggeri AS
            SELECT COUNT(P.id_prenotazione) AS numero_passeggeri, T.aeroporto_partenza, T.aeroporto_arrivo
            FROM Istanza_Tratta AS IT 
            JOIN Tratta AS T ON IT.id_tratta = T.id_tratta
            JOIN Comprende AS C ON T.id_tratta = C.id_tratta
            JOIN Prenotazione AS P ON C.id_prenotazione = P.id_prenotazione
            GROUP BY t.id_tratta
            ORDER BY numero_passeggeri ASC;
        "
dbSendQuery(con, query)
# Analisi Distribuzione_passeggeri
query <- "
            SELECT numero_passeggeri, COUNT(*) AS numero_tratte
            FROM Distribuzione_passeggeri
            GROUP BY numero_passeggeri
            ORDER BY numero_passeggeri ASC;   
        "
df <- dbGetQuery(con, query)
# Grafico Distribuzione_passeggeri
numero_possibili <- merge(data.frame(numero_passeggeri=1:max(df$numero_passeggeri)),df,by="numero_passeggeri",all.x=T)
numero_possibili$numero_tratte[is.na(numero_possibili$numero_tratte)] <- 0

barplot(names=numero_possibili$numero_passeggeri, height=numero_possibili$numero_tratte, xlab = "Numero Passeggeri", ylab = "Numero Tratte", main = "Distribuzione Passeggeri")

dev.off()
dbDisconnect(con)