# História do dataset socios-brasil

1. No fim de 2017 a Receita Federal do Brasil [liberou um dataset com os sócios
   das empresas
   brasileiras](http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-abertos-do-cnpj);

2. No início de 2018 [criei um programa para baixar, corrigir e converter os
   dados para CSV](https://github.com/turicas/socios-brasil/);

3. No meio de 2018 fiz junto com alguns amigos um pedido de acesso à informação
   para termos mais dados, como identificador único dos sócios (CPF) e CNAEs
   das empresas - [parte da história foi contada
   aqui](https://medium.com/serenata/o-dia-que-a-receita-nos-mandou-pagar-r-500-mil-para-ter-dados-públicos-8e18438f3076).

4. Meses (e vários recursos no pedido via LAI) depois, recebemos um pendrive
   pelos Correios com os dados e eu criei um outro script (dentro do mesmo
   repositório de código no GitHub) para converter os novos dados para CSV - o
   formato é parecido, mas diferente, dado que tem informações diferentes; eu
   subi os dados originais e convertidos para o Google Drive e compartilhei o
   link publicamente, para que todos pudessem acessar os dados sem precisar
   fazer o pedido como fizemos (afinal, é dado público). Nota: outras pessoas
   também fizeram pedidos similares e receberam o dump.

5. Um tempo depois que recebemos o pendrive a [RFB liberou no próprio site os
   arquivos](http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj),
   atualizei então o programa para baixar essa nova versão dos dados do site e
   convertê-los.

6. Após rodar análises nos dados, percebi que a residência dos sócios está
   errada - [veja mais
   detalhes](https://gist.github.com/turicas/ad0ab80b8eb3337dafb62fcfd2924ccd)
   - e criei um chamado na Ouvidoria do Ministério da Economia alertando sobre
   o problema; responderam dizendo que passariam para o setor técnico, mas
   depois nunca mais me atualizaram sobre.

7. No dia 05 de abril de 2019 tentei baixar o arquivo (que parece ter sido
   atualizado) no site deles e a previsão de download era de 4 dias; consegui
   baixar em umas 7h porque fiz o download em paralelo de diversos servidores
   do [Brasil.IO](https://brasil.io/). Abri um protocolo na ouvidoria com a
   reclamação e a resposta não foi muito diferente da resposta do item
   anterior. Deixei então os dados originais disponíveis para download no
   Brasil.IO (além dos dados convertidos), assim quem quiser acesso ao dado
   original poderá baixá-lo de 10 a 100x mais rápido que usando o site da RFB -
   [veja mais
   detalhes](https://twitter.com/turicas/status/1114185311372873729).

8. A partir de então, toda vez que a RFB atualiza os dados em seu site eu faço
   o processo de baixar os arquivos originais, deixá-los disponíveis para
   download mais rápido no Brasil.IO, converter os dados para CSV e também
   disponibilizar os dados já convertidos. Em geral publico no Twitter - [veja
   a última conversão que
   fiz](https://twitter.com/turicas/status/1197125153047662592). Ainda preciso
   adicionar esses detalhes na [página desse dataset no
   Brasil.IO](https://brasil.io/dataset/socios-brasil).
