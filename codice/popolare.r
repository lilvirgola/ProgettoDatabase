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
    codici_documenti <- unlist(lapply(1:1550,
	   function(x){
        paste0(sample(c(0:9,LETTERS),15,replace=T),collapse="")
    }))
   
    passeggero_df <- data.frame(
        id_passeggero=1:1500,
        nome = sample(v_nomi,1500),
        cognome= sample(v_nomi,1500,replace=T),
        numero_documento_identita=sample(codici_documenti, 1500)
    )

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
        id_compagnia = sample(v_code,80,replace=F),
        nome = sample(v_nome,80,replace=F)
    )

    dbWriteTable(con, 
                name="compagnia_aerea", 
                value=Compagnia_Aerea_df, 
                append = T, 
                row.names=F)





# populate table tratta, volo, compone

    tratte <- dbGetQuery(con, "SELECT a1.codice_aeroporto as C1, a2.codice_aeroporto as C2 
                                FROM Aeroporto A1, Aeroporto A2 
                                WHERE a1.codice_aeroporto != a2.codice_aeroporto")
    selected<-sample(1:nrow(tratte),1000)
    voli_partenze <- tratte$c1[selected]
    voli_arrivi <- tratte$c2[selected]
    id_tratte=1:1000


    genTime <- function(){
        hs <- sample(0:22,1)
        ms <- sample(0:57,1)
        c(partenza=gettextf("%02d:%02d:00",hs,ms),arrivo=gettextf("%02d:%02d:00",sample(hs:23,1),sample((ms+1):59,1)))
    }
    orari <- sapply(1:1000,function(n){genTime()})

    tratte_df <- data.frame(
        id_tratta=id_tratte,
        orario_partenza=orari[1,1:1000],
        orario_arrivo=orari[2,1:1000],
        aeroporto_partenza = voli_partenze,
        aeroporto_arrivo = voli_arrivi
    )

    dbWriteTable(con, # da sistemare
        name="tratta", 
        value=tratte_df, 
        append = T, 
        row.names=F)



   
    concL <- function(l, e){
        data.frame(
            id_volo=c(l$id_volo,e$id_volo),
            orario_partenza=c(l$orario_partenza,e$orario_partenza),
            orario_arrivo=c(l$orario_arrivo,e$orario_arrivo),
            aeroporto_partenza = c(l$aeroporto_partenza,e$aeroporto_partenza),
            aeroporto_arrivo = c(l$aeroporto_arrivo,e$aeroporto_arrivo)
    )}

    sampleDF <- function(df){
        df[sample(1:length(df[,1]),1),]
    }


    compone_df <- data.frame(
        progressivo_tratta=list(),
        id_tratta=list(),
        id_volo=list()
        )


    voli_df <- data.frame(
        id_volo=list(),
        orario_partenza=list(),
        orario_arrivo=list(),
        aeroporto_partenza = list(),
        aeroporto_arrivo = list()
    )


    for (id_volo in 1:1000) {
        n_tratte=sample(1:6,1)

        t0 <- sampleDF(tratte_df)
        tc <- t0

        compone_df<- data.frame(
            progressivo_tratta=c(compone_df$progressivo_tratta,1),
            id_tratta=c(compone_df$id_tratta,t0$id_tratta),
            id_volo=c(compone_df$id_volo,id_volo)
        )

        for(progressivo_tratta in 2:n_tratte){
            poss <- subset(tratte_df,(aeroporto_partenza==tc$aeroporto_arrivo) & (orario_partenza>tc$orario_arrivo))
            
            if(length(poss[,1])==0){
                break;
            }
            if(length(poss[,1])==1){
                tc<- poss[1,]
            }else{
                tc<- sampleDF(poss)
            }
            compone_df<- data.frame(
                progressivo_tratta=c(compone_df$progressivo_tratta,progressivo_tratta),
                id_tratta=c(compone_df$id_tratta,tc$id_tratta),
                id_volo=c(compone_df$id_volo,id_volo)
            )
        }
    
        voli_df <- concL(voli_df, 
            data.frame(
                id_volo=id_volo,
                orario_partenza= t0$orario_partenza,
                orario_arrivo= tc$orario_arrivo,
                aeroporto_partenza = t0$aeroporto_partenza,
                aeroporto_arrivo = tc$aeroporto_arrivo
            ))        
    }

    dbWriteTable(con, 
        name="volo", 
        value=voli_df, 
        append = T, 
        row.names=F)

    dbWriteTable(con, 
        name="compone", 
        value=compone_df, 
        append = T, 
        row.names=F)















# populate table Classe
    classi <- readLines("dati/classi.txt")
    voli_classi <- c(voli_df$id_volo,sample(voli_df$id_volo,200,replace=T))
    volo_classe_df <- data.frame(
        volo = voli_classi,
        classe = sample(classi,length(voli_classi),replace=T)
    )

    unique_classe_df<-volo_classe_df[!duplicated(volo_classe_df),]
    classe_df <- data.frame(
        volo = unique_classe_df$volo,
        classe = unique_classe_df$classe,
        prezzo=sample(1:10000,length(unique_classe_df$volo))/100
    )

    dbWriteTable(con, 
        name="classe", 
        value=classe_df, 
        append = T, 
        row.names=F)


# populate table Tipo aeroplano
    nomi_tipo <- readLines("dati/aeroplani_nome.txt")
    nomi_costruttori <- readLines("dati/aeroplani_costruttori.txt")
    
	
    tipo_aeroplano_df <- data.frame(
        nome_tipo= sample(nomi_tipo,70),
        autonomia_volo = sample(100:10000,70)*100,
        numero_massimo_posti = sample(50:1000,70),
        nome_azienda_costruttrice = sample(nomi_costruttori, 70,replace=T)
    )

    dbWriteTable(con, 
        name="tipo_aeroplano", 
        value=tipo_aeroplano_df, 
        append = T, 
        row.names=F)



    # q 3 tratte:
    # select count(*) from tratte t1, tratte t2, tratte t3 where t1.aeroporto_arrivo = t2.aeroporto_partenza and t2.aeroporto_arrivo = t3.aeroporto_partenza and t1.orario_arrivo < t2.orario_partenza and t2.orario_arrivo<t3.orario_partenza





gettextf(paste0("%02d"),0:99)









# populate table aeroplano
    aeroplani<-tipo_aeroplano_df[sample(1:70,200,replace=T),];
    codici_aeroplani <- unlist(lapply(1:220,
	   function(x){
        paste0(sample(c(0:9,LETTERS),10,replace=T),collapse="")
    }))
    aeroplano_df<- data.frame(
        codice_aeroplano=sample(codici_aeroplani,200),
        posti_effettivi=round(aeroplani$numero_massimo_posti*sample(50:100,200,replace=T)/100),
        tipo_aereo=aeroplani$nome_tipo
    );

    dbWriteTable(con, 
        name="aeroplano", 
        value=aeroplano_df, 
        append = T, 
        row.names=F)



    
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
#         idvolo = sample(1:100000,100,replace=F),
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
