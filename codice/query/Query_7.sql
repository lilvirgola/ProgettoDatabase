-- query 7 : Selezionare una istanza per ogni tratta che è compresa da una prenotazione:
SELECT *
FROM Compone C 
JOIN Istanza_Tratta IT on IT.id_tratta=C.id_tratta
WHERE C.id_volo=989
    AND C.progressivo_tratta =2;


SELECT MAX(progressivo_tratta) AS n_tratte,id_prenotazione, id_volo
FROM Prenotazione Pr
JOIN Compone C on Pr.riguarda_volo=C.id_volo
GROUP BY id_prenotazione,id_volo;