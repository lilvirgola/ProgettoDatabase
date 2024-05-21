#
# Run this script with "source("script.R")"
#

# create connection
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="gestionevoli")

#define function to generate a alphanumeric string range
stringrange = function(x,y){
    full =unlist(lapply(LETTERS[which(LETTERS==substr(x,1,1)):which(LETTERS==substr(y,1,1))],
            function(x){paste0(x,gettextf(paste0("%02d"),0:99))}))
    full[which(full==x):which(full==y)]
    }

# set schema to "passeggero"
dbGetQuery(con, "SET search_path TO public;")

# populate table "passeggero"
v_nomi <- readLines("nomi.txt")
v_cognomi <- readLines("cognomi.txt")
passeggero_df <- data.frame(idPasseggero = sample(1:1000000, 10000, replace=F),
                          nome=sample(v_nomi, 10000, replace = T),
                          cognome=sample(v_cognomi, 10000, replace = T),
                          numero_documento_identita=sample(, 10000, replace=T))
dbWriteTable(con, 
             name="passeggero", 
             value=passeggero_df, 
             append = T, 
             row.names=F)

# populate table "iscritto_a"
# cdl
temp_cdl <- dbGetQuery(con, "SELECT nome FROM corsi_di_laurea;")
temp_cdl <- temp_cdl$nome
iscritto_a.cdl <- sample(temp_cdl, 10000, replace=T)
# matricola
temp_matricola <- dbGetQuery(con, "SELECT matricola FROM studenti")
iscritto_a.stud <- temp_matricola$matricola
# anno
iscritto_a.anno <- sample(1978:2023, 10000, replace=T)
iscritto_a_df <- data.frame(cdl=iscritto_a.cdl,
                            stud=iscritto_a.stud,
                            anno=iscritto_a.anno)
dbWriteTable(con, name="iscritto_a",
                 value=iscritto_a_df, row.names=F, append = T)

# populate "iscritto_a" with the 1% of previous students, so that 1% of
# the students is enrolled to 2 courses
# cdl
temp_cdl <- dbGetQuery(con, "SELECT nome FROM corsi_di_laurea")
temp_cdl <- temp_cdl$nome
iscritto_a.cdl <- sample(temp_cdl, 100, replace=T)
# matricola
temp_matricola <- dbGetQuery(con, "SELECT matricola FROM studenti")
temp_matricola <- temp_matricola$matricola
iscritto_a.stud <- sample(temp_matricola, 100, replace=F)
# anno
iscritto_a.anno <- sample(1978:2023, 100, replace=T)
iscritto_a_df <- data.frame(cdl=iscritto_a.cdl,
                            stud=iscritto_a.stud,
                            anno=iscritto_a.anno)
# remove the tuples (cdl,stud,anno) in "iscritto_a_df" that are already in
# table "iscritto_a"
x <- dbGetQuery(con,
                 "SELECT cdl,stud,anno
                 FROM iscritto_a")
iscritto_a_df <- data.frame(setdiff(iscritto_a_df,x))
# write table
dbWriteTable(con, name="iscritto_a", value=iscritto_a_df,
             append=T, row.names=F)

# plot: "numero iscritti per anno"
df <- dbGetQuery(con,
                 "SELECT anno, count(*)
                 FROM iscritto_a
                 GROUP BY anno
                 ORDER BY anno")
plot(df$anno, df$count, "o")

# plot: "numero iscritti per anno (1993,1997,1999) e corso di laurea"
x11()
df <- dbGetQuery(con,
                 "SELECT anno, cdl, count(*)
                 FROM iscritto_a
                 WHERE anno='1993' OR anno='1997' or anno='1999'
                 GROUP BY anno, cdl
                 ORDER BY anno, cdl")
matr <- matrix(df$count, nrow = length(unique(df$cdl)))
rownames(matr) <- unique(df$cdl)
matr <- t(matr)
barplot(matr, beside = TRUE)

# grafico a barre degli studenti divisi per sesso e corsi di laurea
df <- dbGetQuery(con,
                 "SELECT cdl, sesso, count(*)
                 FROM studenti JOIN iscritto_a ON matricola = stud
                 GROUP BY cdl, sesso
                 ORDER BY cdl, sesso")
matr <- matrix(df$count, nrow = 2)
rownames(matr) <- c("f","m")
colnames(matr) <- unique(df$cdl)
x11()
barplot(matr)
x11()
barplot(matr, beside=T)
