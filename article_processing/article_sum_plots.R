library(tidyverse, ggplot2, gridExtra)

try(
  setwd(paste0(getwd(), "/../articles"))
)


# Plotting
p1 <- f3 %>% ggplot() +
  aes(`Publication Year`, fill=`Item Type`) +
  geom_histogram(binwidth=1) +
  theme_minimal() +
  labs(title="Article amount by year", x="",y="")

p2 <- f3 %>% mutate(
  `Have PDF`= !is.na(`File Attachments`)
  ) %>%
  select(`Have PDF`, everything()) %>% 
  ggplot() +
  aes(x=`Have PDF`, fill=`Have PDF`) +
  geom_bar() +
  theme_minimal() +
  labs(title="Have PDFs", y="", x="")

p3 <- f3 %>%
  select(Database) %>% 
  count(Database, sort=T) %>%
  arrange(n) %>% 
  ggplot() +
  aes(x=n, y=reorder(Database, n)) +
  geom_col() +
  theme_minimal() +
  labs(title="From each database", y="", x="") +
  theme(legend.position = "none")

tags <- f3 %>% mutate(`Split Tags` = str_to_lower(`Automatic Tags`) %>%  str_split("\\s?;\\s?")) %>% 
  select(`Split Tags`) %>% 
  unnest(cols=c(`Split Tags`)) %>% 
  count(`Split Tags`, sort=T)

p4 <- tags %>% 
  slice(2:11) %>% 
  arrange(n) %>%
  ggplot() +
  aes(x=n, y=reorder(`Split Tags`, n)) +
  geom_col() +
  theme_minimal() +
  labs(title="Occurrence of automatic tags", y="", x="") +
  theme(legend.position = "none")

gridExtra::grid.arrange(p2, p1, p3, p4, ncol=2, widths=c(c(0.4,0.6)))


