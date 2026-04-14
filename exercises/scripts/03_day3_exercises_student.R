# ============================================================
# EJERCICIOS - DIA 3 (version ESTUDIANTE)
# Curso: Introduccion a programacion y analisis de datos en R
# Efrain Garcia Sanchez & Filip Andras
# CIMCYC - Universidad de Granada
# ============================================================
#
# Como usar este script:
#   1. Lee el enunciado de cada ejercicio (lineas comentadas).
#   2. Escribe tu codigo donde dice "# TU_CODIGO_AQUI".
#   3. Las soluciones se muestran en la presentacion.

# --- Instalar paquetes (solo la primera vez, luego comentar) ---
# install.packages("tidyverse")
# install.packages("psych")
# install.packages("sjPlot")
# install.packages("effectsize")
# install.packages("report")


# ============================================================
# BLOQUE 1 — group_by() + summarise(), pipelines, write_csv()
# (Day3_bloque1)
# ============================================================

# ------------------------------------------------------------
# Ejercicio 1 — practicar group_by() + summarise()
# (Bloque 1, slide ~11)
# Tiempo: 20 minutos
# ------------------------------------------------------------
#
# 1. Limpia tu environment (rm(list = ls())) + Cmd/Ctrl + Shift + 0
# 2. Carga los paquetes necesarios
# 3. Carga los datos (data_trial, data_followup)
# 4. Calcula la media de depression_pre y depression_post y n()
#    por grupo Y sexo. Que combinacion muestra mayor cambio?
# 5. Que grupo tiene la mediana mas alta de numero de sesiones (n_sessions)?
#    Recuerda na.rm = TRUE
# 6. Como se compara el bienestar medio (wellbeing_pre, wellbeing_post,
#    wellbeing_followup) entre hombres y mujeres?

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 2 — construye tu pipeline de preprocesado
# (Bloque 1, slide ~21)
# Tiempo: 20 minutos
# ------------------------------------------------------------
#
# Los datos ya estan cargados (data_trial, data_followup)
#
# 1. Carga sites con read_csv()
# 2. Une data_trial con data_followup (por patient_id) y con sites (por site_id)
# 3. Crea una variable mejora = anxiety_pre - anxiety_post
#    y otra mejora_followup = anxiety_pre - anxiety_followup
# 4. Clasifica la mejora con if_else(): "mejora" si mejora > 0, "empeora" si no
# 5. Clasifica la gravedad post con case_when()
#    (GAD-7: <= 4 minima, <= 9 leve, <= 14 moderada, resto grave)
# 6. Cuenta cuantos pacientes mejoran vs empeoran por grupo (count())
# 7. Guarda los datos preprocesados - que funcion necesitas? en que carpeta?
#
# Opcional: renombra rosenberg -> self_esteem y ucla -> loneliness
#           (pre, post Y followup), reordena followup despues de post

# TU_CODIGO_AQUI



# ============================================================
# BLOQUE 2 — pivot_longer() y pivot_wider()
# (Day3_bloque2)
# ============================================================

# ------------------------------------------------------------
# Ejercicio 3 — tu primer pivot_longer()
# (Bloque 2, slide ~11)
# Tiempo: 5 minutos
# ------------------------------------------------------------
#
# Tienes este tibble en formato ancho:
datos_ancho <- tibble::tibble(
  paciente = 1:3,
  dia_1    = c(10, 8, 12),
  dia_2    = c(7, 6, 9),
  dia_3    = c(5, 4, 7)
)
# 1. Usa pivot_longer() para convertirlo a formato largo
#    (columnas dia_* -> "dia" y valores -> "puntuacion")
# 2. Cuantas filas tiene el resultado?

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 4 — reestructurar datos de bienestar con seguimiento
# (Bloque 2, slide ~18)
# Tiempo: 20 minutos
# ------------------------------------------------------------
#
# Usamos los datos preprocesados del bloque anterior
# (data/processed_data/preprocessed_data.csv)
#
# 1. Carga los datos preprocesados
# 2. Selecciona patient_id, group, wellbeing_pre, wellbeing_post, wellbeing_followup
# 3. Usa pivot_longer() para crear formato largo (momento y wellbeing)
#    Pista: usa names_prefix = "wellbeing_"
# 4. Ordena los niveles con factor(momento, levels = c("pre", "post", "followup"))
# 5. Cuantas filas tiene el resultado?
# 6. Bonus: media de wellbeing por group y momento

# TU_CODIGO_AQUI


# ============================================================
# BLOQUE 3 — Estadistica descriptiva, normalidad, correlacion
# (Day3_bloque3)
# ============================================================

# --- Partimos del dataset procesado ---
# data_processed <- read_csv("data/processed_data/preprocessed_data.csv")


# ------------------------------------------------------------
# Ejercicio 5 — descriptivos por grupo
# (Bloque 3, slide ~10)
# Tiempo: 10 minutos
# ------------------------------------------------------------
#
# 1. Elige una variable dependiente (ansiedad, depresion, bienestar,
#    autoestima o soledad)
# 2. Calcula una medida de tendencia central y una de dispersion,
#    mas el n(), agrupados por group y sex, para el momento
#    de tratamiento que quieras (pre/post/followup)
# 3. Hay diferencias entre hombres y mujeres dentro de cada grupo?

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 6 — cuartiles y rango intercuartilico
# (Bloque 3, slide ~12)
# Tiempo: 5 minutos
# ------------------------------------------------------------
#
# Para anxiety_pre, calcula:
# 1. Mediana
# 2. Q1 y Q3 con quantile(probs = c(0.25, 0.75))
# 3. IQR

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 6b — histograma + boxplot: pre vs post
# (Bloque 3, slide ~14)
# ------------------------------------------------------------
# Crea histogramas y boxplots de anxiety_pre y anxiety_post

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 7 — correlacion de Spearman
# (Bloque 3, slide ~26)
# Tiempo: 2 minutos
# ------------------------------------------------------------
#
# Usa ?cor o busca en internet: que argumento hay que cambiar
# en cor() para calcular Spearman en vez de Pearson?

# TU_CODIGO_AQUI


# ------------------------------------------------------------
# Ejercicio 8 — correlacion edad y ansiedad
# (Bloque 3, slide ~29)
# Tiempo: 5 minutos
# ------------------------------------------------------------
#
# 1. Visualiza la distribucion de age con hist()
# 2. Comprueba la normalidad de age con shapiro.test()
# 3. Es normal? Que tipo de correlacion debemos usar?
# 4. Calcula la correlacion entre age y anxiety_post
# 5. Genera el resumen APA con report()

# TU_CODIGO_AQUI


# ============================================================
# SESSION INFO
# ============================================================
sessionInfo()
