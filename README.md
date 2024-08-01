## SCOPO DEL PROGETTO
La presente relazione si propone di analizzare e implementare un sistema di gestione dati. 
Si vuole partire da un tema scritto in linguaggio naturale e attraverso una analisi del testo definire dei requisiti opportuni,
per poi passare alla progettazione concettuale, logica e infine riuscire a creare un databse che soddisfi i requisiti definiti inizialmente e successi-
vamente popolarlo per poter analizzare dati presenti al suo interno con il linguaggio R
## COME UTILIZZARE IL CODICE
Il progetto usa un database Postgres in docker, si consiglia di fermare il servizio di postgrest se lo avete in locale o cambiare le porte nel compose file e in tutto il codice:
# Disattivare il server postgrest locale temporaneamente
per fermare il servizio basta usare il seguente comando:
`sudo systemctl stop postgresql.service`
e quando si ha finito per riattivarlo basta usare:
`sudo systemctl start postgresql.service`
# Creare il container
per creare il container basta avere installato docker nel sistema e nella folder principale usare:
`sudo docker compose up -d --build`
per fermarlo basterà usare:
`sudo docker compose down`
si noti che il database è salvato in un volume e quindi anche se si chiude il container i dati non si perdono
# Creare e popolare il database
per creare e popolare il databse basta andare nella folder codice in locale o connettendosi al container e eseguire lo script create_and_populateDB.sh:
`bash create_and_populateDB.sh`
si ricorda che la password per il databse è **S3cret**
# Eseguire le query 
per eseguire tutte le query basta eseguire lo script execute_querys.sh
`bash execute_querys.sh`
i risultati si troveranno nella folder query
# Stampare i grafici dell'analisi
per eseguire tutte le query basta eseguire lo script generate_graph.sh
`bash generate_graph.sh`
i risultati si troveranno nella folder analisi


