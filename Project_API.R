### Matt Kurtz
### Lecture 24: A Short Introduction to Exploratory Data Mining


# Packages ----------------------------------------------------------------
if(require(pacman)==FALSE) install.packages("pacman")
pacman::p_load(tidyverse,
               jsonlite,
               lubridate,
               locale)


# TMDB API ----------------------------------------------------------------
API_Documentation = "https://dev.to/m0nica/how-to-use-the-tmdb-api-to-find-films-with-the-highest-revenue-82p"

api_key = 'cfc120466656431c8b5062d711ef05c9'
api_url = paste0('https://api.themoviedb.org/3/discover/movie?api_key=',
                 api_key,
                 '&primary_release_year=&sort_by=revenue.desc')
TBDB_json = fromJSON(api_url)

TBDB_json$results$title # Titles of 20 highest grossing movies