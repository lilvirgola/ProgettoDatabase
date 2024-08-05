-- query 4 : Trovare una tra le compagnie aere che effettua più atterraggi a Seoul
CREATE OR REPLACE VIEW atterraggi_seoul AS
SELECT COUNT(*) AS num_atterraggi, ca.id_compagnia
FROM Compagnia_Aerea AS ca
JOIN Volo AS v ON ca.id_compagnia=v.id_compagnia
JOIN Compone AS c ON v.id_volo=c.id_volo
JOIN Tratta AS tr ON tr.id_tratta=c.id_tratta
JOIN Aeroporto AS ar ON ar.codice_aeroporto=tr.aeroporto_arrivo
WHERE ar.citta='Seoul'
GROUP BY ca.id_compagnia;

SELECT nome, num_atterraggi
FROM Compagnia_Aerea AS ca
JOIN atterraggi_seoul AS ats ON ca.id_compagnia=ats.id_compagnia
WHERE ats.num_atterraggi = (
    SELECT max(num_atterraggi)
    FROM atterraggi_seoul
);