-- query 6 : Elenco dei passeggeri su un volo specifico
SELECT P.nome, P.cognome, P.numero_documento_identita
FROM Passeggero P
JOIN Prenotazione PR ON P.id_passeggero = PR.passeggero
JOIN Comprende C ON PR.id_prenotazione = C.id_prenotazione
WHERE C.id_tratta = 123 AND C.data_volo = '2022-01-13';