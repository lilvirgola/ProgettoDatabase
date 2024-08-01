-- query 2 : trovare l'aeroporto in cui si effettuano più decolli
CREATE OR REPLACE VIEW numero_decolli AS
SELECT COUNT(*) AS numero_voli,codice_aeroporto
FROM Aeroporto a 
JOIN Volo v ON v.aeroporto_partenza=a.codice_aeroporto
GROUP BY a.codice_aeroporto;

SELECT nome, citta, nazione, numero_voli
FROM numero_decolli nd 
JOIN Aeroporto A ON nd.codice_aeroporto=A.codice_aeroporto
WHERE numero_voli = (
    SELECT MAX(numero_voli)
    FROM numero_decolli
);