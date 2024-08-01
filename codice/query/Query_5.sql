-- query 5 : Trovare la tratta in cui ci sono stati più passeggeri in business class.
CREATE OR REPLACE VIEW passeggeri_business AS
SELECT COUNT(*) AS num_passeggeri, tr.id_tratta
FROM Tratta AS tr
JOIN Istanza_Tratta AS istr ON tr.id_tratta=istr.id_tratta
JOIN Comprende AS comp ON comp.id_tratta=istr.id_tratta
JOIN Prenotazione AS pren ON pren.id_prenotazione=comp.id_prenotazione
JOIN Classe AS cls ON cls.nome_classe=pren.sceglie_classe
WHERE cls.nome_classe='business'
GROUP BY tr.id_tratta;

SELECT pr.citta AS citta_partenza, ar.citta AS citta_arrivo, num_passeggeri
FROM Tratta AS tr
JOIN passeggeri_business AS pb ON tr.id_tratta=pb.id_tratta
JOIN Aeroporto AS pr ON pr.codice_aeroporto = tr.aeroporto_partenza
JOIN Aeroporto AS ar ON ar.codice_aeroporto = tr.aeroporto_arrivo
where num_passeggeri = (
    SELECT MAX(num_passeggeri)
    FROM passeggeri_business
);