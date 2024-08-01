-- query 1 : trovare tutti gli aeroporti in cui è passato mario rossi con voli diretti a tokio

SELECT DISTINCT A.nome
FROM Passeggero P
JOIN Prenotazione pren ON P.id_passeggero=pren.passeggero 
JOIN Comprende C ON C.id_prenotazione=pren.id_passeggero
JOIN Tratta tr ON tr.id_prenotazione=pren.id_prenotazione
JOIN Aeroplano A ON (A.codice_aeroporto = tr.aeroporto_arrivo OR A-codice_aeroplano=tr.aeroporto_partenza)
JOIN Volo V ON V.id_volo=pren.riguarda_volo
JOIN Aeroporto Avolo ON V.aeroporto_arrivo = Avolo.codice_aeroporto
WHERE P.nome = "Mario" AND P.cognome = "Rossi"
    AND Avolo.citta="Tokio"

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

-- query 4 : Trovare una tra le compagnie aere che effettua più atterraggi a Sydney
CREATE OR REPLACE VIEW atterraggi_sydney AS
SELECT COUNT(*) AS num_atterraggi, ca.id_compagnia
FROM Compagnia_Aerea AS ca
JOIN Volo AS v ON ca.id_compagnia=v.id_compagnia
JOIN Compone AS c ON v.id_volo=c.id_volo
JOIN Tratta AS tr ON tr.id_tratta=c.id_tratta
JOIN Aeroporto AS ar ON ar.codice_aeroporto=tr.aeroporto_arrivo
WHERE ar.citta='Sydney'
GROUP BY ca.id_compagnia;

SELECT nome, num_atterraggi
FROM Compagnia_Aerea AS ca
JOIN atterraggi_sydney AS ats ON ca.id_compagnia=ats.id_compagnia
WHERE ats.num_atterraggi = (
    SELECT max(num_atterraggi)
    FROM atterraggi_sydney
);

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
