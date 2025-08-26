# Sample Code - Simplified

library(lme4)

data_test <- read.csv("Cicek_Data_Frame.csv", 
                      fileEncoding = "UTF-8-BOM")

str(data_test)

summary(m1 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 | item) +
    (1 | subject),
  data = data_test,
  REML = FALSE
))


summary(m2 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 + evade + remnant | item) +
    (1 + evade + remnant | subject),
  data = data_test,
  REML = FALSE
))


summary(m3 <- lmerTest::lmer(
  z_score ~ evade * remnant +
    (1 + evade * remnant | item) +
    (1 + evade * remnant | subject),
  data = data_test,
  REML = FALSE
))

anova(m1,m2,m3)
