pacman::p_load(rjson, tidyverse, rcrossref)

GetCitations <- function(DOI){
  if(!is.na(DOI)){
    tryCatch(expr = {
      api <- paste0("https://opencitations.net/index/coci/api/v1/citations/",DOI)
      rjson::fromJSON(file = api) %>% 
        lapply(function(x){
          x[['citing']]
        }) %>% 
        unlist %>% 
        length() %>% 
        return
    }, error = function(cond){return(NA)},
    finally = function(cond){return(NA)})
  } 
  else {
    return(NA)
  }
}

df <- read_csv("../articles/21-03-10-citations.csv")
citations <- c()

for (i in 1:nrow(df)) {
  message(paste("iteration:", i))
  citations <- c(citations, GetCitations(df$DOI[i]))
}

df2 <- df %>% 
  mutate(
    Citations = citations
  )

df2 %>% write_csv("../articles/21-03-10-citations-output.csv", na="")


