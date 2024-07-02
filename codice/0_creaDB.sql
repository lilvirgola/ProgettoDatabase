CREATE TABLE Compagnia_Aerea(
        idCompagnia CHAR(3) PRIMARY KEY,
        nome VARCHAR (20) NOT NULL
);

CREATE TABLE Aeroporto(
    codice_aeroporto CHAR(3) PRIMARY KEY,
    citta VARCHAR(20),
    nome VARCHAR(40),
    nazione VARCHAR(20)
);

CREATE TABLE Volo(
    idVolo INTEGER PRIMARY KEY,
    orario_partenza TIME,
    orario_arrivo TIME,
    aeroporto_partenza CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto)
);

CREATE TABLE Classe(
    volo INTEGER REFERENCES Volo(idVolo),
    classe VARCHAR(10) NOT NULL,
    prezzo DECIMAL(2) NOT NULL,
    PRIMARY KEY (volo,prezzo)
);

CREATE TABLE Tipo_aeroplano(
    nome_tipo CHAR(20) PRIMARY KEY,
    autonomia_volo INTEGER,
    numero_massimo_posti INTEGER NOT NULL,
    nome_azienda_costruttrice VARCHAR(20) NOT NULL
);

    

CREATE TABLE Aeroplano(
    codice_aeroplano VARCHAR(10) PRIMARY KEY,
    posti_effettivi INTEGER NOT NULL,
    tipo_aereo CHAR(20)  REFERENCES Tipo_aeroplano(nome_tipo)
);


CREATE TABLE Tratta(
    idTratta INTEGER NOT NULL PRIMARY KEY,
    orario_partenza TIME,
    orario_arrivo TIME,
    aeroporto_decollo CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    aeroporto_arrivo CHAR(3) REFERENCES Aeroporto(codice_aeroporto)
);
    
CREATE TABLE Istanza_Tratta(
    idTratta INTEGER,
    data_volo DATE,
    posti_rimanenti INTEGER,
    aereo_usato VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano),
    PRIMARY KEY (idTratta,data_volo)
);

CREATE TABLE Passeggero(
    idPasseggero INTEGER PRIMARY KEY,
    nome VARCHAR(20),
    cognome VARCHAR(20),
    numero_documento_identita VARCHAR(15)
);

CREATE TABLE Prenotazione(
    idPrenotazione INTEGER PRIMARY KEY,
    passeggero INTEGER REFERENCES Passeggero(idPasseggero),
    cancellata BOOL
);

    
CREATE TABLE Numero_di_telefono(
    idPasseggero INTEGER REFERENCES Passeggero(idPasseggero),
    numero VARCHAR(15),
    PRIMARY KEY(idPasseggero, numero)
);

CREATE TABLE Riguarda(
    posto CHAR(4) NOT NULL,
    idTratta INTEGER REFERENCES Tratta(idTratta),
    idPrenotazione INTEGER REFERENCES Prenotazione(idPrenotazione),
    data_volo DATE NOT NULL,
    PRIMARY KEY (idTratta, idPrenotazione)
);

CREATE TABLE Compone(
    progressivoTratta INTEGER NOT NULL,
    idTratta INTEGER REFERENCES Tratta(idTratta),
    idVolo INTEGER REFERENCES Volo(idVolo),
    PRIMARY KEY (idTratta, idVolo)
);
    
CREATE TABLE Accetta(
    nome_tipo CHAR(20) REFERENCES Tipo_Aeroplano(nome_tipo),
    codice_aeroporto CHAR(3) REFERENCES Aeroporto(codice_aeroporto),
    PRIMARY KEY (nome_tipo, codice_aeroporto)
);

CREATE TABLE Possiede(
    codice_aeroplano VARCHAR(10) REFERENCES Aeroplano(codice_aeroplano),
    idCompagnia CHAR(5) REFERENCES Compagnia_Aerea(idCompagnia),
    PRIMARY KEY (codice_aeroplano, idCompagnia)
);
    
CREATE TABLE Giorni_della_settimana(
    giorno INTEGER,
    idVolo INTEGER REFERENCES Volo(idVolo),
    PRIMARY KEY (giorno, idVolo),
    CHECK (giorno BETWEEN 1 AND 7)
);