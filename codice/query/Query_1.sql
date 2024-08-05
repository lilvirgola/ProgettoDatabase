-- query 1 : trovare tutti gli aeroporti in cui è passato mario rossi con voli diretti a tokio

SELECT DISTINCT A.nome
FROM Passeggero P
JOIN Prenotazione pren ON P.id_passeggero=pren.passeggero 
JOIN Comprende C ON C.id_prenotazione=pren.id_prenotazione
JOIN Istanza_Tratta IT ON IT.id_tratta=C.id_tratta
JOIN Tratta TR ON TR.id_tratta=it.id_tratta
JOIN Aeroporto A ON (A.codice_aeroporto = TR.aeroporto_arrivo OR A.codice_aeroporto=TR.aeroporto_partenza)
JOIN Volo V ON V.id_volo=pren.riguarda_volo
JOIN Aeroporto Avolo ON V.aeroporto_arrivo = Avolo.codice_aeroporto
WHERE P.nome = 'Mario' AND P.cognome = 'Rossi'
    AND Avolo.citta='Tokio'