-- query 3 : Trovare il tipo di aereo più utilizzato (tempo totale in volo)

CREATE OR REPLACE VIEW ore_volo AS
SELECT sum(orario_arrivo-orario_partenza) as ore, aereo_usato
FROM Istanza_Tratta IT
JOIN Tratta T on IT.id_tratta=T.id_tratta
GROUP BY aereo_usato;


SELECT aereo_usato, ore
FROM ore_volo
WHERE ore=(
    SELECT DISTINCT MAX(ore)
    FROM ore_volo
);