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
    aeroporto_partenza CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto)
);


Create table Classe(
    nome_classe VARCHAR(10) PRIMARY KEY    
);

CREATE TABLE Dispone_Classe(
    volo INTEGER REFERENCES Volo(id_volo),
    classe VARCHAR(10) REFERENCES Classe(nome_classe),
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
    tipo_aereo CHAR(40)  REFERENCES Tipo_aeroplano(nome_tipo)
);


CREATE TABLE Tratta(
    id_tratta INTEGER NOT NULL PRIMARY KEY,
    orario_partenza TIME,
    orario_arrivo TIME,
    aeroporto_partenza CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    CONSTRAINT orari_validi CHECK (orario_partenza < orario_arrivo )
);

CREATE TABLE Istanza_Tratta(
    id_tratta INTEGER,
    data_volo DATE,
    posti_rimanenti INTEGER,
    aereo_usato VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano),
    PRIMARY KEY (id_tratta,data_volo)
);

CREATE TABLE Compone(
    progressivo_tratta INTEGER NOT NULL,
    id_tratta INTEGER REFERENCES Tratta(id_tratta),
    id_volo INTEGER REFERENCES Volo(id_volo),
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
    passeggero INTEGER REFERENCES Passeggero(id_passeggero),
    cancellata BOOL
);

    
CREATE TABLE Numero_di_telefono(
    id_passeggero INTEGER REFERENCES Passeggero(id_passeggero),
    numero VARCHAR(15),
    PRIMARY KEY(id_passeggero, numero)
);

CREATE TABLE Riguarda(
    posto CHAR(4) NOT NULL,
    id_tratta INTEGER REFERENCES Tratta(id_tratta),
    id_prenotazione INTEGER REFERENCES Prenotazione(id_prenotazione),
    data_volo DATE NOT NULL,
    PRIMARY KEY (id_tratta, id_prenotazione)
);


    
CREATE TABLE Accetta(
    nome_tipo CHAR(20) REFERENCES Tipo_Aeroplano(nome_tipo),
    codice_aeroporto CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    PRIMARY KEY (nome_tipo, codice_aeroporto)
);

CREATE TABLE Possiede(
    codice_aeroplano VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano),
    id_compagnia CHAR(5) REFERENCES Compagnia_Aerea(id_compagnia),
    PRIMARY KEY (codice_aeroplano, id_compagnia)
);
    
CREATE TABLE Giorni_della_settimana(
    giorno INTEGER,
    id_volo INTEGER REFERENCES Volo(id_volo),
    PRIMARY KEY (giorno, id_volo),
    CHECK (giorno BETWEEN 1 AND 7)
);


create or replace function controllo_successione()
    returns Trigger language plpgsql as 
    $$
    DECLARE
        collegamento RECORD;
    BEGIN
        FOR collegamento IN
            select t1.orario_arrivo orario_arrivo, t1.aeroporto_arrivo aeroporto_arrivo, t2.orario_partenza orario_partenza, t2.aeroporto_partenza aeroporto_partenza
            FROM COMPONE c1
            JOIN Compone c2 On c1.id_volo=c2.id_volo
            JOIN Tratta t1 on c1.id_tratta=t1.id_tratta
            JOIN Tratta t2 on c2.id_tratta=t2.id_tratta
            where c1.id_volo=c2.id_volo 
            and c1.progressivo_tratta = c2.progressivo_tratta+1
            and c1.id_volo = new.id_volo

        LOOP
            IF collegamento.aeroporto_arrivo != collegamento.aeroporto_partenza THEN
                RAISE NOTICE 'Aeroporti non uguali nel cambio';
                RETURN NULL; 
            END IF;

            IF collegamento.orario_arrivo > collegamento.orario_partenza THEN
                RAISE NOTICE 'Orari non compatibili per stesso volo';
                RETURN NULL;
            END IF;
        END LOOP;
        return new;
    END
$$ ;


create trigger controllo_successione_trigger
before insert or update on Compone
for each row
execute procedure controllo_successione();

create or replace function controllo_voli_inizio()
    returns Trigger language plpgsql as 
    $$
    DECLARE
        partenza RECORD;
    BEGIN
        SELECT T.orario_partenza orario, T.aeroporto_partenza aeroporto INTO partenza
            from TRATTA T
            JOIN Compone C on C.id_tratta=T.id_tratta
            where C.progressivo_tratta = 1
                and  C.id_volo=new.id_volo;

        IF partenza.orario != new.orario_partenza THEN
            RAISE NOTICE 'Orario non corrispondente';
            RETURN NULL; 
        END IF;

        IF partenza.aeroporto != new.aeroporto_partenza THEN
            RAISE NOTICE 'Aeroporto non corrispondente';
            RETURN NULL; 
        END IF;
        RETURN new;
    END
$$ ;


create trigger controllo_voli_inizio_trigger
before insert or update on Volo
for each row
execute procedure controllo_voli_inizio();



create or replace function controllo_numero_posti()
    returns Trigger language plpgsql as 
    $$
    DECLARE
        posti_disponibili INTEGER;
        posti_assegnati INTEGER;
    BEGIN
        SELECT posti_rimanenti into posti_disponibili
        FROM Istanza_Tratta it
        WHERE it.id_tratta = new.id_tratta
            AND it.data_volo = new.data_volo;

        IF posti_disponibili == 0 THEN
            RAISE NOTICE 'Posti assegnati finiti';
            RETURN NULL; 
        END IF;

        UPDATE Istanza_Tratta
            SET posti_rimanenti = posti_disponibili -1
            where it.id_tratta = new.id_tratta
                AND it.data_volo = new.data_volo;
        RETURN new;
    END
$$ ;



create trigger controllo_numero_posti_trigger
before insert or update on Riguarda
for each row
execute procedure controllo_numero_posti();