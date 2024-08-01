-- query 6 : Trovare tutti i voli che sono effettuabili (per cui esiste una istanza per ogni tratta che ha posti disponibili)
SELECT id_volo,classe 
FROM volo V
JOIN dispone_classe DC ON DC.volo=V.id_volo
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