#
# Run this script with "source("script.R")"
#

# create connection
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", user="postgres", password="S3cret")
set.seed(1234)
#define function to generate a alphanumeric string range
# stringrange = function(x,y){
#     full =unlist(lapply(LETTERS[which(LETTERS==substr(x,1,1)):which(LETTERS==substr(y,1,1))],
#             function(x){paste0(x,gettextf(paste0("%02d"),0:99))}))
#     full[which(full==x):which(full==y)]
#     }



cifre <- gettextf(paste0("%01d"),0:9)

genIdNumber= function(n){
    unlist(lapply(1:n,
	   function(x){
		   paste0(c(sample(cifre,2),sample(cifre,2),sample(LETTERS,6),sample(cifre,5)),collapse="")
	   }))
}
# set schema to "passeggero"
dbGetQuery(con, "SET search_path TO public;")


# populate table Passeggero
    v_nomi <- readLines("dati/nomi.txt")
    v_cognomi <- readLines("dati/cognomi.txt")
    passeggero_df <- data.frame(idpasseggero = sample(1:1000000, 10000, replace=F),
                            nome=sample(v_nomi, 10000, replace = T),
                            cognome=sample(v_cognomi, 10000, replace = T),
                            numero_documento_identita=sample(genIdNumber(10000),10000))
    dbWriteTable(con, 
                name="passeggero", 
                value=passeggero_df, 
                append = T, 
                row.names=F)





# populate table Areoporto
    v_citta <- readLines("dati/aeroporto_citta.txt")
    v_nazioni <- readLines("dati/nazioni.txt")
    v_nomi_aeroporti <- readLines("dati/aeroporto_nome.txt")

    prefV=function(v1){
    unlist(lapply(v1,function(x){
        unlist(lapply(LETTERS,function(y){
            paste0(x,y)
        }))
        }
    ))}

    v_code <- prefV(prefV(LETTERS))

    areoporto_df <- data.frame(
        codice_aeroporto = sample(v_code,100,replace=F),
        citta = sample(v_citta,100),
        nome = sample(v_nomi_aeroporti,100),
        nazione = sample(v_nazioni,100)
    )

    dbWriteTable(con, 
                name="aeroporto", 
                value=areoporto_df, 
                append = T, 
                row.names=F)

# populate table Compagnia Aerea
    v_nome <- readLines("dati/compagnie_nomi.txt")
    Compagnia_Aerea_df = data.frame(
        idcompagnia = sample(v_code,80,replace=F),
        nome = sample(v_nome,80,replace=F)
    )

    dbWriteTable(con, 
                name="compagnia_aerea", 
                value=Compagnia_Aerea_df, 
                append = T, 
                row.names=F)





# populate table Volo

    Tratte <- dbGetQuery(con, "SELECT a1.codice_aeroporto as C1, a2.codice_aeroporto as C2 
                                FROM Aeroporto A1, Aeroporto A2 
                                WHERE a1.codice_aeroporto != a2.codice_aeroporto")
    selected<-sample(1:nrow(Tratte),100)
    voli_partenze <- Tratte$c1[selected]
    voli_arrivi <- Tratte$c2[selected]
    id_Voli=1:100

    genTime=function(){
        paste0(c(sample(0:23,1),':',sample(0:23,1),':00'),collapse="")
    }


    Volo_df = data.frame(
        idvolo=id_Voli,
        orario_partenza=unlist(lapply(1:100,function(n){genTime()})),
        orario_arrivo=unlist(lapply(1:100,function(n){genTime()})),
        aeroporto_partenza = voli_partenze,
        aeroporto_arrivo = voli_arrivi
    )

    dbWriteTable(con, 
        name="volo", 
        value=Volo_df, 
        append = T, 
        row.names=F)






# # populate table Tipo_aeroplano
# nome_tipo <- readLines("dati/aeroplani_nome.txt")
# autonomia_volo <- sample(1000:10000, 100, replace=T)
# numero_massimo_posti <- sample(100:500, 100, replace=T)
# nome_azienda_costruttrice <- readLines("dati/aeroplani_costruttori.txt")
# dbWriteTable(con, 
#              name="Tipo_aeroplano", 
#              value=data.frame(nome_tipo=nome_tipo, autonomia_volo=autonomia_volo), 
#              append = T, 
#              row.names=F)




# # populate table Volo

# volo_df <- data.frame(
#         idVolo = sample(1:100000,100,replace=F),
#         orario_partenza 
# )

# #https://stackoverflow.com/questions/71898351/random-timestamp-generation-in-r

# # populate table "iscritto_a"
# # cdl
# temp_cdl <- dbGetQuery(con, "SELECT nome FROM corsi_di_laurea;")
# temp_cdl <- temp_cdl$nome
# iscritto_a.cdl <- sample(temp_cdl, 10000, replace=T)
# # matricola
# temp_matricola <- dbGetQuery(con, "SELECT matricola FROM studenti")
# iscritto_a.stud <- temp_matricola$matricola
# # anno
# iscritto_a.anno <- sample(1978:2023, 10000, replace=T)
# iscritto_a_df <- data.frame(cdl=iscritto_a.cdl,
#                             stud=iscritto_a.stud,
#                             anno=iscritto_a.anno)
# dbWriteTable(con, name="iscritto_a",
#                  value=iscritto_a_df, row.names=F, append = T)

# # populate "iscritto_a" with the 1% of previous students, so that 1% of
# # the students is enrolled to 2 courses
# # cdl
# temp_cdl <- dbGetQuery(con, "SELECT nome FROM corsi_di_laurea")
# temp_cdl <- temp_cdl$nome
# iscritto_a.cdl <- sample(temp_cdl, 100, replace=T)
# # matricola
# temp_matricola <- dbGetQuery(con, "SELECT matricola FROM studenti")
# temp_matricola <- temp_matricola$matricola
# iscritto_a.stud <- sample(temp_matricola, 100, replace=F)
# # anno
# iscritto_a.anno <- sample(1978:2023, 100, replace=T)
# iscritto_a_df <- data.frame(cdl=iscritto_a.cdl,
#                             stud=iscritto_a.stud,
#                             anno=iscritto_a.anno)
# # remove the tuples (cdl,stud,anno) in "iscritto_a_df" that are already in
# # table "iscritto_a"
# x <- dbGetQuery(con,
#                  "SELECT cdl,stud,anno
#                  FROM iscritto_a")
# iscritto_a_df <- data.frame(setdiff(iscritto_a_df,x))
# # write table
# dbWriteTable(con, name="iscritto_a", value=iscritto_a_df,
#              append=T, row.names=F)

# # plot: "numero iscritti per anno"
# df <- dbGetQuery(con,
#                  "SELECT anno, count(*)
#                  FROM iscritto_a
#                  GROUP BY anno
#                  ORDER BY anno")
# plot(df$anno, df$count, "o")

# # plot: "numero iscritti per anno (1993,1997,1999) e corso di laurea"
# x11()
# df <- dbGetQuery(con,
#                  "SELECT anno, cdl, count(*)
#                  FROM iscritto_a
#                  WHERE anno='1993' OR anno='1997' or anno='1999'
#                  GROUP BY anno, cdl
#                  ORDER BY anno, cdl")
# matr <- matrix(df$count, nrow = length(unique(df$cdl)))
# rownames(matr) <- unique(df$cdl)
# matr <- t(matr)
# barplot(matr, beside = TRUE)

# # grafico a barre degli studenti divisi per sesso e corsi di laurea
# df <- dbGetQuery(con,
#                  "SELECT cdl, sesso, count(*)
#                  FROM studenti JOIN iscritto_a ON matricola = stud
#                  GROUP BY cdl, sesso
#                  ORDER BY cdl, sesso")
# matr <- matrix(df$count, nrow = 2)
# rownames(matr) <- c("f","m")
# colnames(matr) <- unique(df$cdl)
# x11()
# barplot(matr)
# x11()
# barplot(matr, beside=T)
