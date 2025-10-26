# spec/requests/apolices_spec.rb (somente o request spec)
require 'rails_helper'
require 'bigdecimal'
require 'bigdecimal/util'
require 'securerandom'

RSpec.describe 'Endossos', type: :request do

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [aumento_is]' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      # deve ter aumentado o LMG em 350.00
      expect(body['apolice']['lmg'].to_d).to eq(1350.00.to_d)
      # deve possuir um endosso base + 1 criado.
      expect(body['endossos'][0]['tipo_endosso']).to eq('BASE')
      # deve possuir um endosso aumento_is.
      expect(body['endossos'][1]['numero']).to eq(numero_endosso)
      expect(body['endossos'][1]['tipo_endosso']).to eq('aumento_is')

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [reducao_is]' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: -350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      # deve ter aumentado o LMG em 350.00
      expect(body['apolice']['lmg'].to_d).to eq(650.00.to_d)
      # deve possuir um endosso base + 1 criado.
      expect(body['endossos'][0]['tipo_endosso']).to eq('BASE')
      # deve possuir um endosso reducao_is.
      expect(body['endossos'][1]['numero']).to eq(numero_endosso)
      expect(body['endossos'][1]['tipo_endosso']).to eq('reducao_is')

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [aumento_is_alteracao_vigencia]' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00,
               fim_vigencia: (Date.today + 90).to_s
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      # deve ter aumentado o LMG em 350.00
      expect(body['apolice']['lmg'].to_d).to eq(1350.00.to_d)
      # deve possuir um endosso base + 1 criado.
      expect(body['endossos'][0]['tipo_endosso']).to eq('BASE')
      # deve possuir um endosso aumento_is_alteracao_vigencia.
      expect(body['endossos'][1]['numero']).to eq(numero_endosso)
      expect(body['endossos'][1]['tipo_endosso']).to eq('aumento_is_alteracao_vigencia')

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [reducao_is_alteracao_vigencia]' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: -350.00,
               fim_vigencia: (Date.today + 90).to_s
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      # deve ter aumentado o LMG em 350.00
      expect(body['apolice']['lmg'].to_d).to eq(650.00.to_d)
      # deve possuir um endosso base + 1 criado.
      expect(body['endossos'][0]['tipo_endosso']).to eq('BASE')
      # deve possuir um endosso reducao_is_alteracao_vigencia.
      expect(body['endossos'][1]['numero']).to eq(numero_endosso)
      expect(body['endossos'][1]['tipo_endosso']).to eq('reducao_is_alteracao_vigencia')

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos/:numero_endosso' do
    it 'Consulta um endosso específico' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}/endossos/#{numero_endosso}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['numero']).to eq(numero_endosso)
      expect(body['tipo_endosso']).to eq('aumento_is')
      expect(body['importancia_segurada'].to_d).to eq(350.00.to_d)
    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Lista todos os endossos de uma apólice' do
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

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      get "/apolices/#{numero}/endossos", headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.size).to be >= 2
      expect(body[0]['tipo_endosso']).to eq('BASE')
      expect(body[1]['numero']).to eq(numero_endosso)
      expect(body[1]['tipo_endosso']).to eq('aumento_is')
    end
  end

end
