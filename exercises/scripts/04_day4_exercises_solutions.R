# ============================================================
# EJERCICIOS - DIA 4 (versión SOLUCIÓN)
# Curso: Introducción a programación y análisis de datos en R
# Efraín García Sánchez & Filip Andras
# CIMCYC - Universidad de Granada
# ============================================================


# ============================================================
# 1. INSTALAR PAQUETES (solo la primera vez, luego comentar)
# ============================================================
# install.packages("tidyverse")    # manipulación de datos + ggplot2
# install.packages("afex")         # aov_ez() para ANOVA mixto y RM
# install.packages("emmeans")      # comparaciones post-hoc
# install.packages("effectsize")   # tamaño del efecto (eta cuadrado, Cohen's d)
# install.packages("car")          # leveneTest() para homogeneidad de varianzas
# install.packages("easystats")    # report() genera texto APA automáticamente
# install.packages("psych")        # describe() para descriptivos completos


# ============================================================
# 2. CARGAR LIBRERÍAS
# ============================================================
library(tidyverse)    # dplyr, tidyr, readr, ggplot2, stringr, etc.
library(afex)         # ANOVA robusto (aov_ez) con corrección GG automática
library(emmeans)      # comparaciones por pares después del ANOVA
library(effectsize)   # eta_squared(), cohens_d()
library(car)          # leveneTest() — homogeneidad de varianzas
library(easystats)    # incluye report(), performance, parameters
library(psych)        # describe() — descriptivos completos

# opciones globales
options(scipen = 999) # evitar notación científica


# ============================================================
# 3. CARGAR LOS DATOS PREPROCESADOS
# ============================================================
# Partimos del dataset que preparamos en Día 3, Bloque 1.

data_processed <- read_csv("data/processed_data/preprocessed_data.csv")

# echar un vistazo rápido
glimpse(data_processed)


# ============================================================
# BLOQUE 1 — Introducción conceptual al ANOVA
# ============================================================
# Bloque teórico: trabajamos con anova_by_hand.html.
# No hay ejercicios de código.


# ============================================================
# BLOQUE 2 — ANOVA de una vía: ejercicio guiado
# (Day4_bloque2, slides 6-17)
# ============================================================
# Pregunta: ¿Existen diferencias en ansiedad BASAL (pre)
# entre los tres grupos de tratamiento?
# Expectativa: NO rechazamos H0 (aleatorización).
# ============================================================

# --- Paso 1: Explorar datos ---
glimpse(data_processed)
data_processed |> count(group)


# --- Paso 2: Descriptivos por grupo ---
# media, desviación típica y n de anxiety_pre por grupo
descriptivos_pre <- data_processed |>
  summarise(
    media = mean(anxiety_pre),
    dt    = sd(anxiety_pre),
    n     = n(),
    .by   = group
  )
descriptivos_pre


# --- Paso 3: Visualizar los datos ---
# boxplot básico para comparar los tres grupos
boxplot(formula = anxiety_pre ~ group, data = data_processed)


# --- Paso 4: Escribir las hipótesis ---
# H0: mu_CBT = mu_pharm = mu_control
# H1: al menos un grupo difiere
# Expectativa: NO rechazamos H0 (datos basales, aleatorización)


# --- Paso 5: Ejecutar el ANOVA ---
# aov() ajusta el ANOVA de una vía
# formula = variable_dependiente ~ factor
modelo_aov <- aov(formula = anxiety_pre ~ group, data = data_processed)

# tabla resumen del ANOVA
summary(modelo_aov)


# --- Paso 6: Interpretar ---
# Si F pequeño y p > .05 → NO rechazamos H0
# → no hay evidencia de diferencias basales entre grupos
# → la aleatorización ha funcionado


# --- Paso 7a: Post-hoc ---
# comparaciones por pares con emmeans (corrección de Holm)
emm_pre <- emmeans(object = modelo_aov, specs = ~ group)
pairs(x = emm_pre, adjust = "holm")


# --- Paso 7b: Tamaño del efecto ---
# eta cuadrado (proporción de varianza explicada por el factor)
eta_squared(model = modelo_aov)


# --- Paso 8a: Normalidad de residuos ---
# histograma
hist(x = residuals(modelo_aov))

# QQ plot
qqnorm(y = residuals(modelo_aov))
qqline(y = residuals(modelo_aov), col = "red", lwd = 2)

# test formal
# H0: los residuos son normales
# si p > 0.05, no rechazamos la normalidad
shapiro.test(x = residuals(modelo_aov))


# --- Paso 8b: Homogeneidad de varianzas ---
# test de Levene
# H0: las varianzas son iguales
# si p > 0.05, no rechazamos la igualdad de varianzas
leveneTest(y = anxiety_pre ~ group, data = data_processed)


# --- Reportar resultados ---
# resumen automático en formato APA con el paquete report
report(x = modelo_aov)


# --- Ejercicio BONUS — anxiety_post (Day4_bloque2, slide ~19) ---
# Repite el mismo flujo, pero ahora con anxiety_post en vez de anxiety_pre.
# Aquí SÍ esperamos diferencias (efecto del tratamiento).

# descriptivos post-tratamiento
descriptivos_post <- data_processed |>
  summarise(
    media = mean(anxiety_post),
    dt    = sd(anxiety_post),
    n     = n(),
    .by   = group
  )
descriptivos_post

# boxplot
boxplot(formula = anxiety_post ~ group, data = data_processed)

# ANOVA post-tratamiento
modelo_post <- aov(formula = anxiety_post ~ group, data = data_processed)
summary(modelo_post)

# post-hoc: ¿qué grupos difieren?
emm_post <- emmeans(object = modelo_post, specs = ~ group)
pairs(x = emm_post, adjust = "holm")

# tamaño del efecto
eta_squared(model = modelo_post)

# reportar
report(x = modelo_post)


# ============================================================
# BLOQUE 3 — ANOVA de medidas repetidas y mixto
# (Day4_bloque3)
# ============================================================

# --- Preparar los datos: pivotar a formato largo ---
# una fila por medición (paciente × timepoint)
datos_largo <- data_processed |>
  select(patient_id, group, anxiety_pre, anxiety_post, anxiety_followup) |>
  pivot_longer(
    cols         = starts_with("anxiety"),
    names_to     = "timepoint",
    values_to    = "anxiety",
    names_prefix = "anxiety_"
  ) |>
  mutate(
    # ordenar los niveles cronológicamente
    timepoint = factor(timepoint, levels = c("pre", "post", "followup"))
  )

# verificar
head(datos_largo)
nrow(datos_largo)  # 300 pacientes x 3 timepoints = 900 filas


# --- Ejercicio 1 — RM ANOVA por grupo (Day4_bloque3, slide ~11) ---

# --- Grupo farmacológico ---

# 1. Filtrar los datos
pharm_largo <- datos_largo |>
  filter(group == "pharmacological")

# 2. Descriptivos por timepoint
pharm_largo |>
  summarise(
    media = mean(anxiety),
    dt    = sd(anxiety),
    n     = n(),
    .by   = timepoint
  )

# 3. Boxplot
boxplot(formula = anxiety ~ timepoint, data = pharm_largo)

# 4. RM ANOVA con afex::aov_ez()
modelo_rm_pharm <- aov_ez(
  id     = "patient_id",
  dv     = "anxiety",
  data   = pharm_largo,
  within = "timepoint"
)
modelo_rm_pharm

# 5. Post-hoc con emmeans y corrección de Holm
emm_pharm <- emmeans(object = modelo_rm_pharm, specs = ~ timepoint)
pairs(x = emm_pharm, adjust = "holm")


# --- Grupo control ---

# 1. Filtrar los datos
ctrl_largo <- datos_largo |>
  filter(group == "control")

# 2. Descriptivos por timepoint
ctrl_largo |>
  summarise(
    media = mean(anxiety),
    dt    = sd(anxiety),
    n     = n(),
    .by   = timepoint
  )

# 3. Boxplot
boxplot(formula = anxiety ~ timepoint, data = ctrl_largo)

# 4. RM ANOVA con afex::aov_ez()
modelo_rm_ctrl <- aov_ez(
  id     = "patient_id",
  dv     = "anxiety",
  data   = ctrl_largo,
  within = "timepoint"
)
modelo_rm_ctrl

# 5. Post-hoc con emmeans y corrección de Holm
emm_ctrl <- emmeans(object = modelo_rm_ctrl, specs = ~ timepoint)
pairs(x = emm_ctrl, adjust = "holm")


# --- ANOVA mixto (Day4_bloque3, slide ~20) ---
# combina el factor within (timepoint) + el factor between (group)
modelo_mixto <- aov_ez(
  id      = "patient_id",
  dv      = "anxiety",
  data    = datos_largo,
  within  = "timepoint",
  between = "group"
)
modelo_mixto

# gráfico de interacción con emmip()
emmip(object = modelo_mixto, formula = group ~ timepoint, CIs = TRUE)

# efectos simples: efecto del tiempo DENTRO de cada grupo
emm_within_group <- emmeans(object = modelo_mixto, specs = ~ timepoint | group)
pairs(x = emm_within_group, adjust = "holm")

# comparar los tres grupos EN CADA timepoint
emm_between_time <- emmeans(object = modelo_mixto, specs = ~ group | timepoint)
pairs(x = emm_between_time, adjust = "holm")


# --- Ejercicio 2 — ANOVA mixto con depresión (Day4_bloque3, slide ~28) ---

# 1. Pivotar las columnas de depresión a formato largo
dep_largo <- data_processed |>
  select(patient_id, group,
         depression_pre, depression_post, depression_followup) |>
  pivot_longer(
    cols         = starts_with("depression"),
    names_to     = "timepoint",
    values_to    = "depression",
    names_prefix = "depression_"
  ) |>
  mutate(timepoint = factor(timepoint, levels = c("pre", "post", "followup")))

# verificar estructura
dep_largo |> count(group, timepoint)

# 2. ANOVA mixto para depresión
modelo_dep <- aov_ez(
  id      = "patient_id",
  dv      = "depression",
  data    = dep_largo,
  within  = "timepoint",
  between = "group"
)
modelo_dep

# 3. Gráfico de interacción
emmip(object = modelo_dep, formula = group ~ timepoint, CIs = TRUE)

# 4. Efectos simples: comparaciones por timepoint dentro de cada grupo
emm_dep <- emmeans(object = modelo_dep, specs = ~ timepoint | group)
pairs(x = emm_dep, adjust = "holm")


# ============================================================
# SESSION INFO
# ============================================================
sessionInfo()
