
################################################
#### The Tidyverse -- Workshop Day 2        ####
#### College of Social & Behavioral Sciences ###
#### Josh McCrain                           ####
#### joshuamccrain.com                      ####
#### josh.mccrain@utah.edu                  ####
################################################

## Available at : https://www.joshuamccrain.com/day2_tidyverse.R
## Data at:       https://www.joshuamccrain.com/day2_workshop.zip

# HOW TO USE THIS FILE:
#   - Put your cursor on a line and hit Ctrl+Enter (Cmd+Enter on a Mac).
#   - Anything after a # is a comment and R ignores it
#   - Type the code instead of copy and paste.
#   - Unzip R_workshop_day2.zip into your "R Workshop" folder so that this
#     file sits next to a folder called data/.




# 0. Setup ----------------------------------------------------------------

# Today uses PACKAGES: code other people wrote and shared, which you add on
# top of R -- why R is so great
#
#   install.packages()  downloads it to your computer. ONCE. (Or when
#                       you update R.)
#   library()           loads it into this session. run every time you open R.
#
# If you have not installed yet, run this line once and then comment it out
# by putting a # in front of it:
# install.packages(c("tidyverse", "janitor", "sf", "broom"))

library(tidyverse)

# Read the startup message. Two parts:
#   "Attaching core tidyverse packages" -- tidyverse is a bundle. dplyr
#       (wrangling), ggplot2 (plots), tidyr (reshaping), readr (reading
#       files), stringr (text), purrr (iteration), and a few others.
#   "Conflicts" -- dplyr has a function called filter(), and so does base R.
#       The one loaded LAST wins. Not an error.

getwd()
# setwd("C:/Users/you/R Workshop")
# Or: Session > Set Working Directory > To Source File Location

list.files("data")  




# 1. The pipe -------------------------------------------------------------

# Here is a real name from the dataset we will use today, exactly as it was
# typed in the original datat:

agency <- "  Citizens' Law Enforcement Review Board (CLERB) "

# Suppose we want to compare agency names across two sources. Different
# people type the same name differently, so first we standardize: drop the
# acronym in parentheses, drop punctuation, make it all caps, and strip the
# extra spaces. stringr (part of the tidyverse) has a function for each step.
# All of them start with str_ so you can find them by typing str_ and Tab.

str_remove(agency, "\\(.*\\)")        # remove "(" anything ")"
str_remove_all(agency, "[[:punct:]]")  # remove every punctuation mark
str_to_upper(agency)
str_squish(agency)                     # trim ends, collapse inner spaces

# The weird strings in quotes are "regular expressions" -- patterns for
# matching text. 


## Way 1: nesting ----------------------------------------------------------
# Put each function inside the next one:

str_squish(str_to_upper(str_remove_all(str_remove(agency, "\\(.*\\)"), "[[:punct:]]")))

# It works. Impossible to read... now imagine ten steps instead of four.


## Way 2: overwrite an object, one step per line ---------------------------

clean <- str_remove(agency, "\\(.*\\)")
clean <- str_remove_all(clean, "[[:punct:]]")
clean <- str_to_upper(clean)
clean <- str_squish(clean)
clean

# Readable, top to bottom. But "clean <-" and "(clean," are typed over and
# over, and it is easy to run one line twice or skip one.






## Dramatic Pause ##






## Way 3: the pipe ---------------------------------------------------------

agency |>
  str_remove("\\(.*\\)") |>
  str_remove_all("[[:punct:]]") |>
  str_to_upper() |>
  str_squish()

# Read |> as "and then": take agency, AND THEN remove the parenthetical,
# AND THEN remove punctuation, AND THEN make it upper case, AND THEN squish.

 


## What the pipe actually does ---------------------------------------------
#
#     x |> f(y)     is exactly the same as     f(x, y)
#
# The thing on the LEFT becomes the FIRST argument of the function on the
# right

sum(5, 10)
5 |> sum(10)

mean(c(4, 8, NA), na.rm = TRUE)
c(4, 8, NA) |> mean(na.rm = TRUE)

# Four precise things about it:
#
#   1. It passes into the FIRST argument. Every tidyverse function puts the
#      data first on purpose, so this just works for everything today.
#
#   2. The parentheses are required: str_to_upper(), not str_to_upper.
#
#   3. Put the |> at the END of a line, never the start of the next one.
#      R reads a line ending in |> as "not done yet, keep going."
#
#   4. A pipe does not SAVE anything. The result prints and is gone. To keep
#      it, assign it:  clean <- agency |> ...
#
# Typing it: Ctrl+Shift+M (Cmd+Shift+M on Mac).

# YOU WILL ALSO SEE %>% (from the magrittr package). It is the older
# tidyverse pipe and it is all over the internet
# For everything in this workshop, |> and %>% are
# INTERCHANGEABLE. Same rule, same results:

agency %>% str_to_upper()
agency |> str_to_upper()

# If Ctrl+Shift+M gives you %>%: Tools > Global Options > Code >
# check "Use native pipe operator, |>".


## Wrap it in a function ---------------------------------------------------
# Day 1 rule: when you type the same thing repeatedly, name it.

clean_name <- function(x) {
  x |>
    str_remove("\\(.*\\)") |>
    str_remove_all("[[:punct:]]") |>
    str_to_upper() |>
    str_squish()
}

clean_name(agency)

# stringr functions are vectorized (Day 1, section 1), so ours is too. It
# works on a whole vector of names at once -- which means on a whole column:
clean_name(c("Berkeley Police Review Commission ",
             "Police Advisory and Review Committee (PARC)",
             "City of Boise,Office of Police Oversight"))


## Day 1 in brief ------------------------------------------------------
# Last time we ended with tapply() and a four-level nested ifelse()
# This is the readable, preferred version


pager <- read_csv("data/criminalrecord.csv")

pager |>
  mutate(group = case_when(
    black == 0 & crimrec == 0 ~ "white, no record",
    black == 0 & crimrec == 1 ~ "white, record",
    black == 1 & crimrec == 0 ~ "Black, no record",
    black == 1 & crimrec == 1 ~ "Black, record"
  )) |>
  summarize(callback_rate = mean(callback),
            n             = n(),
            .by           = group)

# Same four numbers as Day 1. Notice there is no pager$ anywhere: inside a
# tidyverse verb, you name columns directly.




# 2. Reading messy data ---------------------------------------------------

# THE DATA, part 1: a database of civilian police oversight agencies in the
# U.S. -- review boards, police auditors, inspectors general. Each row is an
# agency, with the city, state, and county it covers.
#
# It is shipped as it came in: somewhat messy. That is the point.
## NOTE: we are using read_csv instead of read.csv


agencies <- read_csv("data/oversight_agencies.csv")

# Read the messages. readr just told you:
#   - it named a column "...1" because that column had no name
#   - what type it guessed for each column (chr = text, dbl = number)

agencies            # a TIBBLE: a data frame that prints politely
glimpse(agencies)   # every column, its type, and the first few values

# Three problems
#
#   1. A column called "...1". It is just a row number. Useless.
#   2. A column called `AGENCY NAME`, with a space in it. To use it you have
#      to type backticks every time:  agencies$`AGENCY NAME`
#   3. county_fips is a number (dbl). Look at California: 6001. A county
#      FIPS code is FIVE characters -- the state (06) plus the county
#      (001). Stored as a number, the leading zero is gone. Utah (49...)
#      survived only because 49 does not start with zero.

## extremely useful helper functions:

library(janitor)

agencies <- agencies |>
  clean_names()          # lower case, underscores, no spaces or symbols

names(agencies)

agencies <- agencies |>
  select(-x1) |>                                   # drop a column
  mutate(county_fips = as.character(county_fips),  # number -> text
         county_fips = str_pad(county_fips, width = 5, pad = "0"),
         agency_clean = clean_name(agency_name))   # our function, on a column

agencies

# mutate() makes or changes columns. Inside it, you can use a column you
# just made on the line above (county_fips twice).




## Duplicates ---------------------------------------------------------------

# count() counts rows by the values of a column:
agencies |> count(state)
agencies |> count(state, sort = TRUE)

# Are any agencies in here twice?
agencies |>
  count(agency_clean, sort = TRUE) |>
  filter(n > 1)

# filter() KEEPS rows where the condition is TRUE. Same logical questions as
# Day 1 (==, >, &, |), no brackets, no data$.

agencies |> filter(agency_clean == "BERKELEY POLICE REVIEW COMMISSION")

# Now look at Albuquerque:
agencies |> filter(city == "Albuquerque")

# Three rows, one agency. The computer only catches EXACT matches -- one of
# those rows has a typo, and one puts the city at the end. Cleaning helps;
# it does not replace looking at your data.

# distinct() keeps the first row for each unique value.
# .keep_all = TRUE keeps the other columns along for the ride.
agencies <- agencies |>
  distinct(agency_clean, .keep_all = TRUE)

nrow(agencies)


## Missing values ------------------------------------------------------------
agencies |> filter(is.na(county_fips))

# Washington, D.C. has a FIPS code (11001); whoever built the sheet did not
# enter it. Fix a single value with if_else(): if_else(question, yes, no)
agencies <- agencies |>
  mutate(county_fips = if_else(state == "Washington DC", "11001", county_fips))






# 3. The core verbs -------------------------------------------------------

# THE DATA, part 2: public support for civilian oversight in every U.S.
# county.
#
#   Nobody surveyed 3,000 counties. A national survey asked people two
#   questions:
#     - do you support civilian oversight of police, with independent
#       oversight authority?
#     - do you support civilian oversight with independent authority,
#       INCLUDING the power to fire officers?

#   Then MRP (multilevel regression and poststratification) estimated how
#   support varies with demographics and geography, and projected that onto
#   the census makeup of each county. The result is an ESTIMATE of the
#   share of adults in each county who support each.
#

#   county_fips   5-character county code (state + county)
#   county        county name
#   state, state_abb, region
#   mrp_crb       estimated share supporting civilian oversight
#   mrp_firing    estimated share supporting oversight WITH firing power
#   pop           population (2020 census)
#   med_inc       median household income (ACS 2016-2020)
#   perc_urban    share of population living in urban areas
#   perc_white, perc_black
#   perc_ba       share of adults 25+ with a bachelor's degree or more
#   perc_repub    Trump's share of the 2020 presidential vote

## Used in https://onlinelibrary.wiley.com/doi/10.1002/pam.22620

counties <- read_csv("data/counties.csv")
glimpse(counties)

# Look at county_fips. Delaware is fine (10001), but scroll down:
counties |> filter(state == "Alabama")


# 1001. readr GUESSED it was a number and threw away the zero -- the same
# problem as the agency file, but this time caused by the reading itself.
# Tell read_csv what type the column is, and it never happens:

counties <- read_csv("data/counties.csv",
                     col_types = cols(county_fips = col_character()))
counties |> filter(state == "Alabama")

# Any ID that looks like a number but is not one to do math on -- FIPS
# codes, ZIP codes, phone numbers, student IDs -- read it as text.


## select(): pick columns ---------------------------------------------------
counties |> select(county, state, mrp_crb)
counties |> select(county, state, starts_with("perc_"))
counties |> select(-county_fips, -state_abb)



## filter(): pick rows ------------------------------------------------------
counties |> filter(state == "Utah")
counties |> filter(state == "Utah", pop > 100000)   # comma means AND
counties |> filter(state %in% c("Utah", "Idaho", "Nevada"))



## arrange(): sort ----------------------------------------------------------
counties |> arrange(mrp_crb)
counties |> arrange(desc(mrp_crb))

# Or directly ask for the top or bottom few:
counties |> slice_max(mrp_crb, n = 10)
counties |> slice_min(mrp_crb, n = 10)



## mutate(): make columns ---------------------------------------------------
counties |>
  mutate(pop_thousands = pop / 1000,
         gap           = mrp_crb - mrp_firing) |>
  select(county, state, pop_thousands, mrp_crb, mrp_firing, gap)


# case_when() is ifelse() for more than two outcomes. Conditions are checked
# in order; the first TRUE wins; .default catches everything left over.
counties <- counties |>
  mutate(urbanicity = case_when(
    perc_urban >= 0.8 ~ "urban",
    perc_urban >= 0.4 ~ "mixed",
    .default           = "rural"
  ))

counties |> count(urbanicity)

# COMMON MISTAKE: running a pipe and forgetting to save
# it. If you do not assign with <-, the data frame did not change.




# 4. Grouping: split, apply, combine --------------------------------------

# summarize() collapses many rows into one:

counties |>
  summarize(mean_support = mean(mrp_crb, na.rm = TRUE),
            n_counties   = n())

# What is that number? It is the average COUNTY. Los Angeles County (10
# million people) and Loving County, Texas (64 people) each count once.
#
#   ** A mean of counties is not a mean of people. **
#
# To get the average PERSON, weight each county by its population:

counties |>
  summarize(mean_support     = mean(mrp_crb, na.rm = TRUE),
            weighted_support = weighted.mean(mrp_crb, w = pop, na.rm = TRUE))

# Different questions, different numbers. 


## .by: do it separately for each group -------------------------------------
# This is the single most useful idea in the tidyverse. Split the data by a
# grouping variable, apply a summary to each piece, combine the results.

counties |>
  summarize(support = weighted.mean(mrp_crb, w = pop, na.rm = TRUE),
            .by = region)

# One row per state. Save this one -- we will plot it and map it later.
states <- counties |>
  summarize(support          = weighted.mean(mrp_crb,    w = pop, na.rm = TRUE),
            support_firing   = weighted.mean(mrp_firing, w = pop, na.rm = TRUE),
            support_unweight = mean(mrp_crb, na.rm = TRUE),
            perc_repub       = weighted.mean(perc_repub, w = pop, na.rm = TRUE),
            pop              = sum(pop),
            n_counties       = n(),
            .by = c(state, state_abb, region)) |>
  arrange(desc(support))

states

# Compare this to tapply() from Day 1: several summaries at once, several
# grouping variables at once, and the result is a data frame you can keep
# working with.



## group_by(): the other way to write it -------------------------------------
# You will see this everywhere:

counties |>
  group_by(region) |>
  summarize(support = weighted.mean(mrp_crb, w = pop, na.rm = TRUE))

# Same result. The difference: group_by() STICKS to the data frame until
# you ungroup() it, which can surprise you three steps later. .by = applies
# to one verb only. Use .by; recognize group_by.


## Grouped mutate: compare each row to its own group ------------------------
# summarize() returns one row per group. mutate() with .by keeps EVERY row,
# but computes within the group. So each county can be compared to its own
# state:

counties <- counties |>
  mutate(state_avg     = weighted.mean(mrp_crb, w = pop, na.rm = TRUE),
         vs_state      = mrp_crb - state_avg,
         rank_in_state = min_rank(desc(mrp_crb)),
         .by = state)

counties |>
  filter(state == "Utah") |>
  select(county, pop, mrp_crb, state_avg, vs_state, rank_in_state) |>
  arrange(rank_in_state)

# The most supportive county in every state, in one line:
counties |> slice_max(mrp_crb, n = 1, by = state)




# 5. Joins ----------------------------------------------------------------

# Two data frames that share a column can be merged on it. Which counties
# have an oversight agency? That information is in `agencies`; the support
# estimates are in `counties`. The shared column is county_fips.
#
# Merging is a a surprising amount of the actual data wrangling you will do.
# Borrows logic from SQL
#
# First, one row per county. Some counties have several agencies (Los
# Angeles has five), and we do not want to duplicate county rows:

agency_counts <- agencies |>
  count(county_fips, name = "n_agencies")

agency_counts

# left_join(x, y): keep EVERY row of x, attach matching columns from y.
# Rows of x with no match get NA.
counties <- counties |>
  left_join(agency_counts, by = join_by(county_fips))

counties |> filter(!is.na(n_agencies)) |> select(county, state, n_agencies)

# NA here really means zero, so say so:
counties <- counties |>
  mutate(n_agencies = replace_na(n_agencies, 0),
         has_agency = n_agencies > 0)

# replace_na is awesome

counties |> count(has_agency)

# ALWAYS check what did not match. anti_join() returns rows of x that have
# NO match in y:
anti_join(agency_counts, counties, by = join_by(county_fips))

# Zero rows is the answer you want. Try the join with the FIPS codes before
# we padded them and California disappears entirely -- silently. No error, no
# warning, just fewer matches. anti_join() is how you catch it.

# Do counties with an oversight agency support oversight more?
counties |>
  summarize(support = weighted.mean(mrp_crb, w = pop, na.rm = TRUE),
            n       = n(),
            .by     = has_agency)

# Yes. Does having an agency CAUSE support? who
# chose to create one? What else is different about those counties?




# EXERCISE 1 ==============================================================
#
# ~~15 minutes.
#
# Use `counties` and `states` from above. Weight by population unless the
# question says otherwise.
#
# 1) Which five states have the HIGHEST support for oversight WITH firing
#    power (support_firing in `states`)? Which five the lowest?
#
#
#
# 2) Support for oversight in general is higher than support for oversight
#    with firing power. In which state is that gap the LARGEST?
#    (Hint: mutate() a new column in `states`, then arrange or slice_max.)
#
#
#
# 3) In Utah: which county is most supportive of civilian oversight? Least?
#    How far is Salt Lake County from the Utah average?
#
#
#
# 4) Compare urban, mixed, and rural counties WITHIN each region. Is the
#    urban-rural difference the same everywhere?
#    (Hint: .by can take two variables: .by = c(region, urbanicity).)
#
#
#
# 5) mrp_firing is below 0.5 in some counties -- a majority opposes. How
#    many such counties are there in each state? Which state has the most?
#
#
#
# (*) FINISHED EARLY?
#
#   a) Fix the Albuquerque duplicates properly. Give all three rows the same
#      agency_clean, then run distinct() again. How many agencies are left?
#
#   b) Among counties WITHOUT an agency, which large ones (pop > 500,000)
#      have the highest support? Those are, in a sense, the places where
#      public opinion is ahead of policy.
#
# =========================================================================



# =========================================================================
#                              B R E A K
# =========================================================================




# 6. ggplot: the grammar of graphics --------------------------------------

# Every ggplot has three parts:
#   data        a data frame
#   aes()       "aesthetic mappings": which COLUMN controls which VISUAL
#               property (x position, y position, color, size, ...)
#   geom_*()    what shape to draw (points, lines, bars, ...)
# and you add pieces with +.

ggplot(counties, aes(x = mrp_crb)) +
  geom_histogram(bins = 40)

ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point()

# "Removed 31 rows containing missing values" -- a warning, not an error.
# ggplot cannot place a point with no x. Which rows? Ask:
counties |> filter(is.na(perc_repub)) |> count(state)
# Alaska reports election results by legislative district, not by county.

# 3,000 points on top of each other. Make them see-through:
ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point(alpha = 0.3)


## Inside aes() or outside? ---------------------------------------------------
# INSIDE aes():  color is DATA. It changes with a column, and you get a legend.
# OUTSIDE aes(): color is a SETTING. Everything is that one color.

ggplot(counties, aes(x = perc_repub, y = mrp_crb, color = region)) +
  geom_point(alpha = 0.3)

ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point(alpha = 0.3, color = "steelblue")

# Now the connection to section 4. Mapping color to region GROUPED the data.
# Add a trend line and ggplot draws one per group, automatically -- this is
# .by = region, for pictures:

ggplot(counties, aes(x = perc_repub, y = mrp_crb, color = region)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "lm")

# Mappings in ggplot() apply to EVERY layer. Mappings inside one geom apply
# to that layer only. Move color into geom_point() and there is just one line:
ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point(aes(color = region), alpha = 0.2) +
  geom_smooth(method = "lm", color = "black")


## Pipes into plots --------------------------------------------------------
# Wrangle, then plot, in one chain. The rule: |> up until ggplot(), + after.

counties |>
  filter(state == "Utah") |>
  ggplot(aes(x = perc_repub, y = mrp_crb, size = pop)) +
  geom_point(alpha = 0.6) +
  geom_text(aes(label = county), size = 3, vjust = -1)




# 7. Layers built from different data -------------------------------------

# Every layer can have its OWN data. This is where wrangling and plotting
# meet: summarize something, then draw it on top of the raw data.

# Counties in gray, states on top:
ggplot() +
  geom_point(data = counties, aes(x = perc_repub, y = mrp_crb),
             color = "gray75", alpha = 0.3) +
  geom_point(data = states, aes(x = perc_repub, y = support),
             color = "firebrick", size = 2.5)

# Highlight one group against everyone else. The trick is a second,
# filtered data frame:
utah <- counties |> filter(state == "Utah")

ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point(color = "gray80", alpha = 0.4) +
  geom_point(data = utah, color = "firebrick") +
  geom_text(data = utah |> slice_max(pop, n = 5),
            aes(label = county), vjust = -1, size = 3.5)

# The utah layer inherits x and y from ggplot(), but uses its own data.




## A sorted dot plot, and why reshaping matters --------------------------------
# Every state, ordered by support. fct_reorder() sorts a category by a
# number; otherwise ggplot sorts states alphabetically.

states |>
  ggplot(aes(x = support, y = fct_reorder(state, support))) +
  geom_point()

# What if we want weighted AND unweighted support, in two colors, with a
# legend? ggplot maps ONE column to color. Right now those are two columns.
# We need one column that says which kind, and one column with the number.
# That is a reshape -- next section.




# 8. Reshaping, facets, and polish ----------------------------------------

## pivot_longer(): wide to long --------------------------------------------

states |>
  select(state, support, support_unweight) |>
  pivot_longer(cols      = c(support, support_unweight),
               names_to  = "type",
               values_to = "estimate")

# Every state now has two rows. The old column NAMES became values in `type`.
# That shape is what ggplot wants:

states |>
  mutate(state = fct_reorder(state, support)) |>
  pivot_longer(cols      = c(support, support_unweight),
               names_to  = "type",
               values_to = "estimate") |>
  ggplot(aes(x = estimate, y = state, color = type)) +
  geom_point()

# Where does weighting move a state a lot? Why would it?


## A second real reshape -------------------------------------------------------
# THE DATA, part 3: county estimates from the Cooperative Election Study
# (CES), also produced with MRP, in three different years.
#   bwc_YEAR    share supporting requiring police to wear body cameras
#   safe_YEAR   share saying the police make them feel safe

opinion <- read_csv("data/county_opinion.csv",
                    col_types = cols(county_fips = col_character()))
opinion

# Year is hiding in the column NAMES. That makes it impossible to plot or
# summarize by year. pivot_longer() can split each name in two at the "_":

opinion_long <- opinion |>
  pivot_longer(cols            = -county_fips,
               names_to        = c("measure", "year"),
               names_sep       = "_",
               values_to       = "estimate",
               names_transform = list(year = as.integer))

opinion_long

# pivot_wider() goes the other way. Handy for computing change over time:
opinion_long |>
  filter(measure == "bwc") |>
  pivot_wider(names_from = year, values_from = estimate,
              names_prefix = "y") |>
  mutate(change = y2022 - y2016)


## Facets: one panel per group ------------------------------------------------
# facet_wrap() is .by for panels:

opinion_long |>
  ggplot(aes(x = estimate)) +
  geom_histogram(bins = 50) +
  facet_wrap(~ measure + year)

# The two measures are on different ranges. Let each panel pick its own
# x-axis, and put a measure in each row:
opinion_long |>
  ggplot(aes(x = estimate)) +
  geom_histogram(bins = 50) +
  facet_grid(year ~ measure, scales = "free_x")


## Polish and save ---------------------------------------------------------
# Save a plot as an object, add to it, and write it to a file.

p <- ggplot(counties, aes(x = perc_repub, y = mrp_crb)) +
  geom_point(aes(color = urbanicity), alpha = 0.3) +
  geom_smooth(method = "lm", color = "black") +
  scale_x_continuous(labels = scales::label_percent()) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(title    = "Support for civilian oversight of police",
       subtitle = "U.S. counties, MRP estimates",
       x        = "Trump vote share, 2020",
       y        = "Estimated support",
       color    = NULL) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

p

dir.create("figures", showWarnings = FALSE)
ggsave("figures/support_by_vote.png", plot = p, width = 7, height = 5, dpi = 300)

# Always give ggsave() a width and height. Otherwise it uses whatever size
# your Plots pane happens to be, and your figure changes every time.




# 9. Maps -----------------------------------------------------------------

library(sf)

# sf = "simple features", the standard way R stores shapes. The two map
# files were made from Census boundary files, with Alaska and Hawaii moved
# under the lower 48 so the map fits.

counties_sf <- readRDS("data/counties_sf.rds")
states_sf   <- readRDS("data/states_sf.rds")

counties_sf
class(counties_sf)

# An sf object is a DATA FRAME with one extra column: geometry. Each cell of
# geometry holds a shape. Everything you learned this morning works on it.

ggplot(counties_sf) +
  geom_sf()

# To color counties by support, join the data onto the shapes.
# Precise point: put the sf object on the LEFT of the join. The result takes
# the type of the left-hand data frame, and you want it to stay a map.

county_map <- counties_sf |>
  left_join(counties |> select(county_fips, mrp_crb, mrp_firing, has_agency),
            by = join_by(county_fips))

# fill is the aesthetic for the INSIDE of a shape; color is its border.
ggplot(county_map) +
  geom_sf(aes(fill = mrp_crb), color = NA) +
  scale_fill_viridis_c(labels = scales::label_percent(), name = "Support") +
  theme_void()


## Layers from different data, again ------------------------------------------
# Add state borders on top, from a different data frame. fill = NA makes
# them hollow.

ggplot() +
  geom_sf(data = county_map, aes(fill = mrp_crb), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(labels = scales::label_percent(), name = "Support") +
  theme_void()

# Now a third layer: where oversight agencies actually exist. Take the
# counties that have one and shrink each to a single point in its middle.
agency_points <- counties_sf |>
  filter(county_fips %in% agencies$county_fips) |>
  st_point_on_surface()

# The warning ("assumes attributes are constant") is sf being careful: the
# county's name now belongs to a point instead of a shape. Harmless here.

ggplot() +
  geom_sf(data = county_map, aes(fill = mrp_crb), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  geom_sf(data = agency_points, shape = 21, fill = "white", size = 2) +
  scale_fill_viridis_c(labels = scales::label_percent(), name = "Support") +
  labs(title    = "Support for civilian oversight, and where it exists",
       subtitle = "Points mark counties with a civilian oversight agency") +
  theme_void()

# Three layers, three data frames: counties, states, agencies.


## A state-level map from summarized data --------------------------------------
# `states` came from summarize(.by = state) back in section 4. Join it to the
# state shapes and map it:

states_sf |>
  left_join(states, by = join_by(state, state_abb)) |>
  ggplot() +
  geom_sf(aes(fill = support), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(labels = scales::label_percent(), name = "Support") +
  theme_void()

# Compare to the county map. The state map hides almost everything.


## One state ----------------------------------------------------------------
county_map |>
  filter(state == "Utah") |>
  ggplot() +
  geom_sf(aes(fill = mrp_crb), color = "white") +
  geom_sf_text(aes(label = county), size = 2.5) +
  scale_fill_viridis_c(labels = scales::label_percent(), name = "Support") +
  theme_void()

# Now picture doing that for all fifty states. That is next.




# 10. Iteration with purrr -------------------------------------------------

# Day 1's loop pattern: make an empty container, loop, fill it.
results <- rep(NA, 5)
for (i in 1:5) {
  results[i] <- i * 10
}
results

# purrr's map() does the same thing in one line: apply a function to every
# element, and collect the results.
map(1:5, \(i) i * 10)

# \(i) i * 10 is a function with no name: "take i, return i times 10".
# \(i) is shorthand for function(i). You will also see this older style in
# code online -- same thing:  map(1:5, ~ .x * 10)

# map() ALWAYS returns a list (Day 1, section 5), because a list can hold
# anything. When every result is one number, ask for a vector instead:
map_dbl(1:5, \(i) i * 10)       # dbl = numbers
map_chr(c("utah", "idaho"), \(s) str_to_upper(s))   # chr = text

# With a real function:
map_dbl(c("Utah", "Idaho", "Nevada"),
        \(s) counties |> filter(state == s) |> pull(mrp_crb) |> mean())

# But .by already does that, and better. When a group's answer is a single
# number, use .by. Reach for map() when the answer for each group is
# something BIGGER: a data frame, a model, a file, a plot.


## A folder full of files --------------------------------------------------
# The most common real use. Data often arrives as one file per state, per
# year, per wave. Make a folder of four files, one per region, to practice:

dir.create("by_region", showWarnings = FALSE)
counties |>
  select(county_fips, county, state, region, mrp_crb) |>
  group_split(region) |>
  walk(\(df) write_csv(df, paste0("by_region/", df$region[1], ".csv")))

list.files("by_region")

# Now read them all back in and stack them:
files <- list.files("by_region", full.names = TRUE)
files

map(files, read_csv)                    # a list of four data frames

# list_rbind() stacks a list of data frames into one. It is the tidyverse
# version of Day 1's do.call(rbind, ...):
map(files, read_csv) |>
  list_rbind()

# An error. READ IT: "Can't combine ..1$county_fips <double> and
# ..2$county_fips <character>." Our old friend. read_csv() guessed the type
# of county_fips separately for each file and guessed differently. You
# cannot stack a number column on top of a text column.
#
# The fix is the one from section 3 -- tell read_csv the type -- but now
# we need to pass that extra argument through map(). That is exactly what
# the \(f) function is for:

all_regions <- map(files, \(f) read_csv(f, col_types = cols(county_fips = col_character()))) |>
  list_rbind()

nrow(all_regions)

# (read_csv() can also take a vector of file names directly. The map()
# version works with ANY reading function -- Excel, Stata, SPSS.)


## One model per state ------------------------------------------------------
# Within each state, how strongly is Republican vote share related to
# support? That is a regression per state -- fifty models.

library(broom)

state_models <- counties |>
  filter(state != "District of Columbia") |>          # one county; no slope
  nest(.by = state) |>
  mutate(model   = map(data, \(df) lm(mrp_crb ~ perc_repub, data = df)),
         results = map(model, \(m) tidy(m, conf.int = TRUE)))

state_models

# Read that tibble. Each row is a state. `data` is a whole data frame per
# state; `model` is a whole regression per state. Columns can hold lists --
# so they can hold anything.
#
# tidy() turns a model (a list, Day 1 section 5, reason 2) into a data frame.
# unnest() spreads those data frames back out into rows:

slopes <- state_models |>
  unnest(results) |>
  filter(term == "perc_repub") |>
  select(state, estimate, conf.low, conf.high)

slopes |>
  ggplot(aes(x = estimate, y = fct_reorder(state, estimate))) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "Change in support per unit of Trump vote share", y = NULL)




# 11. One map per state ----------------------------------------------------

# Write the Utah map ONCE as a function of the state's name:

plot_state <- function(state_name) {
  county_map |>
    filter(state == state_name) |>
    ggplot() +
    geom_sf(aes(fill = mrp_crb), color = "white", linewidth = 0.1) +
    scale_fill_viridis_c(labels = scales::label_percent(), name = "Support",
                         limits = range(county_map$mrp_crb, na.rm = TRUE)) +
    labs(title    = state_name,
         subtitle = "Estimated support for civilian oversight of police") +
    theme_void()
}

plot_state("Utah")
plot_state("Texas")
plot_state("Georgia")

# limits = fixes the color scale to the NATIONAL range, so the same color
# means the same number on every map. Delete that line and each state gets
# its own scale -- more contrast within a state, but you can no longer
# compare two maps by eye. Neither is wrong; know which one you made.

# map() over a few states returns a list of plots:
some_maps <- map(c("Utah", "Colorado", "New Mexico"), plot_state)
some_maps[[2]]

# walk() is map() for SIDE EFFECTS -- things you want DONE (a file saved)
# rather than returned. Every state, saved to its own file:

dir.create("state_maps", showWarnings = FALSE)
all_states <- unique(county_map$state)

walk(all_states, \(s) ggsave(filename = paste0("state_maps/", s, ".png"),
                             plot     = plot_state(s),
                             width    = 6, height = 6, dpi = 150))

list.files("state_maps")

# Open that folder. Fifty-one maps. Change the function -- a color, a title,
# a variable -- rerun ONE line, and all of them update.
#
# facet_wrap() or map()? facet_wrap() when you want ONE figure with many
# panels on a common scale. map()/walk() when you want many SEPARATE
# outputs: files, slides, one page per state in a report.




# EXERCISE 2 ==============================================================
#
# ~~10 minutes. Change plot_state(), then rerun it on a state or two.
#
# 1) Add the oversight agencies to the state maps as points. Inside the
#    function, filter agency_points to the same state and add a third
#    geom_sf() layer.
#
#
#
# 2) Give plot_state() a second argument so it can map EITHER mrp_crb or
#    mrp_firing. To use a column whose name is stored in an argument, write
#    aes(fill = .data[[var]]) instead of aes(fill = mrp_crb):
#
#      plot_state <- function(state_name, var = "mrp_crb") { ... }
#      plot_state("Utah", "mrp_firing")
#
#
#
# 3) Use map() to make a NATIONAL map of body camera support (bwc) for each
#    of the three years in opinion_long. Start by writing plot_year(yr).
#
#
#
# (*) FINISHED EARLY?
#
#   Which state has the steepest slope in `slopes`? The flattest? Map both
#   with plot_state(). Does the map make the slope make sense?
#
# =========================================================================




# 12. Getting unstuck ------------------------------------------------------

# could not find function "ggplot"   (or "%>%", "read_csv", ...)
#   -> you did not run library(tidyverse) in this session.

# object 'mrp_crb' not found
#   -> you used a column name OUTSIDE a tidyverse verb, e.g. mean(mrp_crb).
#      Outside a verb you still need counties$mrp_crb.

# Error: `mapping` must be created by `aes()`
# Did you use `%>%` or `|>` instead of `+`?
#   -> inside a ggplot, layers are joined with +. The pipe stops at ggplot().

# Detected an unexpected many-to-many relationship
#   -> the column you joined on is not unique on either side. Count first
#      (like agency_counts), then join.

# The join "worked" but nothing matched
#   -> the keys look alike but are not: "6001" vs "06001", "Utah" vs "UT",
#      text vs number. anti_join() shows you exactly what failed.

# The data frame did not change
#   -> you ran the pipe but never assigned it with <-.




# =========================================================================
# PART B
# =========================================================================


## B1. Dissolving counties into states --------------------------------------

# summarize() on an sf object also combines the SHAPES. Group counties by
# state and the county lines disappear, leaving state outlines -- the same
# split-apply-combine, on geometry. (sf wants group_by() here, not .by.)

counties_sf |>
  left_join(counties |> select(county_fips, mrp_crb, pop),
            by = join_by(county_fips)) |>
  group_by(state) |>
  summarize(support = weighted.mean(mrp_crb, w = pop, na.rm = TRUE)) |>
  ggplot() +
  geom_sf(aes(fill = support)) +
  theme_void()


## B2. Plots in a column --------------------------------------------------------

# A tibble column can hold plots, too. Build a table of states, their plots,
# and their file names, then save with walk2() -- which walks over TWO
# vectors side by side:

west <- tibble(state = c("Utah", "Idaho", "Nevada", "Wyoming")) |>
  mutate(plot = map(state, plot_state),
         file = paste0("state_maps/west_", state, ".png"))

west

walk2(west$file, west$plot,
      \(f, p) ggsave(filename = f, plot = p, width = 6, height = 6))


## B3. When one iteration fails ------------------------------------------------

# If one element breaks, map() stops and you lose everything. possibly()
# wraps a function so that failures return a value you choose instead:

files_plus <- c(files, "by_region/Narnia.csv")

read_region <- function(f) {
  read_csv(f, col_types = cols(county_fips = col_character()))
}

# map(files_plus, read_region)                         # error, nothing back
safe_read <- possibly(read_region, otherwise = NULL)
map(files_plus, safe_read) |> list_rbind() |> nrow()  # the four good ones
