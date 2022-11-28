### Group 9: Matt Kurtz and Riann Yates-Miller
### ISA401 Group Project: Movie Visualizations


## Packages ----------------------------------------------------------------
if(require(pacman)==FALSE) install.packages('pacman')
pacman::p_load(tidyverse, rvest, lubridate, httr, openxlsx)


## IMBD --------------------------------------------------------------------
imbd = 'https://www.imdb.com/search/title/?user_rating=1.0,5.0&groups=bottom_100,bottom_250,bottom_1000&adult=include&sort=moviemeter,desc&count=250&view=advanced'
imbd_s1 = read_html(imbd)
# Title
  imbd_title_s2 = html_elements(x = imbd_s1, css = '#main > div > div.lister.list.detail.sub-list > div > div > div.lister-item-content > h3 > a')
  imbd_title_s3 = html_text2(imbd_title_s2)
# Year
  imbd_yr_s2 = html_elements(x = imbd_s1, css = 'span.lister-item-year.text-muted.unbold')
  imbd_yr_s3 = html_text2(imbd_yr_s2)
  imbd_yr_s3 = str_extract_all(imbd_yr_s3, pattern = '[:digit:]{4}')
  # Need to convert to date in Excel
# Duration
  imbd_dur_s2 = html_elements(x = imbd_s1, css = '#main > div > div.lister.list.detail.sub-list > div > div > div.lister-item-content > p:nth-child(2) > span.runtime')
  imbd_dur_s3 = html_text2(imbd_dur_s2) # also wanna get rid of minutes to do analysis
  imbd_dur_s3 = str_remove(imbd_dur_s3, pattern = ' min')
  imbd_dur_s3 = as.numeric(imbd_dur_s3)
  # Need to convert to integer in Excel
# Genre
  imbd_gen_s2 = html_elements(x = imbd_s1, css = '#main > div > div.lister.list.detail.sub-list > div > div > div.lister-item-content > p:nth-child(2) > span.genre')
  imbd_gen_s3 = html_text2(imbd_gen_s2) #may be multiple genres, how should we deal with that
  # We need to convert this to factors?? Possibly?
# Rating
  imbd_rate_s2 = html_elements(x = imbd_s1, css = '#main > div > div.lister.list.detail.sub-list > div > div > div.lister-item-content > div > div.inline-block.ratings-imdb-rating > strong')
  imbd_rate_s3 = html_text2(imbd_rate_s2)
# Putting it all together
  imbd_tbl = tibble(Title = imbd_title_s3,
                    Year = imbd_yr_s3,
                    Duration = imbd_dur_s3,
                    Genre = imbd_gen_s3,
                    Rating = imbd_rate_s3)


## Rotten Tomatoes ---------------------------------------------------------
rotten = 'https://editorial.rottentomatoes.com/guide/worst-movies-of-all-time/'
rotten_s1 = read_html(rotten)
# Title
  rotten_title_s2 = html_elements(x = rotten_s1, css = 'div.col-sm-18.col-full-xs.countdown-item-content > div.row.countdown-item-title-bar > div.col-sm-20.col-full-xs > div > div > h2 > a')
  rotten_title_s3 = html_text2(rotten_title_s2)
# Year
  rotten_yr_s2 = html_elements(x = rotten_s1, css = 'div.col-sm-18.col-full-xs.countdown-item-content > div.row.countdown-item-title-bar > div.col-sm-20.col-full-xs > div > div > h2 > span.subtle.start-year')
  rotten_yr_s3 = html_text2(rotten_yr_s2)
# Critic Rating (!!!wrong!!!)
  rotten_crit_s2 = html_elements(x = rotten_s1, css = 'div.col-sm-18.col-full-xs.countdown-item-content > div.row.countdown-item-title-bar > div.col-sm-20.col-full-xs > div > div > h2 > span:nth-child(5)')
  rotten_crit_s3 = html_text2(rotten_crit_s2)
# Critic Consensus
  rotten_critcon_s2 = html_elements(x = rotten_s1, css = 'div.col-sm-18.col-full-xs.countdown-item-content > div.row.countdown-item-details > div > div.info.critics-consensus')
  rotten_critcon_s3 = html_text2(rotten_critcon_s2)
# Putting it all together
  rotten_tbl = tibble(Title = rotten_title_s3,
                      Year = rotten_yr_s3, 
                      CriticRating = rotten_crit_s3,
                      CriticConsensus= rotten_critcon_s3)
# Extracting the unnecessary elements
  rotten_tbl$Year = str_extract_all(rotten_tbl$Year, pattern = '[:digit:]{4}')
  rotten_tbl$CriticConsensus = str_remove(rotten_tbl$CriticConsensus, pattern = 'Critics Consensus: ')
# Correcting the URLs
  rotten_title_s3[7] = 'Super Babies: Baby Geniuses 2'
  rotten_title_s3[25] = 'Highlander 2 The Quickening'
  rotten_title_s3[27] = 'Bolero 1984'
  rotten_title_s3[28] = 'Precious Cargo 2016'
  rotten_title_s3[37] = 'Master of Disguise'
  rotten_title_s3[50] = 'Kickin It Old School'
  rotten_title_s3[52] = 'Haunting of Molly Hartley'
  rotten_title_s3[55] = 'Jack and Jill 2011'
  rotten_title_s3[58] = 'Feardotcom 2002'
  rotten_title_s3[62] = 'Mod Squad'
  rotten_title_s3[64] = '1126175 House of the Dead'
  rotten_title_s3[71] = '1076097 Mchales Navy'
  rotten_title_s3[77] = 'Whole Ten Yards'
  rotten_title_s3[95] = 'Low Down Dirty Shame'
  rotten_title_s3 = str_remove_all(rotten_title_s3, "[[:punct:]]")
  rotten_title_s3 = str_replace_all(rotten_title_s3, pattern = ' ', 
                                    replacement = '_')
  print(rotten_title_s3)
  rotten_adds = tibble()
  for (i in rotten_title_s3) {
    rotten_prof_stem = 'https://www.rottentomatoes.com/m/'
    rotten_prof_mov = tolower(i)
    rotten_url = paste0(rotten_prof_stem, rotten_prof_mov)
    rotten_url <- GET(rotten_url, add_headers('user-agent' = 'Gov employment data scraper ([[yatesmrl@miamioh.edu]])'))
    rotprof_s1 = read_html(rotten_url)
    # Getting the genre
    rotprof_s2 = html_elements(rotprof_s1,
                               css = 'section.panel.panel-rt.panel-box.movie_info.media > div > div > ul > li:nth-child(2) > div.meta-value.genre')
    rotprof_s3 = html_text2(rotprof_s2)
    # Getting the runtime
    rotdur_s2 = html_elements(rotprof_s1,
                              css = 'section.panel.panel-rt.panel-box.movie_info.media > div > div > ul > li:nth-child(10) > div.meta-value > time')
    rotdur_s3 = html_text2(rotdur_s2)
    rotten_profile = tibble(Title = i, 
                            Genre = rotprof_s3, 
                            Duration = rotdur_s3)
    rotten_adds = rbind(rotten_adds, rotten_profile)
  }
  # So it works, but at what cost, there's some missing. So now I'm thinking I should undo the changes I made and try to do an if statement like if the Adds matches the original table append the extra info and if not make it null
  

## MovieData-API -----------------------------------------------------------
movie_tbl = read_csv('https://github.com/Kurtzm23/ISA401-FinalProject/raw/main/MovieAPIdata.csv')
# problems() --> row 1107, $$ is a character


## Wikipedia ---------------------------------------------------------------
wiki = 'https://en.wikipedia.org/wiki/List_of_biggest_box-office_bombs#cite_note-13'
wiki_s1 = read_html(wiki)
# Read table
  wiki_s2 = html_elements(x = wiki_s1, css = '#mw-content-text > div.mw-parser-output > table')
  wiki_s3 = html_table(wiki_s2, header = TRUE)[[1]]
# Taking away reference column and subheadings
  wiki_s3 = wiki_s3[-1, -7]
  colnames(wiki_s3)[5] = 'Nominal- Estimated Loss (millions)'
  colnames(wiki_s3)[6] = 'Adj. for Infaltion- Estimated Loss (millions)'
# Putting it all together
  wiki_tbl = wiki_s3


## Exporting to Excel ------------------------------------------------------
# Make sure Working Directory is set
movie_datasets <- list('IMDB Data' = imbd_tbl,
                   'Rotten Tomatoes Data' = rotten_tbl,
                   'Movie API' = movie_tbl,
                   'Wikipedia Data' = wiki_tbl)
write.xlsx(movie_datasets, file = 'Group_Project_Data.xlsx')
