# Segarante Apólices & Endossos API

> Desafio Técnico 3 – Implementação de API Ruby on Rails para gestão de **Apólices** e **Endossos**.

## Sumário
1. Visão Geral
2. Arquitetura & Camadas
3. Modelagem de Dados
4. Regras de Negócio Implementadas
5. Tipos de Endosso
6. Endpoints da API
7. Exemplos de Requisições (curl / Postman)
8. Fluxos Principais
9. Cancelamento de Endosso – Regras
10. Execução com Docker / Docker Compose
11. Execução Local (sem Docker)
12. Testes Automatizados (RSpec)
13. Limitações & Próximos Passos
14. Coleção Postman

---
## 1. Visão Geral
Esta API gerencia Apólices de Seguro e seus Endossos. Cada apólice possui um histórico imutável de endossos que impactam:
- Limite Máximo de Garantia (LMG)
- Fim da Vigência
- Status da apólice

O desafio exige criação e consulta (somente métodos `POST` e `GET`). Não há edição ou exclusão.

---
## 2. Arquitetura & Camadas
A aplicação segue uma separação simples de responsabilidades:
- Controller (`ApolicesController`): Orquestra requisições HTTP e parâmetros fortes (Strong Params).
- Service (`ApoliceService`, `EndossoService`): Constrói Objetos de Valor (VO) e delega persistência.
- Repository (`ApoliceRepository`, `EndossoRepository`): Interação direta com ActiveRecord e regras transacionais.
- VO (Value Objects) (`Vo::ApoliceVo`, `Vo::EndossoVo`): Validações de formato, regras básicas e determinação automática do tipo de endosso (quando não enviado).
- Models (`Apolice`, `Endosso`): Mapeamento ActiveRecord para tabelas (`tb_apolices`, `tb_endossos`).
- Utilitário (`NullCleaner`): Remove valores nulos em respostas JSON.

Fluxo de criação:
`Controller -> Service -> VO validation -> Repository (AR transaction) -> Model persistido + Endosso BASE`

---
## 3. Modelagem de Dados
### Apólice (`tb_apolices`)
Campos:
- `numero` (PK, integer autoincrement – migrations usam `primary_key :numero`)
- `data_emissao` (date)
- `inicio_vigencia` (date)
- `fim_vigencia` (date)
- `importancia_segurada` (decimal(15,2)) – valor original base
- `lmg` (decimal(15,2)) – acumulado com endossos
- `status` (string) – "ATIVA" ou passa a "BAIXADA" na lógica atual

### Endosso (`tb_endossos`)
Campos:
- `numero` (PK, integer autoincrement se não enviado)
- `tb_apolice_numero` (FK apólice)
- `tipo_endosso` (string) – determinado automaticamente se não informado
- `data_emissao` (date)
- `cancelado_endosso_numero` (FK self para endosso cancelado)
- `fim_vigencia` (date opcional)
- `importancia_segurada` (decimal(15,2) – pode ser positiva ou negativa)
- `created_at` (timestamp – grava momento de criação)

Relacionamentos:
- Uma apólice possui muitos endossos.
- Um endosso de cancelamento referencia o endosso que cancela via `cancelado_endosso_numero`.

---
## 4. Regras de Negócio Implementadas
1. Criação de Apólice gera automaticamente um Endosso `BASE` com os dados iniciais.
2. LMG é atualizado somando o valor `importancia_segurada` de cada endosso normal (positivo ou negativo). Cancelamento reverte o impacto do endosso mais recente não cancelado.
3. Fim de vigência pode ser alterado por endosso que contenha `fim_vigencia` e classificado como alteração de vigência (sozinho ou combinado com aumento/redução IS).
4. Tipo de endosso é determinado no VO `EndossoVo` quando não enviado:
   - Baseado em presença de `fim_vigencia` e sinal de `importancia_segurada`.
5. Cancelamento cria um endosso `cancelamento` que referencia o endosso cancelado. Reverte alterações de LMG e fim de vigência daquele endosso.
6. Após cancelamento: se `lmg <= 0` ou `fim_vigencia <= Date.current`, apólice muda para status `BAIXADA`.
7. Validações de Apólice (VO):
   - Campos obrigatórios presentes
   - `fim_vigencia >= inicio_vigencia`
   - Diferença entre `inicio_vigencia` e `data_emissao` máxima de 30 dias (passado ou futuro)
   - Formato decimal com duas casas para IS e LMG, ambos positivos
8. Validações de Endosso (VO): formato decimal (duas casas) aceita negativo para reduções.
9. Endossos são imutáveis e nunca deletados.

---
## 5. Tipos de Endosso
| Tipo | Cenário |
|------|---------|
| BASE | Criado automaticamente junto da apólice |
| aumento_is | Apenas `importancia_segurada` positiva |
| reducao_is | Apenas `importancia_segurada` negativa |
| alteracao_vigencia | Apenas `fim_vigencia` alterado |
| aumento_is_alteracao_vigencia | `fim_vigencia` + IS positiva |
| reducao_is_alteracao_vigencia | `fim_vigencia` + IS negativa |
| cancelamento | Reverte último endosso não cancelado |

Cancelamento não exige `importancia_segurada` ou `fim_vigencia`.

---
## 6. Endpoints da API
Base URL (Docker): `http://localhost:3000`

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/apolices` | Cria nova apólice |
| GET | `/apolices` | Lista apólices |
| GET | `/apolices/:numero` | Consulta apólice (inclui endossos) |
| POST | `/apolices/:numero/endossos` | Cria endosso (normal ou cancelamento) |
| GET | `/apolices/:numero/endossos` | Lista endossos da apólice |
| GET | `/apolices/:numero/endossos/:endosso_id` | Consulta endosso específico |
| GET | `/csrf` | Obtém token CSRF (se necessário em clients Rails) |

Observação: A API expõe tipo de endosso gerado; não há atualização/deleção.

---
## 7. Exemplos de Requisições (curl – Windows CMD)
No Windows `cmd.exe`, evite aspas simples em JSON; use aspas duplas com escape para valores internos se necessário.

### Criar Apólice
```
curl -X POST http://localhost:3000/apolices -H "Content-Type: application/json" -d "{\"apolice\":{\"numero\":123456,\"data_emissao\":\"2025-10-26\",\"inicio_vigencia\":\"2025-11-25\",\"fim_vigencia\":\"2025-12-25\",\"importancia_segurada\":1000.01,\"lmg\":1000.00}}"
```
Resposta (200/201):
```
{
  "numero":123456,
  "data_emissao":"2025-10-26",
  "inicio_vigencia":"2025-11-25",
  "fim_vigencia":"2025-12-25",
  "importancia_segurada":"1000.01",
  "lmg":"1000.00",
  "status":"ATIVA"
}
```

### Criar Endosso (Aumento IS)
```
curl -X POST http://localhost:3000/apolices/123456/endossos -H "Content-Type: application/json" -d "{\"endosso\":{\"numero\":654321,\"importancia_segurada\":350.00}}"
```
Resposta (200):
```
{
  "numero":654321,
  "tb_apolice_numero":123456,
  "tipo_endosso":"aumento_is",
  "data_emissao":"2025-10-26",
  "importancia_segurada":"350.00",
  "created_at":"2025-10-26T12:00:00Z"
}
```

### Criar Endosso (Redução IS + alteração vigência)
```
curl -X POST http://localhost:3000/apolices/123456/endossos -H "Content-Type: application/json" -d "{\"endosso\":{\"importancia_segurada\":-150.00,\"fim_vigencia\":\"2026-01-15\"}}"
```
Tipo será classificado automaticamente como `reducao_is_alteracao_vigencia`.

### Cancelar Último Endosso
```
curl -X POST http://localhost:3000/apolices/123456/endossos -H "Content-Type: application/json" -d "{\"endosso\":{\"tipo_endosso\":\"cancelamento\"}}"
```

### Consultar Apólice
```
curl -X GET http://localhost:3000/apolices/123456 -H "Accept: application/json"
```

### Listar Endossos
```
curl -X GET http://localhost:3000/apolices/123456/endossos -H "Accept: application/json"
```

---
## 8. Fluxos Principais
1. Criação de Apólice → Endosso BASE criado → LMG inicial = IS.
2. Endosso de aumento/redução IS → LMG ajustado somando/subtraindo `importancia_segurada`.
3. Endosso com `fim_vigencia` → apólice atualiza fim de vigência para esse novo valor.
4. Endosso combinado (IS + vigência) → ambos efeitos aplicados.
5. Cancelamento → encontra último endosso não cancelado (exclui já cancelados e endossos de cancelamento) → cria endosso de cancelamento → reverte LMG e/ou vigência para o estado anterior.
6. Apólice pode tornar-se `BAIXADA` se após cancelamento LMG ≤ 0 ou vigência expirada.

---
## 9. Cancelamento de Endosso – Regras Internas
Implementado em `EndossoRepository#create_cancelamento`:
- Seleciona endosso alvo (último não cancelado, caindo para BASE se necessário).
- Cria registro `tipo_endosso = cancelamento` com referência `cancelado_endosso_numero`.
- Se o endosso cancelado tinha `fim_vigencia`, restaura para o `fim_vigencia` do endosso anterior.
- Se tinha `importancia_segurada`, subtrai esse valor do LMG.
- Caso `lmg <= 0` ou `fim_vigencia <= Date.current`, marca apólice como `BAIXADA` (o desafio cita "BAIXADA" – ajuste futuro).

---
## 10. Execução com Docker / Docker Compose
Pré-requisitos:
- Docker Desktop instalado
- Porta 3000 livre (app), 5432 (Postgres), 5400 (Adminer)

Passos (Windows CMD):
```
cd C:\git\segarante-challenge-3
docker compose build
docker compose up -d
```
Serviços:
- `ruby_app` → API Rails (http://localhost:3000)
- `postgres` → Banco de dados
- `adminer` → Interface DB (http://localhost:5400) – Server: postgres / User: postgres / Password: postgres / DB: postgres

Logs da aplicação:
```
docker compose logs -f ruby_app
```
Parar e remover:
```
docker compose down
```
Recriar com limpeza de volumes (cuidado – apaga dados):
```
docker compose down -v
```
Migrações são executadas automaticamente no `CMD` do Dockerfile (`rails db:migrate`). Se adicionar novas migrations após subir o container:
```
docker compose exec ruby_app bundle exec rails db:migrate
```

---
## 11. Execução Local (Sem Docker)
Pré-requisitos:
- Ruby 3.2.x
- PostgreSQL 15+
- Node.js para assets mínimos (já requerido no Dockerfile)

Passos:
```
cd C:\git\segarante-challenge-3
bundle install
# Configure DATABASE_URL ou edite config/database.yml conforme seu ambiente
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails server -b 0.0.0.0 -p 3000
```
Acesso: http://localhost:3000

---
## 12. Testes Automatizados (RSpec)
Executar:
```
cd C:\git\segarante-challenge-3
bundle exec rspec --format documentation
```
Status atual: 13 cenários passando (criação de apólice, criação de todos os tipos de endosso, cancelamentos e consultas).

Coberturas chaves:
- Criação e persistência de apólice
- Atualização de LMG em aumento e redução
- Alteração de fim_vigência
- Reversão de LMG e fim_vigência via cancelamento
- Determinação de tipos

---
## 13. Limitações & Próximos Passos
Limitações / divergências do enunciado:
- Status após invalidação fica `BAIXADA`.
- Não há validação adicional para impedir LMG negativo em cadeia de endossos (apenas depois de cancelamento é verificado). Poderia validar antes de criar.
- Não há autenticação / segurança.
- Não há paginação em listagens.
- Não há DTOs implementados (arquivos DTO estão vazios).
- Não há validação para impedir criação de endosso sem impacto (ex: sem fim_vigência e sem importância_segurada) – hoje vira `BASE` se ambos ausentes.

Sugestões futuras:
- Padronizar status (`ATIVA`, `BAIXADA`).
- Adicionar swagger/openapi (ex: rswag) no projeto.
- Implementar pagination `?page=` e `?per=`.
- Adicionar autenticação JWT.
- Adicionar validação de duplicidade / monotonicidade de vigência.

---
## 14. Coleção Postman
O repositório inclui: `Segarante Apolices Challenge.postman_collection.json` (e versão v2). Importe no Postman:
1. Abrir Postman → Import.
2. Selecionar arquivo JSON.
3. Executar na ordem: Criar Apólice → Criar Endossos → Cancelamento → Consultas.

Configurações dinâmicas sugeridas:
- Variável `baseUrl` = `http://localhost:3000`
- Scripts de teste podem validar status HTTP e campos (`tipo_endosso`, `lmg`).

---
## Códigos de Erro & Respostas
| Código | Situação |
|--------|----------|
| 201 / 200 | Sucesso em criação / consulta |
| 404 | Apólice ou Endosso não encontrado |
| 422 | Falha de validação (VO levanta `ArgumentError`) |

Mensagens de erro são simples (string JSON) – aprimorar para padrão estruturado.

---
## Formato de Valores Decimais
- Sempre duas casas decimais (ex: `1000.00`).
- Endosso aceita valores negativos para redução.

---
## Remoção de Campos Nulos
Respostas passam por `NullCleaner.remove_nulls`, retirando chaves com `null`.

---
## Licença
Uso interno para avaliação técnica. Ajustar conforme necessidade de distribuição.

---
## Contato
Em caso de dúvidas sobre o desafio ou melhorias, incluir instruções ou contato do mantenedor.

