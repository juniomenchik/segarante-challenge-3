Perguntas Sobre a Lógica do Negócio.


Caso for criado uma Apólice.
    Posso cancelar um endosso ?
        Se cancelar um endosso, e possui apenas o BASE, a apolice será BAIXADA.

Não foi descrito explicitamente no desafio, então deixei que o usuario gerasse os IDs do endosso.
    pois o id da Apólice é o numero, e o numero é um campo obrigatório. 
    Porém se mandar nulo, será auto_incrementado. 

Não entendi muito bem se a importancia_segurada da apolice deveria ser ou não atualizada
    porque ela estava como "original",  e o LMG deveria "refletir" o valor da IS.
    Então deixei que a importancia_segurada fosse atualizada junto com o LMG conforme os endossos fossem criados.