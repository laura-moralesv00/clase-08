---
pagetitle: "8 - Visualizaciones en R"
title: "Taller de R: Estadística y programación"
subtitle: "Lecture 8: Visualizaciones en R"
author: 
  name: Eduard Fernando Martínez González
  affiliation: Universidad de los Andes | [ECON-1302](https://bloqueneon.uniandes.edu.co/d2l/home/133092) #[`r fontawesome::fa('globe')`]()
output: 
  html_document:
    theme: flatly
    highlight: haddock
    # code_folding: show
    toc: yes
    toc_depth: 4
    toc_float: yes
    keep_md: false
    keep_tex: false ## Change to true if want keep intermediate .tex file
    ## For multi-col environments
  pdf_document:
    latex_engine: xelatex
    toc: true
    dev: cairo_pdf
    # fig_width: 7 ## Optional: Set default PDF figure width
    # fig_height: 6 ## Optional: Set default PDF figure height
    includes:
      in_header: tex/preamble.tex ## For multi-col environments
    pandoc_args:
        --template=tex/mytemplate.tex ## For affiliation field. See: https://bit.ly/2T191uZ
always_allow_html: true
urlcolor: darkblue
mainfont: cochineal
sansfont: Fira Sans
monofont: Fira Code ## Although, see: https://tex.stackexchange.com/q/294362
## Automatically knit to both formats
---

```{r setup, include=F , cache=F}
# load packages
require(pacman)
p_load(knitr,tidyverse,janitor,rio,skimr,kableExtra)
Sys.setlocale("LC_CTYPE", "en_US.UTF-8") # Encoding UTF-8

# option html
options(htmltools.dir.version = F)
opts_chunk$set(fig.align="center", fig.height=4 , dpi=300 , cache=F)
```

<!--=================-->
<!--=================-->
## **[0.] Checklist**

Antes de iniciar con esta lectura asegúrese de...

<!--------------------->
#### **☑ Lectures previas**

Asegúrese de haber revisado la [Lecture 7: Combinar conjuntos de datos](https://lectures-r.gitlab.io/uniandes-202202/lecture-7/)

<!--------------------->
#### **☑ Versión de R**

Tener la versión `r R.version.string` instalada:
```{r, cache=F , echo=T}
R.version.string
```

<!--------------------->
#### **☑ Librerías**

Instale/llame la librería `pacman`, y use la función `p_load()` para instalar/llamar las librerías de esta sesión:

```{r eval=FALSE}
## instalar/llamar pacman
require(pacman)

## usar la función p_load de pacman para instalar/llamar las librerías de la clase
p_load(tidyverse, # funciones para manipular/limpiar conjuntos de datos.
       rio, # función import/export: permite leer/escribir archivos desde diferentes formatos. 
       skimr, # función skim: describe un conjunto de datos
       janitor) # función tabyl: frecuencias relativas
```

#### **☑ Obtener conjunto de datos:**

Importe y colapse los datos de la GEIH

```{r}
cg <- import("input/Enero - Cabecera - Caracteristicas generales (Personas).csv") %>% clean_names()
ocu <- import("input/Enero - Cabecera - Ocupados.csv") %>% clean_names()

geih <- left_join(x = cg, y = ocu, by = c("directorio","secuencia_p","orden"))
```

[Diccionario de la GEIH](https://microdatos.dane.gov.co/catalog/659/data_dictionary)

<!--=================-->
<!--=================-->
## **[1.] Descriptivas**

<!--------------------->
### **1.1 Generales**

**summary** ofrece una descripción general(quartil, media, mediana) de todas las columnas presentes.

```{r}
summary(geih[,c("inglabo", "p6020", "p6960","p6040","p6450")])
```

`Nota`

* **p6020:** sexo

* **p6040:** ¿Cuantos años tiene?

* **p6960:** ¿cuántos años lleva afiliado al fondo de pensiones?

* **inglabo:** Ingresos totales

* **p6450:** ¿ Su contrato laboral es verbal o escrito?

**select + summarize_all** se usa para obtener las descriptivas deseadas de una o mas variables., 

```{r}
select(geih, c("inglabo")) %>%  summarize_all(list(min, max, median, mean), na.rm = T)
```

<!--------------------->
### **1.2 Agrupadas**

**group_by()** toma un tibble/data.frame y lo convierte en un tibble agrupado, donde las operaciones son realizadas por grupo. 

```{r}
geih %>% 
select(inglabo,p6020,p6960) %>% 
group_by(p6020) %>%  
summarise(promedio_inglabo = mean(inglabo, na.rm = T),
          media_inglabo = median(inglabo, na.rm = T),
          promedio_p6960 = mean(p6960, na.rm = T),
          media_p6960 = median(p6960, na.rm = T))
```

<!--=================-->
<!--=================-->
## **[2.] Visualizaciones**

<!--------------------->
### **2.1** `ggplot()`

**ggplot** es la manera fácil y eficaz de visualizar datos en R. Las partes de ggplot son: *ggplot* para especificar los datos y **geom_...** para especificar el tipo de geometría.

```{r}
ggplot(data = geih , mapping = aes(x = p6040 , y = inglabo))
```

`nota` **"mapping" y "aes"** se usan para indicar las cordenadas de los datos.

```{r, warning=FALSE}
## + geometry
ggplot(data = geih , mapping = aes(x = p6040 , y = inglabo)) +
geom_point(col = "red" , size = 0.5)
```

Puedes guardar la grafica dentro de un objeto: 
```{r, warning=FALSE}
graph_1 <- ggplot(data = geih, 
                  mapping = aes( x =p6040 , y = inglabo, group= as.character(p6020), color = as.factor(p6020))) +
           geom_point(size = 0.5)
graph_1
```

y añadir atributos a este objeto
```{r, warning=FALSE}
graph_1 + scale_color_manual(values = c("2"="red" , "1"="blue") , label = c("1"="Hombre" , "2"="Mujer") , name = "Sexo")
```

**density chart:**
```{r, warning=FALSE}
density <- filter(geih, !is.na(p6450) & inglabo < 1e+07 ) %>% 
           ggplot(data=. , mapping = aes(x = inglabo, group = as.factor(p6450), fill = as.factor(p6450))) + 
           geom_density() 

density
```

se cambian los ejes
```{r, warning=FALSE}
density <- density  + 
           scale_fill_discrete(label = c("1"="Verbal" , "2"="Escrito", "9"="No informa/Conoce") , name = "Contrato") + 
           labs(x = "Ingresos" , y = "",
                title = "Ingresos menores a 10 SLMV",
                subtitle = "Desagregados por tipo de contrato")
density
```


<!--------------------->
### **2.2 `group_by()` `+` `ggplot()`** 

```{r}
## summarize data
geih %>% 
group_by(p6020) %>% 
summarise(ingresos = mean(inglabo, na.rm = T)) 

## plot
ingresos <- geih %>% 
            group_by(p6020) %>% 
            summarise(ingresos = mean(inglabo, na.rm = T)) %>% 
            ggplot(data=. , mapping = aes(x = as.factor(p6020) , y = ingresos, fill = as.factor(p6020))) + 
            geom_bar(stat = "identity") 
ingresos
```

se cambian los ejes y el theme:

```{r}
ingresos +
scale_fill_manual(values = c("2"="red" , "1"="blue") , label = c("1"="Hombre" , "2"="Mujer") , name = "Sexo") +
labs(x = "sexo") + 
theme_classic()
```



<!--------------------->
## **Para seguir leyendo:**

* Wickham, Hadley and Grolemund, Garrett, 2017. R for Data Science [[Ver aquí]](https://r4ds.had.co.nz)

  + Cap. 5: Data transformation
  + Cap. 10: Tibbles
  + Cap. 12: Tidy data

