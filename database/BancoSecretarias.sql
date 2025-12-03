CREATE TABLE secretaria (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL UNIQUE,
    sigla VARCHAR(10) NOT NULL UNIQUE,
    ativa BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    cargo VARCHAR(80),
    id_secretaria INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_usuario_secretaria
        FOREIGN KEY (id_secretaria) REFERENCES secretaria(id)
        ON UPDATE CASCADE
);

CREATE INDEX idx_usuario_secretaria ON usuario(id_secretaria);

CREATE TABLE comunicado (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    conteudo TEXT NOT NULL,
    id_remetente INT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),
    nivel_importancia SMALLINT NOT NULL DEFAULT 1,  -- 1=Normal, 2=Importante, 3=Urgente

    CONSTRAINT fk_comunicado_remetente 
        FOREIGN KEY (id_remetente) REFERENCES usuario(id)
        ON UPDATE CASCADE
);

CREATE TABLE comunicado_destinatario (
    id SERIAL PRIMARY KEY,
    id_comunicado INT NOT NULL,
    id_secretaria INT NOT NULL,

    CONSTRAINT fk_cd_comunicado 
        FOREIGN KEY (id_comunicado) REFERENCES comunicado(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cd_secretaria
        FOREIGN KEY (id_secretaria) REFERENCES secretaria(id)
        ON UPDATE CASCADE
);

CREATE INDEX idx_comunicado_data ON comunicado(criado_em);
CREATE INDEX idx_comunicado_dest ON comunicado_destinatario(id_secretaria);

CREATE TABLE decisao (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    id_responsavel INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA', 
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_decisao_responsavel 
        FOREIGN KEY (id_responsavel) REFERENCES usuario(id)
        ON UPDATE CASCADE
);

CREATE TABLE decisao_historico (
    id SERIAL PRIMARY KEY,
    id_decisao INT NOT NULL,
    id_usuario INT NOT NULL,
    comentario TEXT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_hist_decisao 
        FOREIGN KEY (id_decisao) REFERENCES decisao(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_hist_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

CREATE INDEX idx_decisao_status ON decisao(status);
CREATE INDEX idx_hist_decisao ON decisao_historico(id_decisao);

CREATE TABLE fluxo_comunicacao (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(180) NOT NULL,
    descricao TEXT,
    id_criador INT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_fluxo_criador
        FOREIGN KEY (id_criador) REFERENCES usuario(id)
);

CREATE TABLE fluxo_participante (
    id SERIAL PRIMARY KEY,
    id_fluxo INT NOT NULL,
    id_secretaria INT NOT NULL,

    CONSTRAINT fk_fluxo_participante_fluxo
        FOREIGN KEY (id_fluxo) REFERENCES fluxo_comunicacao(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fluxo_participante_secretaria
        FOREIGN KEY (id_secretaria) REFERENCES secretaria(id)
);

CREATE TABLE fluxo_mensagem (
    id SERIAL PRIMARY KEY,
    id_fluxo INT NOT NULL,
    id_usuario INT NOT NULL,
    mensagem TEXT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_fluxo_msg_fluxo
        FOREIGN KEY (id_fluxo) REFERENCES fluxo_comunicacao(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fluxo_msg_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

CREATE INDEX idx_fluxo_msg_fluxo ON fluxo_mensagem(id_fluxo);

CREATE TABLE log_visualizacao (
    id SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    recurso VARCHAR(30) NOT NULL,   -- 'COMUNICADO', 'DECISAO', 'FLUXO'
    id_recurso INT NOT NULL,
    data TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_log_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

CREATE INDEX idx_log_recurso ON log_visualizacao(recurso, id_recurso);
