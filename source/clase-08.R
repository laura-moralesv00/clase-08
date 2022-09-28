
## instalar/llamar pacman
require(pacman)

## usar la función p_load de pacman para instalar/llamar las librerías de la clase
p_load(tidyverse, # funciones para manipular/limpiar conjuntos de datos.
       rio, # función import/export: permite leer/escribir archivos desde diferentes formatos. 
       skimr, # función skim: describe un conjunto de datos
       janitor) # función tabyl: frecuencias relativas

#### **Obtener conjunto de datos:**
cg <- import("input/Enero - Cabecera - Caracteristicas generales (Personas).csv") %>% clean_names()
ocu <- import("input/Enero - Cabecera - Ocupados.csv") %>% clean_names()
geih <- left_join(x = cg, y = ocu, by = c("directorio","secuencia_p","orden"))

## **[1.] Descriptivas**

### **1.1 Generales**

## **summary** ofrece una descripción general(quartil, media, mediana) de todas las columnas presentes.
summary(geih[,c("inglabo", "p6020", "p6960","p6040","p6450")])

geih %>% 
select(inglabo,p6020,p6960) %>%
summarize_all(list(min, max, median, mean), na.rm = T)

### **1.2 Agrupadas**

## **group_by()** toma un tibble/data.frame y lo convierte en un tibble agrupado, donde las operaciones son realizadas por grupo. 

geih %>% 
select(inglabo,p6020,p6960) %>% 
group_by(p6020) %>%  
summarise(promedio_inglabo = mean(inglabo, na.rm = T),
          media_inglabo = median(inglabo, na.rm = T),
          promedio_p6960 = mean(p6960, na.rm = T),
          media_p6960 = median(p6960, na.rm = T))

## **[2.] Visualizaciones**

### **2.1** `ggplot()`

## **"mapping" y "aes"** se usan para indicar las cordenadas de los datos.
ggplot(data = geih , mapping = aes(x = p6040 , y = inglabo))

## + geometry
ggplot(data = geih , mapping = aes(x = p6040 , y = inglabo)) +
geom_point(col = "red" , size = 0.5)

## Puedes guardar la grafica dentro de un objeto: 
graph_1 <- ggplot(data = geih, 
                  mapping = aes( x =p6040 , y = inglabo, group= as.character(p6020), color = as.factor(p6020))) +
           geom_point(size = 0.5)
graph_1

## añadir atributos a este objeto
graph_1 + scale_color_manual(values = c("2"="red" , "1"="blue") , label = c("1"="Hombre" , "2"="Mujer") , name = "Sexo")


## **density chart:**
density <- filter(geih, !is.na(p6450) & inglabo < 1e+07 ) %>% 
           ggplot(data=. , mapping = aes(x = inglabo, group = as.factor(p6450), fill = as.factor(p6450))) + 
           geom_density() 
density

## se cambian los ejes
density <- density  + 
           scale_fill_discrete(label = c("1"="Verbal" , "2"="Escrito", "9"="No informa/Conoce") , name = "Contrato") + 
           labs(x = "Ingresos" , y = "",
                title = "Ingresos menores a 10 SLMV",
                subtitle = "Desagregados por tipo de contrato")
density


### **2.2 `group_by()` `+` `ggplot()`** 

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

##se cambian los ejes y el theme:
ingresos +
scale_fill_manual(values = c("2"="red" , "1"="blue") , label = c("1"="Hombre" , "2"="Mujer") , name = "Sexo") +
labs(x = "sexo") + 
theme_classic()



