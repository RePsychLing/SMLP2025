# Sample Code - Simplified

library(lme4)

data_test <- read.csv("Cicek_Data_Frame.csv", 
                      fileEncoding = "UTF-8-BOM")

str(data_test)

# We strongly reommend to convert subject and item numbers to strings. For example:

library(dplyr)

data_test <- 
  data_test |> 
  mutate(
    subject = as_factor(paste0("S", str_pad(subject, width = 3, side = "left", pad = "0"))),
    item = as_factor(paste0("I", str_pad(item, width = 5, side = "left", pad = "0")))
  )

# We also recommend that contrasts are set explicitly. R's default setting to
# dummy coding is not very compatible with experimental designs such as this one.
# The recommendation would be contr.sum(). 

# Code revision reflects Douglas Bates's recommendation for default setting. 
summary(m1 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 | item) +
    (1 | subject),
  data = data_test,
  REML = TRUE, control=lmerControl(calc.derivs=FALSE)
))


# This model is overparameterized. See Julia HTML.
summary(m2 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 + evade + remnant | item) +
    (1 + evade + remnant | subject),
  data = data_test,
  REML = TRUE, control=lmerControl(calc.derivs=FALSE)
))

# This model is even more overparameterized. See Julia HTML.
summary(m3 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 + evade * remnant | item) +
    (1 + evade * remnant | subject),
  data = data_test,
  REML = TRUE, control=lmerControl(calc.derivs=FALSE)
))

anova(m1,m2,m3)

# In the Julia script I show a model m4 that is less complex than m2, 
# therefore supported by the data (i.e., not overparameterized), 
# and of same goodness of fit as m2.
