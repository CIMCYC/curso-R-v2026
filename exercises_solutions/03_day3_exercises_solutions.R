# ============================================================
# EJERCICIOS - DIA 3 (version SOLUCION)
# Curso: Introduccion a programacion y analisis de datos en R
# Efrain Garcia Sanchez & Filip Andras
# CIMCYC - Universidad de Granada
# ============================================================

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

# --- Limpiar environment y cargar paquetes ---
rm(list = ls())
library(tidyverse)
library(psych)
library(effectsize)
library(report)
options(scipen = 999, width = 120)

# --- Cargar datos ---
data_trial    <- read_csv("data/raw_data/data_clinical_trial.csv")
data_followup <- read_csv("data/raw_data/data_clinical_trial_followup.csv")


# --- CODIGO DE LA PRESENTACION (para referencia) -----

# summarise() --- calcular estadisticos
resumen_global <- data_trial |>
  summarise(
    media_ansiedad = mean(anxiety_pre, na.rm = TRUE),
    sd_ansiedad    = sd(anxiety_pre, na.rm = TRUE),
    n              = n()
  )
resumen_global

# group_by() + summarise() --- agrupar antes de resumir
resumen_por_grupo <- data_trial |>
  group_by(group) |>
  summarise(
    media_ansiedad = mean(anxiety_pre, na.rm = TRUE),
    sd_ansiedad    = sd(anxiety_pre, na.rm = TRUE),
    n              = n()
  )
resumen_por_grupo

# multiples variables de agrupacion
resumen_grupo_sexo <- data_trial |>
  group_by(group, sex) |>
  summarise(
    media_ansiedad = mean(anxiety_pre, na.rm = TRUE),
    .groups = "drop"
  )
resumen_grupo_sexo

# count() --- atajo para group_by + summarise(n = n())
conteo <- data_trial |>
  count(group, sex)
conteo

# pipeline completo (1): preprocesar
datos_preprocesados <- data_trial |>
  left_join(read_csv("data/raw_data/data_sites.csv"), by = "site_id") |>
  mutate(
    mejora = anxiety_pre - anxiety_post,
    cambio = if_else(mejora > 0, "mejora", "empeora"),
    gravedad_post = case_when(
      anxiety_post <= 4  ~ "minima",
      anxiety_post <= 9  ~ "leve",
      anxiety_post <= 14 ~ "moderada",
      .default           = "grave"
    )
  )
datos_preprocesados

# pipeline completo (2): resumir
datos_resumidos <- datos_preprocesados |>
  group_by(group, sex) |>
  summarise(
    mejora_media = round(mean(mejora), 1),
    .groups      = "drop"
  ) |>
  arrange(mejora_media)
datos_resumidos

# write_csv() --- exportar
# sin pipe
write_csv(datos_preprocesados, "data/processed_data/preprocessed_data.csv")
# con pipe
datos_preprocesados |>
  write_csv("data/processed_data/preprocessed_data.csv")


# ------------------------------------------------------------
# Ejercicio 1 — practicar group_by() + summarise()
# (Bloque 1, slide ~11)
# ------------------------------------------------------------

# 1. limpia tu environment
rm(list = ls())

# 2. carga paquetes
library(tidyverse)

# 3. carga datos
data_trial    <- read_csv("data/raw_data/data_clinical_trial.csv")
data_followup <- read_csv("data/raw_data/data_clinical_trial_followup.csv")

# 4. depresion pre y post por grupo y sexo
resumen_depresion <- data_trial |>
  group_by(group, sex) |>
  summarise(
    media_pre    = mean(depression_pre, na.rm = TRUE),
    media_post   = mean(depression_post, na.rm = TRUE),
    n            = n(),
    .groups      = "drop"
  ) |>
  mutate(cambio = media_pre - media_post) |>
  arrange(desc(cambio))
resumen_depresion

# 4. alternativa: todo dentro de summarise
resumen_depresion <- data_trial |>
  group_by(group, sex) |>
  summarise(
    media_cambio = mean(depression_pre - depression_post, na.rm = TRUE),
    n            = n(),
    .groups      = "drop"
  ) |>
  arrange(desc(media_cambio))
resumen_depresion

# 5. mediana de sesiones por grupo
sesiones_por_grupo <- data_trial |>
  group_by(group) |>
  summarise(mediana_sesiones = median(n_sessions, na.rm = TRUE))
sesiones_por_grupo

# 6. bienestar medio por sexo (pre, post y followup)
bienestar_por_sexo <- data_trial |>
  left_join(data_followup, by = "patient_id") |>
  group_by(sex) |>
  summarise(
    media_pre      = mean(wellbeing_pre, na.rm = TRUE),
    media_post     = mean(wellbeing_post, na.rm = TRUE),
    media_followup = mean(wellbeing_followup, na.rm = TRUE)
  )
bienestar_por_sexo


# ------------------------------------------------------------
# Ejercicio 2 — construye tu pipeline de preprocesado
# (Bloque 1, slide ~21)
# ------------------------------------------------------------

# 1. cargar sites
sites <- read_csv("data/raw_data/data_sites.csv")

# 2. unir data_trial con data_followup y sites
datos_preprocesados <- data_trial |>
  left_join(data_followup, by = "patient_id") |>
  left_join(sites, by = "site_id")

# 3. crear variable mejora
datos_preprocesados <- datos_preprocesados |>
  mutate(
    mejora = anxiety_pre - anxiety_post,
    cambio = if_else(mejora > 0, "mejora", "empeora"),
    gravedad_post = case_when(
      anxiety_post <= 4  ~ "minima",
      anxiety_post <= 9  ~ "leve",
      anxiety_post <= 14 ~ "moderada",
      .default           = "grave"
    )
  )

# 6. contar mejoran vs empeoran por grupo
datos_preprocesados |> count(group, cambio)

# 7. guardar datos preprocesados
write_csv(datos_preprocesados, "data/processed_data/preprocessed_data.csv")


# ============================================================
# BLOQUE 2 — pivot_longer() y pivot_wider()
# (Day3_bloque2)
# ============================================================

# --- CODIGO DE LA PRESENTACION (para referencia) -----

# toy example: formato ancho
ancho <- data.frame(
  paciente  = 1:4,
  gad7_pre  = c(14, 11, 17, 9),
  gad7_post = c(8, 7, 11, 5)
)
ancho

# pivot_longer(): de ancho a largo
largo <- ancho |>
  pivot_longer(
    cols      = c(gad7_pre, gad7_post),
    names_to  = "momento",
    values_to = "gad7"
  )
largo

# pivot_wider(): de largo a ancho
largo |>
  pivot_wider(
    names_from  = "momento",
    values_from = "gad7"
  )

# pivot_longer con datos del ensayo
trial_ancho <- datos_preprocesados |>
  select(patient_id, group, anxiety_pre, anxiety_post) |>
  slice_head(n = 8)
trial_ancho

trial_largo <- trial_ancho |>
  pivot_longer(
    cols      = c(anxiety_pre, anxiety_post),
    names_to  = "momento",
    values_to = "anxiety"
  )
trial_largo

# pivot_wider: tabla comparativa
library(knitr)
tabla_comparativa <- datos_preprocesados |>
  group_by(group) |>
  summarise(
    pre     = round(mean(anxiety_pre), 1),
    post    = round(mean(anxiety_post), 1),
    .groups = "drop"
  ) |>
  mutate(mejora = pre - post) |>
  arrange(desc(mejora))
tabla_comparativa


# ------------------------------------------------------------
# Ejercicio 3 — tu primer pivot_longer()
# (Bloque 2, slide ~11)
# ------------------------------------------------------------

datos_ancho <- tibble::tibble(
  paciente = 1:3,
  dia_1    = c(10, 8, 12),
  dia_2    = c(7, 6, 9),
  dia_3    = c(5, 4, 7)
)
datos_ancho

datos_largo <- datos_ancho |>
  pivot_longer(
    cols      = c(dia_1, dia_2, dia_3),
    names_to  = "dia",
    values_to = "puntuacion"
  )
datos_largo
nrow(datos_largo)  # 9 filas (3 pacientes x 3 dias)


# ------------------------------------------------------------
# Ejercicio 4 — reestructurar datos de bienestar con seguimiento
# (Bloque 2, slide ~18)
# ------------------------------------------------------------

wellbeing_largo <- datos_preprocesados |>
  select(patient_id, group,
         wellbeing_pre, wellbeing_post, wellbeing_followup) |>
  pivot_longer(
    cols      = starts_with("wellbeing"),
    names_to  = "momento",
    values_to = "wellbeing",
    names_prefix = "wellbeing_"
  ) |>
  mutate(momento = factor(momento, levels = c("pre", "post", "followup")))
wellbeing_largo

nrow(wellbeing_largo)  # 900 filas (300 pacientes x 3 momentos)

# bonus: media por grupo y momento
wellbeing_largo |>
  group_by(group, momento) |>
  summarise(
    media = mean(wellbeing, na.rm = TRUE),
    .groups = "drop"
  )


# ============================================================
# BLOQUE 3 — Estadistica descriptiva, normalidad, correlacion
# (Day3_bloque3)
# ============================================================

# --- Partimos del dataset procesado ---
data_processed <- read_csv("data/processed_data/preprocessed_data.csv")

# --- CODIGO DE LA PRESENTACION (para referencia) -----

# estadisticos basicos
mean(data_processed$anxiety_pre, na.rm = TRUE)
sd(data_processed$anxiety_pre, na.rm = TRUE)
summary(data_processed$anxiety_pre)
describe(data_processed$anxiety_pre)

# descriptivos por grupo
descriptivos_grupo <- data_processed |>
  group_by(group) |>
  summarise(
    media  = round(mean(anxiety_post), 2),
    dt     = round(sd(anxiety_post), 2),
    minimo = min(anxiety_post),
    maximo = max(anxiety_post),
    n      = n()
  )
descriptivos_grupo

# histograma + boxplot
hist(data_processed$anxiety_pre)
boxplot(anxiety_post ~ group, data = data_processed)

# comprobar normalidad (histogramas)
par(mfrow = c(1, 2))
hist(data_processed$anxiety_post)
hist(data_processed$wellbeing_post)
par(mfrow = c(1, 1))

# comprobar normalidad (Shapiro-Wilk)
shapiro.test(x = data_processed$anxiety_post)
shapiro.test(x = data_processed$wellbeing_post)

# correlacion de Pearson
cor.test(x = data_processed$anxiety_post,
         y = data_processed$wellbeing_post,
         method = "pearson")

# report
cor_result <- cor.test(x = data_processed$anxiety_post,
                       y = data_processed$wellbeing_post)
report(x = cor_result)

# matriz de correlaciones
library(sjPlot)
data_processed |>
  select(anxiety_pre, depression_pre, wellbeing_pre, loneliness_pre, self_esteem_pre) |>
  tab_corr(triangle = "lower")

# regresion lineal
cbt <- data_processed |> filter(group == "CBT")
modelo_simple <- lm(formula = anxiety_post ~ n_sessions, data = cbt)
summary(modelo_simple)
plot(cbt$n_sessions, cbt$anxiety_post)
abline(modelo_simple)
performance::check_model(modelo_simple)
report(x = modelo_simple)

# regresion multiple
modelo_multiple <- lm(formula = anxiety_post ~ n_sessions + age, data = cbt)
summary(modelo_multiple)


# ------------------------------------------------------------
# Ejercicio 5 — descriptivos por grupo
# (Bloque 3, slide ~8)
# ------------------------------------------------------------

descriptivos_grupo_sexo <- data_processed |>
  group_by(group, sex) |>
  summarise(
    media   = round(mean(anxiety_post), 2),
    mediana = median(anxiety_post),
    dt      = round(sd(anxiety_post), 2),
    n       = n(),
    .groups = "drop"
  )
descriptivos_grupo_sexo


# ------------------------------------------------------------
# Ejercicio 6 — cuartiles y rango intercuartilico
# (Bloque 3, slide ~10)
# ------------------------------------------------------------

median(data_processed$anxiety_pre)
quantile(data_processed$anxiety_pre, probs = c(0.25, 0.75))
IQR(data_processed$anxiety_pre)


# ------------------------------------------------------------
# Ejercicio 6b — histograma + boxplot: pre vs post
# (Bloque 3, slide ~12)
# ------------------------------------------------------------

par(mfrow = c(2, 2))
hist(data_processed$anxiety_pre)
boxplot(data_processed$anxiety_pre, horizontal = TRUE)
hist(data_processed$anxiety_post)
boxplot(data_processed$anxiety_post, horizontal = TRUE)
par(mfrow = c(1, 1))


# ------------------------------------------------------------
# Ejercicio 7 — correlacion de Spearman
# (Bloque 3, slide ~26)
# ------------------------------------------------------------

cor.test(x = data_processed$anxiety_post,
         y = data_processed$wellbeing_post,
         method = "spearman")


# ------------------------------------------------------------
# Ejercicio 8 — correlacion edad y ansiedad
# (Bloque 3, slide ~29)
# ------------------------------------------------------------

hist(data_processed$age)
shapiro.test(x = data_processed$age)

cor.test(x = data_processed$age,
         y = data_processed$anxiety_post,
         method = "spearman")

cor_age <- cor.test(x = data_processed$age,
                    y = data_processed$anxiety_post,
                    method = "spearman")
report(x = cor_age)

plot(data_processed$age, data_processed$anxiety_post)


# (Ejercicio de regresion -> movido a Day 4)


# ============================================================
# SESSION INFO
# ============================================================
sessionInfo()
