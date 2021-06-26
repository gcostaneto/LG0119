---
title: "Modelagem da Interação GxE"
subtitle: "Teoria e prática no R usando dados fenotípicos, genômicos e ambientais"
author: "Germano Costa Neto"
date: "June 26, 2020"
output:
  prettydoc::html_pretty:
    theme: cayman
    highlight: github
    keep_md: true
---

# Modelagem da Interação GxE

### Teoria e prática no R usando dados fenotípicos, genômicos e ambientais
author: Germano Costa Neto,  June 26, 2020

--------------------------------------------------------------------

## Why R?

Não sabe o que é o R? Está perdendo tempo!

- R é uma linguagem de programação multi-paradigma orientada a objetos, programação funcional, dinâmica, fracamente tipada, voltada à manipulação, análise e visualização de dados. 
Foi criado originalmente por Ross Ihaka e por Robert Gentleman no departamento de Estatística da Universidade de Auckland, Nova Zelândia. 
(sim, eu copiei essa parte do [Wikipédia](https://pt.wikipedia.org/wiki/R_(linguagem_de_programa%C3%A7%C3%A3o)))

**Principais características**

- Intuitivo
- Ensina estatística e álgebra!
- É open source (código aberto e gratuito)
- Contribuições globais
- Podemos sempre evoluir!



## (1) Dados Multi-ambientais      

- **dados multiambientais**: data base contendo informações de fenótipos (clássicos, HTP ou fenótipos moleculares) coletados sob múltiplas condições ambientais.
- Experimentos são avaliados sob múltiplos fatores (p.ex: níveis de adubo, lâminas de irrigação) ou diversos locais, anos ou datas de plantio;
- Auxiliam na alocação de cultivares, orientam o manejo cultural ótimo e alocação de esforços (humanos e financeiros);
- Um conjunto de experimentos é denominado rede experimental (outro termo é Multi-Environment Trials (MET));
- Um fenótipo avaliado em diferentes ambientes pode ser visto como um 'trait diferente';
- São essenciais para verificar a eficiência do programa de melhoramento!

Usaremos data sets de cada pacote e data sets adicionais. Abaixo estão disponíveis dois *data sets* de METs que serão usados como exemplos adicionais.

- **Arroz irrigado e de terras altas (EMBRAPA)**

Contem uma amostra de 5 anos de ensaios de VCU para dois programas de melhoramento de arroz (irrigado, Sul do Brasil) e sequeiro/terras altas (meio-norte do Brasil). O fenótipo-alvo de trabalho é rendimento de grãos (kg/ha). Contêm dados climáticos coletados de estações meteorológicas da rede experimental da Embrapa (AB Heinemann, Santo Antonio de Goiás).

**Para baixar**:


```r
1+1
```

```
## [1] 2
```

- **Milho tropical (hibrdos do painel USP)**

Contem uma amostra de XX hibridos avalidados em 2 anos, 2 locais e 2 manejos de nitrogênio. Híbridos pertencentes ao germoplasma do [Laboratório de Melhoramento de Plantas Alógamas](http://www.genetica.esalq.usp.br/alogamas/equipe.html) da Universidade de São Paulo, ESALQ/USP. Os híbridos são resultantes de um dialelo envolvendo 49 linhagens parentais (pai x mãe). Contêm dados moleculares (32k SNPs obtidos via Affimetrix) e fenotípicos (rendimento de grãos, altura de plantas e altura de espiga).

**Para baixar**:


```r
1+1
```

```
## [1] 2
```


**OBS: os data sets disponibilizados são apenas amostras usadas para demonstração dos códigos. Nenhuma inferencia pode ser feita com os resultados obtidos, uma vez que estes não representam a totalidade dos dados usados para testes de hipóteses dos autores que os disponibilizaram. Minha sugestão é: olhem os códigos, pratiquem e testem com os seus próprios data sets!**

- *PLUS*: baixem data sets de repositórios públicos da internet, como G2F, Soy NAM, Maize NAM, CIMMYT Dataverse entre outros.


**Analises individuais de cada experimento**


-----------------------------------------------------------------------

## (2) Norma de Reação via Regressão Linear FW

- Para esta etapa, usaremos o pacote FW e funções do pacote E2P (envirome-phenotypic associations, in develop.)


```r
1+1
```

```
## [1] 2
```


**2.1 Modelo de Finlay-Wilkinson**


- Passo 1: Estimar Médias ambientais ($\mu+h_{j}$)

$$y_{i j }=\mu+g_{i}+h_{j}+\varepsilon_{i j }$$

- Passo 2: Regressão das observações sob as médias ambientais (centralizadas na media geral, isto é: $h_{j}$)

$$y_{i j }=\mu+g_{\mathrm{i}}+\hat{h}_{j}+b_{i} \hat{h}_{j}+\varepsilon_{i j }$$


**Quadrados mínimos ordinários (ordinary least squares, OLS)**

- É o padrão desenvolvido nos anos 60.
- Efeitos fixos
- Problemas com dados faltantes
- mais de 4 ambientes é o ideal
- Quanto mais genótipos e mais ambientes, melhor a estimativa dos parametros
- covariancia entre genótipo-ambiente (problema comum dos modelos empíricos, mas nesse é o caso extremo)




```r
require(FW)
```

```
## Loading required package: FW
```

```
## The FW package received financial support from NIH grants R01GM101219 and R01GM099992 and from Arvalis
```

```
## 
```

```r
data(wheat) # chama um determinado data set do pacote

y   = wheat.Y$y    # vetor de fenótipos (p genotipos, q ambientes, pq = n)
GID = wheat.Y$VAR  # vetor de fatores para genotipos (genotypes identification, GID)
ENV = wheat.Y$ENV  # vetor de fatores para ambientes 
```

Ajustando o modelo: 


```r
lm1 = FW(y=y,VAR=GID,ENV=ENV,method="OLS")  # uso de ordinary least squares
summary(lm1) # me resuma o que tem dentro de lm1
```

```
##                Length Class  Mode     
## y              2396   -none- numeric  
## whichNa           0   -none- numeric  
## VAR            2396   factor numeric  
## ENV            2396   factor numeric  
## VARlevels       599   -none- character
## ENVlevels         4   -none- character
## mu                1   -none- numeric  
## g               599   -none- numeric  
## b               599   -none- numeric  
## h                 4   -none- numeric  
## yhat           2396   -none- numeric  
## var_e           599   -none- numeric  
## var_e_weighted    1   -none- numeric
```

Explorando o objeto:


```r
lm1$g[1:10]   # efeitos de genótipo + media geral (isto é, media dos genótipos)
```

```
##  [1] 3.234110 4.569245 2.946624 5.009052 3.908120 4.768925 3.906098 4.006865
##  [9] 3.819623 4.358714
```

```r
lm1$b[1:10]   # efeito de genotipo ao longo do ambiente
```

```
##  [1] -0.01499334 -0.23156180  0.15262836  0.33197972  0.16119069  0.14964002
##  [7]  0.05953297  0.11217795  0.25210868  0.65972004
```

```r
responsividade = (1+lm1$b)
lm1$h # efeitos de ambiente, aqui chamado de h
```

```
##         [,1]
## 1  0.9578438
## 2  0.3218138
## 4 -0.3224948
## 5 -0.9571629
```

```r
lm1$yhat[1:10] # valores preditos pela relacao linear
```

```
##  [1] 5.196354 4.288082 3.367988 2.461661 5.402035 4.468663 3.523142 2.591769
##  [9] 5.170596 4.276038
```

```r
lm1$y[1:10] # valores observados (que foram usados)
```

```
##  [1] 6.168930 3.141820 2.743335 3.260000 4.987500 4.830160 4.045450 2.122500
##  [9] 5.352500 3.994165
```

Organizando melhor:


```r
h    <- data.frame(h    = lm1$h,    ENV = lm1$ENVlevels)
g    <- data.frame(g    = lm1$g,    GID = lm1$VARlevels)
b    <- data.frame(b    = lm1$b,    GID = lm1$VARlevels)
d2   <- data.frame(d2   = lm1$var_e,GID = lm1$VARlevels)
yHat <- data.frame(yHat = lm1$yhat, ENV = lm1$ENV,GID = lm1$VAR )

require(tidyverse)
```

```
## Loading required package: tidyverse
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --
```

```
## v ggplot2 3.3.5     v purrr   0.3.4
## v tibble  3.0.4     v dplyr   1.0.2
## v tidyr   1.1.2     v stringr 1.4.0
## v readr   1.4.0     v forcats 0.5.0
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
FW_output1 <- yHat %>% 
              merge(g, by = 'GID') %>% # pipes do tidyverse!
              merge(b, by = 'GID') %>% 
              merge(d2,by = 'GID') %>% 
              merge(h, by = 'ENV')

head(FW_output1)
```

```
##   ENV     GID     yHat        g            b        d2         h
## 1   1  103122 4.177593 3.234110 -0.014993340 0.9045602 0.9578438
## 2   1 1500224 5.808243 4.726375  0.129482689 1.0201514 0.9578438
## 3   1 1342417 5.575969 4.673711 -0.058032395 0.5576888 0.9578438
## 4   1 1290414 5.273230 4.308304  0.007394582 0.2585072 0.9578438
## 5   1 1047493 5.305289 4.569245 -0.231561801 0.1006490 0.9578438
## 6   1 1504972 5.796717 4.925814 -0.090766559 0.2943633 0.9578438
```

Correlações entre estimado (y_hat, y chapéu) e observados (y) [não é validação cruzada!]


```r
cor(lm1$yhat,lm1$y)
```

```
##           [,1]
## [1,] 0.9122519
```

```r
cor(lm1$yhat,lm1$y,method = 'spearman') # o que houve?
```

```
##           [,1]
## [1,] 0.9176498
```





**Plots úteis**

Primeiramente vamos organizar os outputs do ```FW``` para então podermos usar o ```ggplot2```

- Biplot entre média geral (efeito de genótipo constante) e responsividade ("norma de reação" do genótipo)

- Biplot entre média geral (efeito de genótipo constante) e Estabilidade (variância do desvio para cada genótipo)


**Abordagem Bayesiana para uso do modelo de Finlay-Wilkinson**

- Funções de densidade e probabilidade tem como parametros uma esperança de média (tendencia central) e variancia (dispersão).
- quando vemos $x \sim  \mathrm{N}\left(0, \mathbf{K} \sigma_{x}^{2}\right)$, quer dizer "$x$ tem distribuição Normal, com esperança de média igual a 0 variância assumida como $\mathbf{K} \sigma_{x}^{2}$, no qual $\mathbf{K}$ é uma matriz de relacionamento para as observações presentes em $x$". Se assumirmos ausencia de relação entre as observações, $\mathbf{K} = I$

-------------------------------------------------------

Modelando FW com probabilidade condicional:
$$p(\mathbf{y} \mid \boldsymbol{\theta})=\prod_{i j k} \mathrm{~N}\left(\mu+g_{i}+h_{j}+b_{i} h_{j}, \sigma_{\varepsilon}^{2}\right)$$

e função densidade probabilidade a priori como: $p(\boldsymbol{\theta})=p\left(\sigma_{\varepsilon}^{2}\right) p\left(\mathbf{g} \mid \sigma_{g}^{2}\right) p\left(\mathbf{b} \mid \sigma_{b}^{2}\right) p\left(\mathbf{h} \mid \sigma_{h}^{2}\right) p\left(\sigma_{g}^{2}\right) p\left(\sigma_{b}^{2}\right) p\left(\sigma_{h}^{2}\right)$

em que: erro $\sigma_{\varepsilon}^{2} \sim \chi^{-2}\left(\nu_{\varepsilon}, S_{\varepsilon}^{2}\right)$, qualidade ambiental $\mathbf{h} \sim \mathrm{N}\left(0, \quad \mathbf{H} \sigma_{h}^{2}\right)$, efeito de genótipo (valor genético) $\mathbf{g} \sim \mathbf{N}\left(0, \mathbf{A} \sigma_{g}^{2}\right)$ e efeito de responsividade de genótipo ("norma de reação", neste caso "adaptabilidade") $\mathbf{b} \sim \mathrm{N}\left(0, \mathbf{A} \sigma_{b}^{2}\right)$, sendo $\mathbf{A}$ e $\mathbf{H}$ matrizes "realizadas" de relacionamento entre genótipos e entre ambientes, respectivamente.
COmo padrão, assume-se $\mathbf{A} = \mathbf{I_p}$ e $\mathbf{H} = \mathbf{I_q}$,  sendo I uma matriz diagonal de 1s (identidade) e p (número de genótipos) e q (número de ambientes). 

- Matrizes de relacionamento são criadas usando covariáveis que supomos descrever algum tipo de relação entre as observações.
- Podem ser covariáveis espaciais (distancia entre parcelas), morfológicas (traits secundários, HTP), moleculares (marcadores SNP), descritores ambientais (covariáveis ambientias) etc....
- Em genética quantitativa, é muito comum usar o pedigree (parentesco "anotado" entre genótipos) e as matrizes de relacionamento genômico. Estas últimas podem ser criadas para diversos efeitos, como aditividade, dominancia, epstasia...
- Essas matrizes podem ser montadas matematicamente de diferentes formas, isto é, por diferentes [**métodos de kernels**](https://github.com/gcostaneto/KernelMethods), como GBLUP (covariância linear), Gaussian Kernel (distancias não-lineares), Deep Kernel (imitando camadas de aprendizado de máquina de forma nao-linear)....entre outros!
- As matrizes de relacionamento tem que ter o mesmo número de linhas e colunas, sendo estes exatamente o número de fatores do efeito a ser modelado. Matrizes de ambiente, tem número de ambientes x número de ambientes; Matrizes de genótipo tem número de genótipos x número de genótipos, na qual em ambas a diagonal denota a relação do inviduo com ele mesmo.
- Por isso nas matrizes $\mathbf{I}$ a diagonal é igual a 1 e off-diagonal igual a 0, isto é: o individuo só tem relação CONSIGO MESMO, e nenhuma relação com as outras observações.



**Rodando o modelo FW usando Amostrador de Gibbs e A = Ip, H = Iq (padrão do pacote)**


```r
lm2=FW(y=y,VAR=GID,ENV=ENV,method="Gibbs") # amostrador de Gibbs (bayesiano)
```

```
## iter:1000
## iter:2000
## iter:3000
## iter:4000
## iter:5000
```

```r
seed      = 91281 # você escolhe! Se mudar a seed, mudam as estimativas dos parametros (b,g,h) ?
iteracoes = 10E3
burnin    = 20E2
thining   = 5

lm2=FW(y=y[1:100],VAR=GID[1:100],ENV=ENV[1:100],method="Gibbs",
       seed = seed,thin = thining,burnIn = burnin,nIter = iteracoes) # amostrador de Gibbs (bayesiano)
```

```
## iter:1000
## iter:2000
## iter:3000
## iter:4000
## iter:5000
## iter:6000
## iter:7000
## iter:8000
## iter:9000
## iter:10000
```

---------------------------------------------------------------------

## (3) GGE biplot       

- O método GGE biplot surgiu de uma compilação e modelos bilineares (um modelo linear dentro de outro modelo linear!) e de suas visualizações gráficas.
- O modelo mais popular até o meio dos anos 2000 era o AMMI [veja material dos profs Roland Vencovsky e João Batista Duarte](https://github.com/gcostaneto/Mini_Curso_GxE_pt/blob/main/literatura/Material%20GGE/AMMI.pdf)
- Com a criação do software para windows, focado no modelo SREG (sites-regression, G+GE), o nome popularizou e hoje em dia as pessoas confundem software com o modelo
- SREG: Modelo bilinear por Cornelius et al (1996)

**3.1 usando Site-Regression Model**


$$\bar{y}_{i j}-\mu_{j}=\sum_{k=1}^{t} \lambda_{k} \alpha_{i k} \gamma_{j k}+\bar{\varepsilon}_{i j}$$
em que: $\mu_{j} = \mu + E_{j}$ = média dos ambientes

- SREG1 (usa apenas um componente), SREG2 (primeiro e segundo componentes), SREG3, SREG4....SREGk = modelo original, sendo *k* o número total de componentes para atingir 100% da variância explicada.
- Em termos práticos, não usamos toda a variância, pois nela há sinal (padrão) + ruído (variância "desnecessária")
- O ideal é captar pelo menos 60% com dois componentes....se não chegou a 60%, mas componentes são necessários, o que pode inviabilizar o método (e sua visualização gráfica, afinal é "bi"plot)
- Indices combinando os componentes podem ser usados para rankear genótipos;
- Em tese, a abordagem funciona para qualquer matriz de dupla entrada: genótipos x ambientes, cultivares x níveis de nitrogênio, genótipos x traits, pais x mães (dialelos), pais x mães-ambientes....depende do que você quiser decompor!



**3.2 usando additive main effects and multiplicative interaction (AMMI)**


$$\bar{y}_{i j}=\mu+G_{j}+E_{j}+\sum_{k=1}^{t} \lambda_{k} \alpha_{i k} \gamma_{j k}+\bar{\varepsilon}_{i j}$$

# (4) Regressão Fatorial (FR) com dados ambientais



- Passo 1: Ajustar o modelo de análise conjunta ($\mu+h_{j}$)

$$y_{i j }=\mu+G_{i}+E_{j}+GE_{ij}+\varepsilon_{i j }$$

- Passo 2: Realizar regressões sobre algum efeito (e.g., GE)
$$GE_{ij}=\sum_{k=1}^{t} b_{ij} w_{jk} +GE^{*}_{i j}$$

- Passo 3: O modelo global é reescrito então como:

$$y_{i j }=\mu+G_{i}+E_{j}+\sum_{k=1}^{t} b_{ij} w_{jk} +GE^{*}_{i j}+\varepsilon_{i j }$$

em que: $\sum_{k=1}^{t} b_{ij} w_{jk} $ é o padrão de interação GE captado pelas covariáveis ambientais e $+GE^{*}_{i j}$ é a interação GE residual não captada pelas covariáveis ambientais

- Em síntese, o modelo pode ser usado para qualquer outro efeito, como G+GE ou o próprio y:

y (média global):

$$\bar{y}_{i j}=\sum_{k=1}^{t} b_{ij} w_{jk} +y^{*}_{i j}+\bar{\varepsilon}_{i j}$$

E G+GE:

$$\bar{y}_{i j}-\mu_{j}=G_{i}+\sum_{k=1}^{t} b_{ij} w_{jk} +GGE^{*}_{i j}+\bar{\varepsilon}_{i j}$$

**Usando FR_model()**


 **outras opções para modelagem**
 
- Quadrados mínimos parciais (partial least squares, PLS) [Vargas et al., 1999, Crossa et al., 1992, Costa-Neto, 2017; Porker et al., 2019]
- Generalized additive model (GAM) [Heinemann et al., under review]
- RandomForest
- Regressões Aleatórias (Bayesianas, BayesR) [Millet et al., 2019 é um exemplo integrando com predição genômica]
- Modelagem conjunta (sob modelos mistos), usando para isto o software ASReml-R [Heslot et al., 2014; Ly et al., 2018]
- Regressões multivariadas (PCA dos dados ambientais seguida da regressão sobre autovetores como covariáveis)

------------------------------------------------------------------------

## (5) Regressões genômicas


------------------------------------------------------------------------

## (6) Envirotyping usando o pacote EnvRtype R


------------------------------------------------------------------------

## (7) Predição Genômica com Envirômica




## Hands-on (e questões práticas para se pensar e trabalhar)

- 1. É possível fazer SREG sobre os efeitos dos marcadores?
- 2. Rode difernetes modelos usando o pacote metan
- 3. Diferenças entre AMMI, SREG e GREG usando os dados de milho (USP) e trigo (FW, data(wheat))
- 4. Com os dados de arroz, rode componentes principais (PCA) para dados ambientais e em seguida use os autovetores como covariáveis no FR_model()
- 5. Agrupe ambientes com base em dados de temperatura
- 6. Agrupe ambientes com base em dados de radiação
- 7. Agrupe ambientes com base em dados de chuva
- 8. 5-7 deram agrupamentos iguais? e se usar todos juntos ao mesmo tempo?
- 9. Agrupe ambiente com base nos dados de fenótipos (indices empiricos de qualidade ambiental)
- 10. Monte matrizes de relacionamento ambiental usando diferentes tipos de dados ambientais e indices empiricos de qualidade ambiental
- 11. FW com matrizes de relacionamento ambiental para H 
- 12. Rode kernel_model() comparando MM, MDs com os respectivos modelos enriquecidos EMM e EMDs
- 13. crie seus esquemas de validação cruzada (remova genótipos, parentais em comum, ambientes, ambientes em comum após agrupamentos), análises entre e dentro de mega-ambientes (isto é, rode GGE e depois ajuste modelos de predição genomica para cada mega-ambiente)
- 14. Faça downlaod de dados climáticos para o conjunto de arroz, organize os dados e rode FR_model com grupos diferentes de variáveis. Depois cheque os coeficientes de regresão (normas de reação dos genótipos) e a variância fenotípica explicada por cada variável
- 15. Dá pra usar o pacote gge/GGEBiplots para analisar apenas dados ambientais? se sim, o que encontramos ao fazer isso?
- 16. Explore outras ferramentas que não foram apresentadas aqui! Procure por pacotes de RandomForest no R, SVM (support vector machine), Gradient Boosting Machine (GBM), Convolutional Neural Networks (CNN)....
- 17. Modelos SREG e AMMI: Monte as matrizes GE e G+GE "na mao" sem usar a função gge() e depois use PCA() para decompor a matriz
- 18. Faça os gráficos de norma de reação (tipo em FW) usando como indice ambiental alguma covariável ambiental relacionada a temperatura do ar, radiação etc....isso é regressão fatorial? qual é a conclusão que se pode tirar dessas figuras? E neste caso, qual é a interpretação dos parametros g, b e d2 ?

