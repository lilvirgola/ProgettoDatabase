#
# Run this script with "source("script.R")"
#

# create connection
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli", user="postgres", password="S3cret")
set.seed(100)
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

    aeroporto_df <- data.frame(
        codice_aeroporto = sample(v_code,100,replace=F),
        citta = sample(v_citta,100),
        nome = sample(v_nomi_aeroporti,100),
        nazione = sample(v_nazioni,100)
    )

    dbWriteTable(con, 
                name="aeroporto", 
                value=aeroporto_df, 
                append = T, 
                row.names=F)

# populate table Compagnia Aerea
    v_nome <- readLines("dati/compagnie_nomi.txt")
    Compagnia_Aerea_df <- data.frame(
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

    dbWriteTable(con, 
        name="tratta", 
        value=tratte_df, 
        append = T, 
        row.names=F)


    compone_df <- data.frame()
    voli_df <- data.frame()

    for (id_volo in 1:1000) {
        n_tratte=sample(1:6,1)

        t0 <- tratte_df[sample(nrow(tratte_df),1),]
        tc <- t0

        compone_df<- rbind(compone_df,data.frame(
            progressivo_tratta=1,
            id_tratta=t0$id_tratta,
            id_volo=id_volo
        ))

        for(progressivo_tratta in 2:n_tratte){
            poss <- subset(tratte_df,(aeroporto_partenza==tc$aeroporto_arrivo) & (orario_partenza>tc$orario_arrivo))
            
            if(length(poss[,1])==0){
                break;
            }
            if(length(poss[,1])==1){
                tc<- poss[1,]
            }else{
                tc<- poss[sample(nrow(poss),1),]
            }
            compone_df<- rbind(compone_df,data.frame(
                progressivo_tratta=progressivo_tratta,
                id_tratta=tc$id_tratta,
                id_volo=id_volo
            ))
        }
    
        voli_df <- rbind(voli_df,data.frame(
                id_volo=id_volo,
                orario_partenza= t0$orario_partenza,
                orario_arrivo= tc$orario_arrivo,
                id_compagnia=sample(Compagnia_Aerea_df$id_compagnia,1,replace=F),
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

    classe_df <- data.frame(
        nome_classe = classi
    )

    dbWriteTable(con, 
        name="classe", 
        value=classe_df, 
        append = T, 
        row.names=F)
    

    unique_classe_df<-volo_classe_df[!duplicated(volo_classe_df),]
    dispone_classe_df <- data.frame(
        volo = unique_classe_df$volo,
        classe = unique_classe_df$classe,
        prezzo=sample(1:10000,nrow(unique_classe_df))/100
    )



    dbWriteTable(con, 
        name="dispone_classe", 
        value=dispone_classe_df, 
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

# populate table Passeggero
    v_nomi <- readLines("dati/nomi.txt")
    v_cognomi <- readLines("dati/cognomi.txt")
    codici_documenti <- unlist(lapply(1:1550,
	   function(x){
        paste0(sample(c(0:9,LETTERS),15,replace=T),collapse="")
    }))
    id_passeggeri <- 1:1500
   
    passeggero_df <- data.frame(
        id_passeggero=id_passeggeri,
        nome = sample(v_nomi,1500),
        cognome= sample(v_nomi,1500,replace=T),
        numero_documento_identita=sample(codici_documenti, 1500)
    )

    dbWriteTable(con, 
        name="passeggero", 
        value=passeggero_df, 
        append = T, 
        row.names=F)



 # populate table numero_telefono
    id_passeggeri_numeri <- c(id_passeggeri,sample(id_passeggeri,400,replace=T))
    numeri <- sample(10^10, length(id_passeggeri_numeri))
    numeri_telefono_df <- data.frame(
        id_passeggero = id_passeggeri_numeri,
        numero = numeri
    )

    dbWriteTable(con, 
        name="numero_di_telefono", 
        value=numeri_telefono_df, 
        append = T, 
        row.names=F)

# populate table istanza_tratta
    aeroplani_disponibili <- dbGetQuery(con,"SELECT codice_aeroplano,posti_effettivi 
                                            FROM aeroplano")
    aeroplani_usati <- aeroplani_disponibili[sample(nrow(aeroplani_disponibili),8000,replace=T),]

    tratte_date_poss <- (365*4)*1000
    id_instanziati <- sample(tratte_date_poss,8000)
    id_tratte_instanziati <- (id_instanziati %% 1000)+1
    gionri_tratte_instanziate <- ceiling(id_instanziati /1000)

    istanza_tratta_df <- data.frame(
        id_tratta = id_tratte_instanziati,
        data_volo = format(ISOdate(2020,01,01)+gionri_tratte_instanziate * 24*3600,"%D"),
        posti_rimanenti = aeroplani_usati$posti_effettivi ,
        aereo_usato = aeroplani_usati$codice_aeroplano
    )

    dbWriteTable(con, 
        name="istanza_tratta",
        value=istanza_tratta_df, 
        append = T, 
        row.names=F)


# populate prenotazione
    id_prenotazioni  <- 1:500
    prenotazione_volo <- dbGetQuery(con,"SELECT id_volo,classe 
                                        FROM volo V
                                        JOIN dispone_classe DC ON DC.volo=V.id_volo
                                        WHERE NOT EXISTS(
                                            SELECT *  -- trovo tratte non instanziate
                                            FROM Compone C
                                            WHERE C.id_volo=V.id_volo
                                                AND NOT EXISTS (
                                                    SELECT *
                                                    FROM Istanza_Tratta IT
                                                    WHERE IT.id_tratta=C.id_tratta
                                                )
                                        )")

    voli_prenotati <- prenotazione_volo[sample(nrow(prenotazione_volo), 500,replace=T),]

    passeggero_prenotazione <- sample (id_passeggeri,500, replace=T)

    prenotazione_cancellata <- sample(10,500,replace=T)==1
    prenotazione_df <- data.frame(
        id_prenotazione=id_prenotazioni,
        passeggero = passeggero_prenotazione,
        cancellata = prenotazione_cancellata,
        riguarda_volo = voli_prenotati$id_volo,
        sceglie_classe = voli_prenotati$classe
    )

    dbWriteTable(con, 
        name="prenotazione",
        value=prenotazione_df, 
        append = T, 
    row.names=F)


# populate Comprende

    voli_prenotati <- dbGetQuery(con,"SELECT MAX(progressivo_tratta) AS n_tratte,id_prenotazione, id_volo
                                    FROM Prenotazione Pr
                                    JOIN Compone C on Pr.riguarda_volo=C.id_volo
                                    GROUP BY id_prenotazione,id_volo")
    comprende_df <- data.frame()

    for (id_prenotato in 1:nrow(voli_prenotati)) {
        volo <- voli_prenotati[id_prenotato,]
        for(prog in 1:volo$n_tratte){
            possibili_tratte <- dbGetQuery(con,
                            gettextf("
                            SELECT *
                            FROM Compone C 
                            JOIN Istanza_Tratta IT on IT.id_tratta=C.id_tratta
                            WHERE C.id_volo=%d
                            AND C.progressivo_tratta =%d",volo$id_volo,prog))
            tratta_usata <- possibili_tratte[sample(nrow(possibili_tratte),1),]
            comprende_df  <- rbind(comprende_df,data.frame(
                id_tratta =tratta_usata$id_tratta,
                data_volo = tratta_usata$data_volo,
                id_prenotazione =id_prenotato,
                posto = sample(1:9999,1)
            ))
    # se due viaggiano nello stesso posto è possibile, si chiama overbooking           
        }
    }
    
     dbWriteTable(con, 
        name="comprende",
        value=comprende_df, 
        append = T, 
        row.names=F)


# populate table Accetta
    combinazioni_scelte <-sample(nrow(tipo_aeroplano_df)*nrow(aeroporto_df),4000)
    accetta_df <- data.frame(
        nome_tipo = tipo_aeroplano_df$nome_tipo[((combinazioni_scelte-1) %% nrow(tipo_aeroplano_df))+1],
        codice_aeroporto = aeroporto_df$codice_aeroporto[ceiling(combinazioni_scelte /nrow(tipo_aeroplano_df))]
    )
    
    
    dbWriteTable(con, 
        name="accetta",
        value=accetta_df, 
        append = T, 
        row.names=F)



# populate table possiede
    combinazioni_scelte <-sample(nrow(aeroplano_df)*nrow(Compagnia_Aerea_df),4000)
    possiede_df <- data.frame(
        codice_aeroplano = aeroplano_df$codice_aeroplano[(combinazioni_scelte-1) %% nrow(aeroplano_df)+1],
        id_compagnia = Compagnia_Aerea_df$id_compagnia[ceiling(combinazioni_scelte /nrow(aeroplano_df))]
    )
    
    
    dbWriteTable(con, 
        name="possiede",
        value=possiede_df, 
        append = T, 
        row.names=F)


#populate table Giorni_della_settimana
    giorni_della_settimana_df <- data.frame(giorno=list(),id_volo=list())
    id_voli <- dbGetQuery(con,"SELECT id_volo FROM volo")$id_volo
    for(id_volo in id_voli){
        n_giorni <- sample(7,1)
        giorni_della_settimana_df <- rbind(giorni_della_settimana_df, data.frame(
            id_volo = rep(id_volo,n_giorni),
            giorno = sample(1:7,n_giorni)
        ))
    }

    dbWriteTable(con, 
        name="giorni_della_settimana",
        value=giorni_della_settimana_df, 
        append = T,
        row.names=F)