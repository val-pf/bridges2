#### Bridges pt 2 data wrangling

library(tidyverse)
library(lubridate)


### want to match two datasets, old and new. 
### new data needs to be wrangled to match old format
### new data is 3 files


### read in old surveys data
surveys_old <- read_csv("data_clean/surveys_complete_77_89.csv")
## read_csv imports it as tibble
sur_old <- read.csv("data_clean/surveys_complete_77_89.csv",stringsAsFactors =TRUE)

summary(sur_old)

# (first)
## read in an clean new surveys data
surveys <- read_csv("data_raw/surveys_new.csv")
summary(surveys)
view(surveys)
str(surveys)
problems(surveys) ## ONLY works on _ functions (tibbles)
## ISSUE: dates are in wrong order
## ISSUE: row 19 col 6 has a problem (additional quotes, typo)

## How to use if else
x <- 1:10
ifelse(x > 6, "bigger than 6", "not bigger than 6")

surveys <- surveys %>% 
  mutate(hindfoot_length = ifelse(record_id == 16896, 19, hindfoot_length))

# mutate takes a column, does things to it, returns it
# ifelse says: if the record is this value, change it to 19, otherwise leave as is
problems(surveys) #fixed

surveys_clean <- surveys %>%
  rename(date = 'date (mm/dd/yyyy)') %>% #new name = old name
  mutate(date = mdy(date),
         year = year(date),
         month = month(date),
         day = day(date)) %>%
  select (-date) #removes date column
      
view(surveys_clean) #yay


## (second)
### read in an clean species data
species <- read_delim("data_raw/species_new.txt")
species <- read_delim("data_raw/species_new.txt", delim=" ", quote = '""')
#this has more arguments but does the same thing
view(species)
## ISSUE: genus and species are combined in species_name column
species_new <- species %>%
  separate(species_name, into = c("genus", "species"),
           sep = " ")
#separate also removes the old column, if not, remove = FALSE
colnames(species_new) %in% colnames(surveys_old)
#yay check


# (third)
## read in plots data
plots <- read_csv("data_raw/plots_new.csv")
# ISSUE: is wide, should be long
plots_new <- plots %>%
  pivot_longer(cols = everything(), 
               names_to = "plot_id",
               values_to = "plot_type") %>%
  mutate(plot_id = str_replace(plot_id, "Plot ",""))
#this takes column plot_id and removes the string Plot with nothing
view(plots_new)
str (plots_new) # still a string
plots_new$plot_id = as.numeric(plots_new$plot_id)
# or add plot_id = as.numeric(plot_id) to the mutate function


##### NOW put all 3 together #####
surveys_plots <- left_join(surveys_clean, plots_new, by = "plot_id")
view(surveys_plots)
surveys_plots_species <- left_join(surveys_plots, species_new,
                                   by = "species_id")
view(surveys_plots_species)
colnames(surveys_plots_species) %in% colnames(surveys_old)

#### combine new and old
surveys_complete <- bind_rows(surveys_old, surveys_plots_species)
view(surveys_complete)
