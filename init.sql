

-- Criação da tabela tb_apolices
CREATE TABLE IF NOT EXISTS tb_apolices (
  numero SERIAL PRIMARY KEY,
  data_emissao DATE NOT NULL,
  inicio_vigencia DATE NOT NULL,
  fim_vigencia DATE NOT NULL,
  importancia_segurada DECIMAL(15,2) NOT NULL,
  lmg DECIMAL(15,2) NOT NULL,
  status VARCHAR NOT NULL
);

-- Criação da tabela tb_endossos
CREATE TABLE IF NOT EXISTS tb_endossos (
  numero SERIAL PRIMARY KEY,
  tb_apolice_numero INTEGER NOT NULL REFERENCES tb_apolices(numero),
  tipo_endosso VARCHAR NOT NULL,
  data_emissao DATE NOT NULL,
  cancelado_endosso_numero INTEGER REFERENCES tb_endossos(numero),
  fim_vigencia DATE,
  importancia_segurada DECIMAL(15,2),
  created_at TIMESTAMP NOT NULL
);