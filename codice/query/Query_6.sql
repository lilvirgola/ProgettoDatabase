-- query 6 : Trovare tutti i voli che sono effettuabili (per cui esiste una istanza per ogni tratta che ha posti disponibili)
SELECT DISTINCT id_volo, AP.citta AS citta_partenza, AA.citta AS citta_arrivo
FROM volo V
JOIN dispone_classe DC ON DC.volo=V.id_volo
JOIN Aeroporto AP ON AP.codice_aeroporto=V.aeroporto_partenza
JOIN Aeroporto AA ON AA.codice_aeroporto=V.aeroporto_arrivo
WHERE NOT EXISTS(
    SELECT *  -- trovo tratte non instanziate tra quelle con posti
    FROM Compone C
    WHERE C.id_volo=V.id_volo
        AND NOT EXISTS (
            SELECT *
            FROM Istanza_Tratta IT
            WHERE IT.id_tratta=C.id_tratta
                    AND IT.posti_rimanenti > 0
        )
);