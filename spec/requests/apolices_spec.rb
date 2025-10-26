# spec/requests/apolices_spec.rb (somente o request spec)
require 'rails_helper'
require 'bigdecimal'
require 'bigdecimal/util'
require 'securerandom'

RSpec.describe 'Apolices', type: :request do
  describe 'POST /apolices' do
    it 'Criar apólice' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01,
          lmg: 1000.00
        }
      }

      expect {
        post '/apolices',
             params: payload.to_json,
             headers: { 'Content-Type' => 'application/json' }
      }.to change(Apolice, :count).by(1)

      expect(response).to have_http_status(:created).or have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['numero']).to eq(numero)
      expect(body['importancia_segurada'].to_d).to eq(1000.01.to_d)
      expect(body['lmg'].to_d).to eq(1000.00.to_d)
    end
  end

  describe 'GET /apolices' do
    it 'Listar apólices' do

      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01,
          lmg: 1000.00
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get '/apolices', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.size).to eq(1)
    end
  end

  describe 'GET /apolices/:numero' do
    it 'Consulta por número da apólice' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01,
          lmg: 1000.00
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      expect(body['apolice']['lmg'].to_d).to eq(1000.00.to_d)
    end
  end

end
