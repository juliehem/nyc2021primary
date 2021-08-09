library(readxl)    #read_excel()
library(stringr)    #str_split
library(dplyr)
library(rlang)    #isempty
library(tidyverse)    #ggplot, lubridate
library(memisc)


### -------------------------------- LOAD DATA ---------------------------------
# June2021Primary financials
nyc.donations <- read.csv('./project/data/nycelection/CFB2021primary.csv')
nyc.expenditures <- read.csv('./project/data/nycelection/2021_Expenditures.csv')
nyc.contributions <- read.csv('./project/data/nycelection/2021_Contributions.csv')
# nyc.payments <- read.csv('./project/data/nycelection/2021_payments.csv') - don't use this.
nyc.analysis <- read.csv('./project/data/nycelection/EC2021_FinancialAnalysis_2021_Stmt10.csv')

# NYC Census data by city council district - https://data.cityofnewyork.us/City-Government/Census-Demographics-at-the-NYC-City-Council-distri/ye4r-qpmp
# These need a ton of cleaning
# nyc.census <- read_excel('./project/data/nycelection/census_data.xlsx')
# nyc.census.csv <- read.csv('./project/data/nycelection/census_data.csv')

# Results
nyc.results <- read_excel('./project/data/nycelection/results.xlsx')



### ---------------------- CLEAN DATA / GET ID --------------------------------
## Candidate key - to get the candidate numbers from nyc.analysis and add to nyc.results
cand_key <- nyc.analysis %>%
  select(cand_name, cand_id)

## Adding candidate numbers to nyc.results
# name = nyc.results$cand[13]     # for testing function
convert.name <- function(name) {
  first_name <- head(str_split(name, ' ')[[1]],1)
  if (tail(str_split(name, ' ')[[1]],1) == "Jr." | tail(str_split(name, ' ')[[1]],1) == "Sr.") {
    name_split <- tail(str_split(name, ' ')[[1]],2)
    last_name <- paste(name_split[1], name_split[2], sep=" ")
    cat(paste(last_name, first_name, sep = ', '), '\n')
  } else {
    last_name <- tail(str_split(name, ' ')[[1]],1)
  }
  newname = paste(last_name, first_name, sep = ', ')
  return(newname)
}

### fill in cand_id into nyc.results
for (i in 1:nrow(nyc.results)) {
  x = grep(convert.name(nyc.results$cand[i]), cand_key$cand_name, ignore.case = TRUE)
  if (!is_empty(x)) {
    # cat(' match found', cand_key$cand_id[x], '\n')
    nyc.results$cand_id[i] = cand_key$cand_id[x]
  } else {
    cat(' XXX NO MATCH XXX ', '\n')
    nyc.results$cand_id[i] = as.integer("")
  }
}

### Check for missing values
# these are the remaining names. cycle through them to fix errors. 28 of them
missing.cand_id <- nyc.results %>% filter(is.na(cand_id) & cand != "Write-ins")
missing.cand_id.copy <- missing.cand_id
# Cycle thorugh missing candidates and look for just the last name. If only one result 
# found, then use it.
for (candidate in 1:nrow(missing.cand_id)) {
  x = grep(tail(str_split(missing.cand_id$cand[candidate], ' ')[[1]],1), cand_key$cand_name, ignore.case = T)
  # cat(missing.cand_id$cand[candidate], x, '\n')
  if (length(x) == 1) {
    nyc.results$cand_id[nyc.results$cand == missing.cand_id$cand[candidate]] <- cand_key$cand_id[x]
    cat(missing.cand_id$cand[candidate], x, ', key: ', cand_key$cand_id[x], '\n')
    cat('added.\n')
  }
}
# Check missing again
missing.cand_id <- nyc.results %>% filter(is.na(cand_id) & cand != "Write-ins") #now 18

# Manual entry of a few more:
nyc.results$cand_id[nyc.results$cand == 'Tiffany Johnson-Winbush'] <- 2412
nyc.results$cand_id[nyc.results$cand == 'Raymond Sanchez Jr.'] <- 2407
nyc.results$cand_id[nyc.results$cand == 'Rafael Salamanca Jr.'] <- 1902
nyc.results$cand_id[nyc.results$cand == 'Robert E. Cornegy Jr.'] <- 1267
nyc.results$cand_id[nyc.results$cand == 'Robert Ramos Jr.'] <- 2490
nyc.results$cand_id[nyc.results$cand == 'Alec Brook-Krasny'] <- 539
nyc.results$cand_id[nyc.results$cand == 'Donovan J. Richards Jr.'] <- 1190
nyc.results$cand_id[nyc.results$cand == 'Harold C. Miller Jr.'] <- 2491
nyc.results$cand_id[nyc.results$cand == 'John F. McBeth Sr.'] <- 2520
nyc.results$cand_id[nyc.results$cand == 'Theo Bruce Chino Tavarez'] <- 2412

# Still missing info for:
missing.cand_id <- nyc.results %>% filter(is.na(cand_id) & cand != "Write-ins") #now8

## Clean up name column to remove id
nyc.analysis <- nyc.analysis %>%
  mutate(cand_name = gsub("\\(.*", "",cand_name))

# Convert nyc.donations$OFFICECD to character from integer to match the same of contributons dataset
nyc.donations$OFFICECD <- as.character(nyc.donations$OFFICECD)
# class(nyc.donations$FILING) <- as.character(nyc.donations$FILING) - UNUSED
nyc.donations.nofiling <- nyc.donations %>% select(-FILING)
nyc.contributions.nofiling <- nyc.contributions %>% select(-FILING)
dif.contr <- anti_join(nyc.contributions.nofiling, nyc.donations.nofiling)

# Remove Refunds from contributions
refunds <- nyc.contributions %>%
  filter(nchar(REFUNDDATE) != 0) %>%
  select(NAME, DATE, AMNT) %>%
  mutate(AMNT = abs(AMNT))

contrib.cleaned <- anti_join(nyc.contributions, refunds) %>%
  filter(nchar(REFUNDDATE) == 0) %>%
  select(OFFICECD,
         RECIPID,
         RECIPNAME,
         FILING,
         REFNO,
         DATE,
         C_CODE,
         BOROUGHCD,
         CITY,
         STATE,
         ZIP,
         AMNT,
         PREVAMNT,
         PURPOSECD,
   )



### ----------------------------Initial EDA -----------------------------------

### ----------------------- MAYORAL RACE --------------------------------------
## Variables
mayor.ballot = c('Adams', 
                 'Wiley', 
                 'Garcia', 
                 'Yang', 
                 'Stringer', 
                 'Morales', 
                 'McGuire',
                 'Donovan',
                 'Foldenauer',
                 'Chang',
                 'Prince',
                 'Taylor',
                 'Wright'
)

## Looking at mayors
mayors.expend <- nyc.analysis %>%
  filter(office == 1 | office == 11) %>%
  filter(termnd == 'N') %>%
  select(-c(el_cycle, from_stmt, to_stmt,boro_dist)) %>%
  arrange(desc(net_expnd))

mayors.expend <- mayors.expend %>%
  filter(net_expnd != 0)

## plot mayoral candidate with dollars spent and final ranking
mayors.trimmed <- mayors.expend %>%
  select(cand_name, cand_id, cntrs_no, cntns_no, net_cntns, sml_no, sml_amt, net_expnd, max_no, max_amt) 
id.n.pc <- nyc.results %>%
  select(pc_1, cand_id)

mayor.results <- left_join(mayors.trimmed, id.n.pc, by = 'cand_id') %>%
  filter(!is.na(pc_1)) %>%
  mutate(rank = rank(desc(pc_1), na.last = T)) %>%
  arrange(rank) 
 
# As a bar plot
ggplot(data = mayor.results, aes(x  = cand_name, y = net_expnd, fill=rank)) + 
  geom_col() + 
  coord_flip() + 
  scale_fill_gradient2(low="blue", mid="yellow", high="red") + 
  labs(x = 'Candidate', y = 'Total Expenditures')

# By percentage
ggplot(data = mayor.results, aes(x  = cand_name, y = net_expnd, fill=pc_1)) + 
  geom_col() + 
  coord_flip() + 
  # scale_fill_gradient2(low="blue", mid="yellow", high="red") + 
  labs(x = 'Candidate', y = 'Total Expenditures')

# Point plot - Conclusion.  Spending a not might not lead to success, but not spending anything 
# might harm your chances
ggplot(data = mayor.results, aes(x  = net_expnd, y = pc_1)) + 
  geom_point() + 
  # scale_fill_gradient2(low="blue", mid="yellow", high="red") + 
  labs(x = 'Total Expenditures', y = 'Percentage of First Round Vote', title = 'Candidate Expenses vs. Resulting 1st round vote outcome')


### MAYOR'S FUNDRAISING
mayor.funds <- nyc.donations %>%
  filter(OFFICECD == 1 | OFFICECD == 11) %>%
  group_by(RECIPNAME, RECIPID) %>%
  summarise(fundraising = sum(AMNT)) %>%
  mutate(on_ballot = RECIPID %in% mayor.results$cand_id) %>%
  arrange(desc(on_ballot), desc(fundraising))

## Plotting funding vs drop-out or not
ggplot(mayor.funds, aes(x=0, y=fundraising, fill=on_ballot)) + 
  geom_dotplot(binaxis = 'y', stackdir = 'center')
# + geom_dotplot(aes(x=4784356.52, fill='TRUE', color='yellow'))  #attempting to point out Adams


### MAYOR'S FUNDRAISING TIME SERIES
mayor.funds.time <- nyc.donations %>%
  filter(OFFICECD == 1 | OFFICECD == 11) %>%
  select(AMNT, 
         PREVAMNT, 
         ZIP, 
         STATE, 
         CITY, 
         BOROUGHCD, 
         C_CODE, 
         NAME, 
         DATE, 
         FILING, 
         RECIPNAME, 
         RECIPID) %>%
  arrange(RECIPNAME, DATE) %>%
  mutate(as.Date(DATE, format='%m%d%Y'))

mayor.funds.time$DATE <- as.Date(mayor.funds.time$DATE, format='%m/%d/%Y')

mayor.funds.time <- mayor.funds.time %>%
  mutate(month = month(mayor.funds.time$DATE)) %>%
  mutate(week = week(mayor.funds.time$DATE))

mayor.funds.time <- nyc.donations %>%
  filter(OFFICECD == 1 | OFFICECD == 11) %>%
  select(AMNT, 
         PREVAMNT, 
         ZIP, 
         STATE, 
         CITY, 
         BOROUGHCD, 
         C_CODE, 
         NAME, 
         DATE, 
         FILING, 
         RECIPNAME, 
         RECIPID) %>%
  arrange(RECIPNAME, DATE) %>%
  mutate(DATE = as.Date(DATE, format='%m/%d/%Y')) %>%
  mutate(week = week(DATE), month() = month(DATE)) 

# ORGANIZE BY CANDIDATE
# all mayors with total fundraising, by on-ballet vs not - UNUSED
mayor.cand.totals <-  mayor.funds.time %>%
  group_by(RECIPNAME, RECIPID, ) %>%
  summarise(fundraising = sum(AMNT)) %>%
  mutate(on_ballot = RECIPID %in% mayor.results$cand_id) %>%
  arrange(desc(on_ballot), desc(fundraising))

mayor.cand.time <-  mayor.funds.time %>%
  arrange(RECIPNAME) %>%
  mutate(on_ballot = RECIPID %in% mayor.results$cand_id)  %>%
  group_by(RECIPNAME, WEEK) %>%
  summarise(fundraised = sum(AMNT), RECIPID = RECIPID, on_ballot = on_ballot) %>%
  unique()
  # arrange(desc(on_ballot), desc(fundraising))

# only on ballot
mayor.time.ballot <- mayor.cand.time %>%
  filter(on_ballot == T)

#cumulative sum for each candidate
mayor.cumsum <- mayor.cand.time %>% group_by(RECIPNAME) %>% mutate(funds.to.date = cumsum(fundraised))


### PLOTTING % of expenditures vs $ of vote


### PLOTTING MAYOR TIME STUFF 
#plotting linegraph of fundraising over time
ggplot(data = mayor.cand.time, aes(x = WEEK, y = fundraised, group=RECIPNAME, color = RECIPNAME, linetype = on_ballot)) + geom_line() 

# plotting linegraph of all finalists
ggplot(data = mayor.time.ballot, aes(x = WEEK, y = fundraised, group=RECIPNAME, color = RECIPNAME)) + geom_line()
#Just McGuire - over a million in week 18 alone
ggplot(data = mayor.time.ballot[mayor.time.ballot$RECIPID == 2470,], aes(x = WEEK, y = fundraised, group=RECIPNAME, color = RECIPNAME)) + geom_line() 

# plotting cumsum
ggplot(data = mayor.cumsum, aes(x = WEEK, y = funds.to.date, group=RECIPNAME, color = RECIPNAME)) + 
  geom_line() + 
  theme(legend.position = 'bottom')

# drop-outs vs not
tmp <- mayor.time.cand[2:nrow(mayor.time.cand),]
ggplot(data = mayor.time.cand[2:nrow(mayor.time.cand),], aes(x = fundraising, y = on_ballot)) + geom_boxplot() 



#only looking at on-ballot results
final.mayor.time <- mayor.cand.time %>%
  filter(on_ballot == T)

# Histogram showing ballot and drop-out by money made
ggplot(data = mayor.results, aes(x  = cand_name, y = reorder(net_expnd, x=cand_name), fill=pc_1)) + 
  geom_col() + 
  coord_flip() + 
  # scale_fill_gradient2(low="blue", mid="yellow", high="red") + 
  labs(x = 'Candidate', y = 'Total Expenditures')

### MONEY SOURCE - NYC Contributions
nyc.contributions.trimmed <- nyc.contributions %>%
  select(RECIPID, 
         RECIPNAME, 
         FILING, 
         DATE, 
         REFUNDDATE, 
         CITY, 
         STATE,
         ZIP,
         AMNT,
         C_CODE
         )


### MONEY SPENDING - 


### -----------------------  SAVE DATA  ---------------------------------------
appFolder = './project/nyc2021primary/electionApp/'
fileName = 'contribs.csv'
path = paste0(appFolder, fileName)
write.csv(contrib.cleaned, './project/nyc2021primary/electionApp/contribs.csv', row.names = T)
write.csv(nyc.results, './project/nyc2021primary/electionApp/results.csv', row.names = T)
write.csv(mayor.results, './project/nyc2021primary/electionApp/mayorresults.csv', row.names = T)

## TEMP
#mayor.results ggplot for shiny

dist = 35
arg2 <- nyc.results %>%
  filter(district == dist) %>%
  select(cand, votes_1) 

ggplot(arg2, aes(x = cand, y = votes_1)) + geom_col()

cand.input = 'Wiley, Maya' 
arg <- mayor.results %>%
  filter(cand_name == 'Wiley, Maya ') %>%
  ggplot(aes(x=c(cntrs_no, sml_no, max_no)))
  
ggplot(data = mayor.results, aes(x=c(cntrs_no, sml_no, max_no), y = ))

ggplot(arg) + geom_bar(aes(y = sml_no))


