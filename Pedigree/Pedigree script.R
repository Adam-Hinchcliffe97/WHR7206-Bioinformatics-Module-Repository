
install.packages("kinship2")
library(kinship2)

# Define individuals
id      <- c("Dad", "Mom", "Sister", "Son")
dadid   <- c(NA, NA, "Dad", "Dad")
momid   <- c(NA, NA,"Mom", "Mom")
sex     <- c(1, 2, 2, 1)      # 1 = male, 2 = female
affected <- c(0, 0, 0, 1)     # Son affected

ped <- pedigree(id=id, dadid=dadid, momid=momid, sex=sex, affected=affected)
plot(ped)

#create a jpeg
jpeg("pedigree.jpeg", width = 400, height = 400, quality = 100)
plot(ped)
dev.off()