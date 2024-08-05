-- PARTE 1: Creazione delle tabelle
CREATE TABLE Compagnia_Aerea(
    id_compagnia CHAR(3) PRIMARY KEY,
    nome VARCHAR (20) NOT NULL
);

CREATE TABLE Aeroporto(
    codice_aeroporto CHAR(3) PRIMARY KEY,
    citta VARCHAR(20),
    nome VARCHAR(40),
    nazione VARCHAR(20)
);

CREATE TABLE Volo(
    id_volo INTEGER PRIMARY KEY,
    orario_partenza TIME,
    orario_arrivo TIME,
    id_compagnia CHAR(3) REFERENCES Compagnia_Aerea(id_compagnia) ON DELETE CASCADE,
    aeroporto_partenza CHAR(3) REFERENCES Aeroporto(codice_aeroporto) ON DELETE CASCADE,
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto) ON DELETE CASCADE,
    CONSTRAINT orari_validi CHECK (orario_partenza < orario_arrivo )
);

Create table Classe(
    nome_classe VARCHAR(10) PRIMARY KEY    
);

CREATE TABLE Dispone_Classe(
    volo INTEGER REFERENCES Volo(id_volo) ON DELETE CASCADE,
    classe VARCHAR(10) REFERENCES Classe(nome_classe) ON DELETE CASCADE,
    prezzo DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (volo,classe)
);

CREATE TABLE Tipo_aeroplano(
    nome_tipo CHAR(40) PRIMARY KEY,
    autonomia_volo INTEGER,
    numero_massimo_posti INTEGER NOT NULL,
    nome_azienda_costruttrice VARCHAR(25) NOT NULL
);

CREATE TABLE Aeroplano(
    codice_aeroplano VARCHAR(10) PRIMARY KEY,
    posti_effettivi INTEGER NOT NULL,
    tipo_aereo CHAR(40)  REFERENCES Tipo_aeroplano(nome_tipo) ON DELETE CASCADE
);


CREATE TABLE Tratta(
    id_tratta INTEGER NOT NULL PRIMARY KEY,
    orario_partenza TIME,
    orario_arrivo TIME,
    aeroporto_partenza CHAR(3) REFERENCES Aeroporto(codice_aeroporto) ON DELETE CASCADE,
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto) ON DELETE CASCADE,
    CONSTRAINT orari_validi CHECK (orario_partenza < orario_arrivo )
);

CREATE TABLE Istanza_Tratta(
    id_tratta INTEGER REFERENCES Tratta(id_tratta),
    data_volo DATE,
    posti_rimanenti INTEGER,
    aereo_usato VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano) ON DELETE CASCADE,
    PRIMARY KEY (id_tratta,data_volo)
);

CREATE TABLE Compone(
    progressivo_tratta INTEGER NOT NULL,
    id_tratta INTEGER REFERENCES Tratta(id_tratta) ON DELETE CASCADE,
    id_volo INTEGER REFERENCES Volo(id_volo) ON DELETE CASCADE,
    PRIMARY KEY (id_tratta, id_volo)
);

CREATE TABLE Passeggero(
    id_passeggero INTEGER PRIMARY KEY,
    nome VARCHAR(20),
    cognome VARCHAR(20),
    numero_documento_identita VARCHAR(15)
);

CREATE TABLE Prenotazione(   
    id_prenotazione INTEGER PRIMARY KEY,
    passeggero INTEGER REFERENCES Passeggero(id_passeggero) ON DELETE CASCADE,
    cancellata BOOL,
    riguarda_volo INTEGER REFERENCES Volo(id_volo) ON DELETE CASCADE,
    sceglie_classe VARCHAR(10) REFERENCES Classe(nome_classe) ON DELETE CASCADE
);

    
CREATE TABLE Numero_di_telefono(
    id_passeggero INTEGER REFERENCES Passeggero(id_passeggero) ON DELETE CASCADE,
    numero VARCHAR(15),
    PRIMARY KEY(id_passeggero, numero)
);

CREATE TABLE Comprende( 
    posto CHAR(4) NOT NULL,
    id_tratta INTEGER ,
    data_volo DATE NOT NULL,
    id_prenotazione INTEGER REFERENCES Prenotazione(id_prenotazione) ON DELETE CASCADE,
    PRIMARY KEY (id_tratta, id_prenotazione, data_volo),
    FOREIGN KEY (id_tratta, data_volo) REFERENCES Istanza_Tratta(id_tratta, data_volo) ON DELETE CASCADE
);
    
CREATE TABLE Accetta(
    nome_tipo CHAR(40) REFERENCES Tipo_Aeroplano(nome_tipo) ON DELETE CASCADE,
    codice_aeroporto CHAR(3) REFERENCES Aeroporto(codice_aeroporto) ON DELETE CASCADE,
    PRIMARY KEY (nome_tipo, codice_aeroporto)
);

CREATE TABLE Possiede(  
    codice_aeroplano VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano) ON DELETE CASCADE,
    id_compagnia CHAR(5) REFERENCES Compagnia_Aerea(id_compagnia)  ON DELETE CASCADE,
    PRIMARY KEY (codice_aeroplano, id_compagnia)
);
    
CREATE TABLE Giorni_della_settimana(  
    giorno INTEGER,
    id_volo INTEGER REFERENCES Volo(id_volo) ON DELETE CASCADE,
    PRIMARY KEY (giorno, id_volo),
    CHECK (giorno BETWEEN 1 AND 7)
);

-- PARTE 2: Creazione degli indici

-- Indici sulle foreign key (la documentazione di postgres suggerisce di crearli)
CREATE INDEX Volo_id_compagnia_aerea_idx ON Volo(id_compagnia);
CREATE INDEX Volo_aeroporto_partenza_idx ON Volo(aeroporto_partenza);
CREATE INDEX Volo_aeroporto_arrivo_idx ON Volo(aeroporto_arrivo);
CREATE INDEX dispone_classe_classe_idx ON dispone_classe(classe); 
CREATE INDEX Aeroplano_tipo_aeroplano_idx ON Aeroplano(tipo_aereo);
CREATE INDEX Tratta_aeroporto_partenza_idx ON Tratta(aeroporto_partenza);
CREATE INDEX Tratta_aeroporto_arrivo_idx ON Tratta(aeroporto_arrivo);
CREATE INDEX Istanza_Tratta_aereo_usato_idx ON Istanza_Tratta(aereo_usato);
CREATE INDEX Prenotazione_passeggero_idx ON Prenotazione(passeggero);
CREATE INDEX Prenotazione_volo_idx ON Prenotazione(riguarda_volo);
CREATE INDEX Prenotazione_classe_idx ON Prenotazione(sceglie_classe);
CREATE INDEX Comprende_prenotazione_idx ON Comprende(id_prenotazione);

-- Indici sclti per migliorare le performance delle query

CREATE INDEX Volo_orario_partenza_idx ON Volo(orario_partenza);
CREATE INDEX Volo_orario_arrivo_idx ON Volo(orario_arrivo);
CREATE INDEX Passeggero_nome_idx ON Passeggero(nome);
CREATE INDEX Passeggero_cognome_idx ON Passeggero(cognome);


-- PARTE 3: Creazione dei trigger

CREATE OR REPLACE FUNCTION controllo_successione()
    RETURNS Trigger LANGUAGE plpgsql as 
    $$
    DECLARE
        collegamento RECORD;
    BEGIN
        FOR collegamento IN
            SELECT t1.orario_arrivo orario_arrivo, t1.aeroporto_arrivo aeroporto_arrivo, t2.orario_partenza orario_partenza, t2.aeroporto_partenza aeroporto_partenza
            FROM COMPONE c1
            JOIN Compone c2 ON c1.id_volo=c2.id_volo
            JOIN Tratta t1 ON c1.id_tratta=t1.id_tratta
            JOIN Tratta t2 ON c2.id_tratta=t2.id_tratta
            WHERE c1.id_volo=c2.id_volo 
            AND c1.progressivo_tratta +1 = c2.progressivo_tratta
            AND c1.id_volo = new.id_volo
        LOOP
            IF collegamento.aeroporto_arrivo != collegamento.aeroporto_partenza THEN
                RAISE NOTICE 'Aeroporti non uguali nel cambio %s ', new;
                RETURN NULL; 
            END IF;

            IF collegamento.orario_arrivo > collegamento.orario_partenza THEN
                RAISE NOTICE 'Orari non compatibili per stesso volo';
                RETURN NULL;
            END IF;
        END LOOP;
        RETURN new;
    END
$$ ;

CREATE TRIGGER controllo_successione_trigger
BEFORE INSERT OR UPDATE ON Compone
FOR EACH row
EXECUTE PROCEDURE controllo_successione();

CREATE OR REPLACE FUNCTION controllo_voli_inizio()
    RETURNS Trigger LANGUAGE plpgsql AS 
    $$
    DECLARE
        partenza RECORD;
        arrivo RECORD;
    BEGIN
        SELECT T.orario_partenza orario, T.aeroporto_partenza aeroporto INTO partenza
            FROM TRATTA T
            JOIN Compone C ON C.id_tratta=T.id_tratta
            WHERE C.progressivo_tratta = 1
                AND  C.id_volo=new.id_volo;

        IF partenza.orario != new.orario_partenza THEN
            RAISE NOTICE 'Orario non corrispondente';
            RETURN NULL; 
        END IF;

        IF partenza.aeroporto != new.aeroporto_partenza THEN
            RAISE NOTICE 'Aeroporto non corrispondente';
            RETURN NULL; 
        END IF;


        SELECT T.orario_arrivo orario, T.aeroporto_arrivo aeroporto INTO arrivo
            FROM Tratta T
            JOIN Compone C ON C.id_tratta=T.id_tratta
            WHERE C.progressivo_tratta = 
                (SELECT MAX(progressivo_tratta)
                    FROM Compone C1 
                    WHERE C1.id_volo=new.id_volo)
                AND  C.id_volo=new.id_volo;

        IF arrivo.orario != new.orario_arrivo THEN
            RAISE NOTICE 'Orario non corrispondente';
            RETURN NULL; 
        END IF;

        IF arrivo.aeroporto != new.aeroporto_arrivo THEN
            RAISE NOTICE 'Aeroporto non corrispondente';
            RETURN NULL; 
        END IF;
        RETURN new;
    END
$$ ;

CREATE TRIGGER controllo_voli_inizio_trigger
BEFORE INSERT OR UPDATE ON Volo
FOR EACH row
EXECUTE PROCEDURE controllo_voli_inizio();

CREATE OR REPLACE FUNCTION controllo_numero_posti()
    RETURNS Trigger LANGUAGE plpgsql AS 
    $$
    DECLARE
        posti_disponibili INTEGER;
        posti_assegnati INTEGER;
    BEGIN
        SELECT posti_rimanenti INTO posti_disponibili
        FROM Istanza_Tratta IT
        WHERE IT.id_tratta = new.id_tratta
            AND IT.data_volo = new.data_volo;

        IF posti_disponibili = 0 THEN
            RAISE NOTICE 'Posti assegnati finiti';
            RETURN NULL; 
        END IF;

        UPDATE Istanza_Tratta IT
            SET posti_rimanenti = posti_disponibili -1
            WHERE it.id_tratta = new.id_tratta
                AND it.data_volo = new.data_volo;
        RETURN new;
    END
$$ ;

CREATE TRIGGER controllo_numero_posti_trigger
BEFORE INSERT OR UPDATE ON Comprende
FOR EACH ROW
EXECUTE PROCEDURE controllo_numero_posti();