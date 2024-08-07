-- query 7 : Prezzo del biglietto per un volo in una determinata classe
SELECT DC.prezzo
FROM Dispone_Classe DC
JOIN Volo V ON DC.volo = V.id_volo
WHERE V.id_volo = 456 AND DC.classe = 'economy';
