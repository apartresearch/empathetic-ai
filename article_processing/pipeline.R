pacman::p_load(tidyverse, lubridate, bibliometrix, stringr, bibtex)
setwd(dirname(parent.frame(2)$ofile))

###############################################################################
# Remove the ScienceDirect keyword-only matches
sd <- read_csv("../articles/ScienceDirect.csv")
sd <- sd %>% 
  mutate(
    `Title` = str_remove_all(str_to_lower(`Title`), r'[^\\w\\s ]'),
    `Abstract Note` = str_remove_all(str_to_lower(`Abstract Note`), r'[^\\w\\s ]')
  )

nrow(sd)

sd <- sd %>% 
  filter(str_detect(`Title`, "empat*") & str_detect(`Title`, '(artificial intelligence)|(machine learning)|robot|chatbot|avatar|(deep learning)|android') | str_detect(`Abstract Note`, "empat*")& str_detect(`Abstract Note`, '(artificial intelligence)|(machine learning)|robot|chatbot|avatar|(deep learning)|android') )

sd %>% write_csv("../articles/ScienceDirect.csv")

###############################################################################
# Get articles from manual searches
df <- read_csv("../articles/WoS.csv") %>% 
  rbind(read_csv("../articles/ScienceDirect.csv")) %>% 
  rbind(read_csv("../articles/ACM.csv")) %>% 
  rbind(read_csv("../articles/Xplore.csv")) %>% 
  rbind(read_csv("../articles/WorldCat.csv")) %>%
  rbind(read_csv("../articles/Scopus.csv"))

changeLog <- c(nrow(df))

###############################################################################
# Remove un-needed categories
df <- df %>%
  filter(`Item Type` %in% c("journalArticle", "conferencePaper"))

changeLog[2] <- nrow(df)

###############################################################################
# Remove duplicates [no spaces, no punctuation]
df <- df %>% 
  mutate(
    `Title Duplicate` = str_replace_all(str_remove_all(str_to_lower(`Title`), '[^\\w\\s]'), fixed(" "), "")
  ) %>% 
  distinct(`Title Duplicate`, .keep_all = TRUE)

df <- df %>% 
  filter(!(Title%in% c("Design of Counseling Robot for production by 3D printer",
                      "Learning Human Behavior for Emotional Body Expression in Socially Assistive Robotics",
                      "The PAUL Suit (c): an experience of ageing",
                      "A Social Robot System for Modeling Children's Word Pronunciation")))

changeLog[3] <- nrow(df)

###############################################################################
# Remove all with Survey/Review in the title
df <- df %>% 
  filter(
    !str_detect(str_to_lower(`Title`), "survey|review")
  )

changeLog[4] <- nrow(df)


###############################################################################
# Run the keyword analysis

df <- df %>% 
  mutate(
    `TA Keyword` = str_remove_all(str_to_lower(paste(`Title`, `Abstract Note`)), '[^\\w\\s]')
  ) %>% 
  filter(
    str_detect(`TA Keyword`, "adults|children|evaluation|experiment|investigated|participants|rated|quanitative|effect|statistically significant|manipulation|stimulus|results|users|task|evaluated|data|evidence-driven|voluntary|measured|qualitative|questionnaire|ANOVA|correlates| experimental|survey|laboratory|hypotheses|participants"),
    str_detect(`TA Keyword`, "appraisal|perspective-
taking|emotional|emotion|behavior|behaviour|pro-social|feelings|affect|affective|reaction|interaction|companion|emotional cue|recognize emotion|perception of emotion|identify emotion|display of emotion|emotion judgment|emotional state|emotions displayed|emotional content|displaying emotion|emotional interpretation|stylised emotion|emotional information|emotional expression|expressing emotion|natural social interaction|perceived|subjective|matching features"),
    str_detect(`TA Keyword`, "model|displaying|display|body|language|evaluation|evaluate|express|expression|comments|design|capabilities|agents|response|communication|interaction|version|empathy requires|capabilities|real-world|conversation|improve|embodiment"),
    str_detect(`TA Keyword`, "deep learning|robot|humanoid|artificial agents|HRI|computing"),
    str_detect(`TA Keyword`, "empat*"))

changeLog[5] <- nrow(df)


###############################################################################
# Filter for page count

df <- str_split(df$Pages, "\\D") %>% as_tibble(.name_repair = "unique") %>% t %>% as_tibble %>% rename(Page1 = V1, Page2 = V2) %>% cbind(df) %>%
  mutate(
    `Num Pages` = if_else(Title %in% c("Empathic Chatbot Response for Medical Assistance",
                                       "Empathy in Middle School Engineering Design Process",
                                       "Akibot: A Telepresence Robot for Medical Teleconsultation",
                                       'Getting Virtually Personal: Making Responsible and Empathetic "Her" for Everyone',
                                       "Breathing expression for intimate communication corresponding to the physical distance and contact between human and robot"), 
                          3, as.numeric(Page2) - as.numeric(Page1) + 1)) %>% 
  filter(if_else(is.na(`Num Pages`), TRUE, `Num Pages` > 4))

changeLog[6] <- nrow(df)


###############################################################################
# Filter for English
df <- df %>% 
  mutate(Language = if_else(Title == "Evaluation study of a human-sized bipedal humanoid robot through a public demonstration in a science museum", "Korean", Language),
         Language = if_else(Title == "Empathic Computer Science: A Systematic Mapping", "Portuguese", Language)) %>% # Updating mis-classified language 
  filter(`Language` %in% c("English", NA))

changeLog[7] <- nrow(df)


names(changeLog) <- c("Start", "Filter for item type", "Filter duplicates", "Filter reviews", "Keyword filtering in title and abstract", "Filter page count above 4", "Filter English articles")

changeLog <- tibble(change=names(changeLog), nrow=changeLog)


# WRITE TITLE, URL, AND DOI TO FILE
df %>% 
  select("Title", "Url", "DOI") %>% 
  write_csv2("../articles/article_coding.csv")

# WRITE FILTERED ARTICLES TO BIBTEX FORMAT
df %>% 
  select(-c(Page1, Page2, `TA Keyword`, `Title Duplicate`)) %>% 
  write_csv2("../articles/complete_bibtex.csv")

# WRITE FILTERED ARTICLES TO FILE
write_csv2(df, "../articles/complete.csv")          


# WRITE CHANGE LOG
write_csv2(changeLog, "../articles/change_log.csv")
sink("../articles/change_log.txt")
for(i in 1:nrow(changeLog)) cat(paste(changeLog$change[i], ":", changeLog$nrow[i], "\n"))
sink()