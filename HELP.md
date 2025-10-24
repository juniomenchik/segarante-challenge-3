$rails new .

$rails generate migration CreateTbApolices \
numero:primary_key \
data_emissao:date \
inicio_vigencia:date \
fim_vigencia:date \
importancia_segurada:decimal \
lmg:decimal \
status:string --force


$rails db:migrate

$rails generate migration CreateTbEndossos \
numero:primary_key \
tb_apolice_numero:integer \
tipo_endosso:string \
data_emissao:date \
cancelado_endosso_numero:integer \
fim_vigencia:date \
importancia_segurada:decimal --force


$rails db:migrate
