
################################################
#### Introduction to R -- Workshop Day 1    ####
#### College of Social & Behavioral Sciences ###
#### Josh McCrain                           ####
#### joshuamccrain.com                      ####
#### josh.mccrain@utah.edu                  ####
################################################


# HOW TO USE THIS FILE:
#   - Put your cursor on a line and hit Ctrl+Enter (Cmd+Enter on a Mac).
#     That sends the line to the Console where it runs.
#   - Anything after a # is a comment and R ignores it
#   - Type the code instead of copy and paste.




# 0. Getting oriented -----------------------------------------------------

# Four panes in RStudio: (by default)
#   top-left     this file (a SCRIPT -- saved, permanent, what you turn in)
#   bottom-left  the Console (where code actually runs; not saved)
#   top-right    the Environment (every object you have made)
#   bottom-right Files / Plots / Help
#
# The script is the "permanent" file while the console is a scratch pad (!! it does not get saved)

# Where is R currently looking for files?
getwd()

# If that is not the folder holding this file:
#   Session > Set Working Directory > To Source File Location

# What can R see from here? This is your first debugging move
list.files()

# Try it. Put your cursor on the next line and hit Ctrl+Enter.
2 + 2

# R is a calculator
7^2 + 4 * 3
sqrt(81)
log(100)      # note: R's log() is a natural log
exp(log(5))   # exp() undoes log()

# Every function has documentation
?log



# 1. Objects and vectors --------------------------------------------------

# You store things in objects with the arrow, <-
# (Alt+minus types it for you.)
# **** Do not use the = sign ****

n_applications <- 696
n_applications

# Look at your Environment pane. That is all an object is: a name pointing at a value.


n_applications / 2
n_applications <- n_applications + 4   # objects can be overwritten
n_applications


# A VECTOR is several values of the same type, in order. c() means "combine" or "concatenate"
# Imagine five job applications; 1 means the employer called back, 0 means silence.

callbacks <- c(1, 0, 0, 1, 0)
callbacks

length(callbacks)
sum(callbacks)
mean(callbacks)


# mean() of a vector of 0s and 1s is the PROPORTION of 1s. Two callbacks out
# of five is 0.4 -- a proportion IS a mean.

# Math on a vector happens to every element at once ("vectorized"):
callbacks * 100
callbacks + 1


# Vectors can hold text instead of numbers:
cities <- c("Milwaukee", "Milwaukee", "Madison")
cities


# But not both. Watch what happens:
mixed <- c(1, 0, "Milwaukee")
mixed          # the numbers turned into text -- note the quotes around 1 and 0
mean(mixed)    # a WARNING, and the answer is NA


# Read that carefully, because it is the dangerous kind. R did not stop. It
# handed you NA and a note explaining itself, and if you were not looking it
# would have flowed straight into your results. Warnings are not errors and
# they do not halt anything. Read them anyway.

# There IS a container that holds mixed types without flattening them. It is
# called a list, and it is section 5. Park it for now.

# What type is this thing? str() = structure. Use it constantly.
str(callbacks)
str(cities)

# Building vectors without typing every value:
1:10
seq(from = 1990, to = 2020, by = 5)
rep(0, 10)
rep(c("record", "no record"), each = 3)


## Logical operators ------------------------------------------------------
# These are how you ask R questions. The answer is always TRUE or FALSE.

3 > 4
3 < 4
3 == 4    # "is equal to" is TWO equals signs
3 != 4    # "is not equal to"

3 = 4     # error. One = means "assign", not "compare"

(3 < 4) & (5 > 6)    # & is AND -- both must be true
(3 < 4) | (5 > 6)    # | is OR  -- either will do


callbacks == 1
sum(callbacks == 1)   # TRUE counts as 1, so sum() counts how many are TRUE


## Indexing: pulling pieces out of a vector -------------------------------
# Square brackets mean "give me the elements at these positions."

callbacks[1]
callbacks[2:4]
callbacks[c(1, 5)]
callbacks[-1]                  # minus means "everything EXCEPT position 1"
callbacks[length(callbacks)]   # the last one, without knowing it is 5



callbacks[callbacks == 1]

# Read that as "callbacks, where callbacks equals 1."
# This is called logical subsetting. 





# 2. Data frames ----------------------------------------------------------

# A DATA FRAME is a rectangle: rows are observations, columns are variables.
# Each column is a vector. That is it. A data frame is a stack of vectors
# glued side by side, and everything you just learned about vectors still
# works on each column.


# Build a tiny one 
applicant <- c("A", "B", "C", "D")
record    <- c(1, 1, 0, 0)
called    <- c(0, 1, 1, 1)

toy <- data.frame(applicant, record, called)
toy



# Now some real data
#
# THE DATA: Pager (2003), "The Mark of a Criminal Record," AJS.
#   Each row is one job application submitted to one real employer.
#   Testers were matched pairs -- same age, same schooling, same
#   presentation, same fake resume -- except that one of them disclosed a
#   felony drug conviction. Which tester carried the record was rotated at
#   random from job to job. That rotation is what makes this an experiment.
#
#   callback     1 if the employer called back, 0 otherwise
#   crimrec      1 if the application disclosed a criminal record
#   black        1 if the tester was Black, 0 if white
#   city         which of two areas the job was in
#   distance     miles from the city center
#   custserv     job involves customer contact
#   manualskill  job requires a manual skill
#   jobid        which employer -- note that pairs share a jobid


d <- read.csv("data/criminalrecord.csv")



# ALWAYS look at data before you do anything to it
dim(d)        # rows, columns
names(d)      # variable names
head(d)       # the first six rows
str(d)        # each column and its type

# Or click `d` in the Environment pane. Same as:
View(d)

# Pull one column out with a dollar sign. A column is a vector:
d$callback
str(d$callback)
length(d$callback)

# Brackets on a data frame take TWO arguments: [rows, columns]
d[1, ]                             # first row, all columns
d[, 2]                             # all rows, second column
d[1:5, ]                           # first five rows
d[1:5, c("callback", "crimrec")]   # columns by name is safer than by number


# table() counts things. One variable:
table(d$crimrec)
table(d$callback)

# Two variables gives you a cross-tab:
table(d$callback, d$crimrec)

# That is unreadable without labels. Say what the dimensions are:
table(callback = d$callback, record = d$crimrec)

# Read the table. Of the applications WITH a record (right column), how many
# drew a callback? Of those WITHOUT one?



# 3. Subsetting is conditional probability --------------------------------

# P(callback) is "the share of ALL applications that got a callback."
# P(callback | record) is "the share of applications THAT DISCLOSED A RECORD
# that got a callback."
#
# The only difference is which rows you are averaging over. Conditioning on
# something means throwing away every row where it is not true, and taking
# the mean of what is left. The vertical bar in P(A | B) is literally the [ ].

# The unconditional rate:
mean(d$callback)

# Now condition. First just look at the subset:
d$callback[d$crimrec == 1]

# That is the callback column, keeping only rows where crimrec is 1.
# How many rows is that?
length(d$callback[d$crimrec == 1])

# And its mean is P(callback | record):
mean(d$callback[d$crimrec == 1])

# And the other group:
mean(d$callback[d$crimrec == 0])

# Save them so you can work with them:
p_record    <- mean(d$callback[d$crimrec == 1])
p_no_record <- mean(d$callback[d$crimrec == 0])

p_no_record - p_record

# That difference is the estimated effect of a criminal record on the
# probability of being called back, in percentage points.
#
# WHY are we allowed to call it an effect? 
#
# If Pager had instead found real job seekers and compared those who happened
# to have records to those who did not, this same subtraction would mean
# something very different.


# You can put more than one condition in the brackets with & and | :
mean(d$callback[d$crimrec == 1 & d$black == 1])
mean(d$callback[d$crimrec == 1 & d$city == 1])




## A word about missing values --------------------------------------------
# Real data has holes. R marks them NA

mean(d$distance)   # NA

# Explicitly that you want to ignore them:
mean(d$distance, na.rm = TRUE)

# Find them:
sum(is.na(d$distance))
which(is.na(d$distance))

# is.na() is a question, so it works in brackets like any other question:
d[is.na(d$distance), ]





# EXERCISE 1 ==============================================================
#
# ~~15 minutes. 
#
# Pager's real question was not "does a record hurt?" It was "does a record
# hurt everyone the same amount?" The variable `black` records whether the
# tester submitting the application was Black (1) or white (0).
#
#
# 1) How many applications were submitted by Black testers? By white testers?
#    (Two ways to get this: table(), or sum() of a logical question.)
#
#
# 2) Among WHITE testers only (black == 0), compute:
#       P(callback | no record)
#       P(callback | record)
#    Subtract them. That is the callback penalty for a record, among white
#    applicants, in percentage points.
#
#
# 3) Do exactly the same thing among BLACK testers only.
#
#
# 4) Compare the two penalties from 2 and 3. For which group does disclosing
#    a criminal record cost more?
#
#
# 5) Now line up two specific numbers you have already computed:
#
#       P(callback | white tester, WITH a record)
#       P(callback | Black tester, NO record)
#
#
# 6) say what these four numbers together imply: the kind of statement you would put in a policy memo about a
#    "ban the box" law
#
#
# (*) FINISHED EARLY? Try these.
#
#   a) Rebuild questions 2 and 3 as tables instead of means:
#      table(d$callback[d$black == 0], d$crimrec[d$black == 0])
#      Do the proportions match what you computed?
#
#   b) `city` codes which area the job was in. Does the record penalty differ
#      between the two? Careful -- city has missing values.
#
#   c) Applications came in pairs sharing a jobid. Use length(unique(d$jobid))
#      and table(table(d$jobid)) to confirm the pairing. Why might it matter
#      for standard errors that these rows are not independent of each other?
#      (We will do something about this in a later course, not today.)
#
# =========================================================================



# =========================================================================
#                              B R E A K
# =========================================================================




# 4. Making new variables -------------------------------------------------

# So far we have only read the data. In practice most of your time goes to
# creating variables that were not in the file.

# A new column is just assignment to a name that does not exist yet:
d$white <- ifelse(d$black == 0, 1, 0)

# ifelse() reads as: ifelse(question, value if TRUE, value if FALSE)
# It is vectorized -- it asks the question of every row and hands back a full
# column, which is why you can assign it straight into the data frame.
table(white = d$white, black = d$black)


# Something more useful: one variable naming all four groups at once.
d$group <- ifelse(d$black == 1 & d$crimrec == 1, "Black, record",
           ifelse(d$black == 1 & d$crimrec == 0, "Black, no record",
           ifelse(d$black == 0 & d$crimrec == 1, "white, record",
                                                 "white, no record")))

table(d$group)

# Nested ifelse gets ugly fast, and four levels is about the limit. Next class has
# case_when(), which is the readable version of exactly this.

# tapply() splits a vector by a grouping variable and applies a function to each piece:

tapply(d$callback, d$group, mean)


# Same thing, but in one line





## Factors: categorical variables with a fixed set of levels ---------------

# Notice the tapply output came out alphabetically, which is a terrible order
# for reading. A FACTOR is a categorical variable that remembers what its
# categories are AND what order they go in.


str(d$group)                    # right now it is just text
d$group <- factor(d$group,
                  levels = c("white, no record", "white, record",
                             "Black, no record", "Black, record"))

str(d$group)                    # now it is a factor with an order you chose
levels(d$group)

tapply(d$callback, d$group, mean)   # same numbers, sensible order


# Factors become incredibly important moving forward






# 5. Lists -- the other container ------------------------------------------

# Back in section 1 we tried to put numbers and text in the same vector and R
# flattened everything into text:
str(mixed)          # chr [1:3] -- the numbers became "1" and "0"

# A LIST is the container that holds anything, of any
# type, of any length, including other lists.
mixed_list <- list(1, 0, "Milwaukee")
str(mixed_list)     # a number, a number, and a string. Nothing was coerced.

# Elements are usually named, and can be whole vectors of different lengths:
study <- list(
  citation   = "Pager (2003), AJS 108(5)",
  n_apps     = 696,
  outcomes   = c("callback", "no callback"),
  randomized = TRUE
)

study
str(study)          # str() is even more useful on lists than on vectors
length(study)       # 4 -- the number of ELEMENTS, not of anything inside them
names(study)




## Getting things out: [[ ]] versus [ ] ------------------------------------

study[["n_apps"]]   # 696 -- a number
study["n_apps"]     # a LIST of length 1 that happens to contain 696

str(study[["n_apps"]])
str(study["n_apps"])

# Hadley Wickham's metaphor:
# if the list is a train, then
#     study[1]    hands you the first CAR      (still a train)
#     study[[1]]  hands you the CARGO inside it
#     study[[1]][1] gives you an individual item within the cargo
#
# Single bracket subsets the container and gives you a smaller container.
# Double bracket reaches in and gives you the contents.
#


# $ works too, exactly like it does on a data frame:
study$n_apps
study$outcomes
study$outcomes[2]   # second element of the vector that is inside the list


# By position rather than name:
study[[1]]
study[[3]]


# Lists inside lists, which is where $ chains start:
big <- list(a = 1:5, b = list(x = "hello", y = 99))
big$b$y
big[["b"]][["y"]]




## Why you actually care ---------------------------------------------------

# REASON 1: a data frame IS a list.
#
#  a list of vectors that all happen to have the same length

is.list(d)
length(d)          # the number of COLUMNS, because the columns ARE the
                   # elements of the list
names(d)
d[["callback"]]    # the same vector as...
d$callback         # ...this one
identical(d[["callback"]], d$callback)

# That is why $ works on both, and why length() of a data frame gives you the
# column count instead of the row count. 



# REASON 2: almost everything a statistical function hands back is a list.
#
# This is how you get numbers OUT of model output programmatically, instead
# of manually retyping it into a table by hand.

result <- t.test(d$callback[d$crimrec == 0],
                 d$callback[d$crimrec == 1])

result             # the printed version, formatted for a human to read

str(result)        # what the object actually is: a list
names(result)      # every piece of it, with a name

result$estimate    # look at these two numbers
result$conf.int
result$p.value


# Those two estimates are 0.2264 and 0.1009 -- the exact numbers computed
# by hand before the break. All a t-test did was take the difference you
# already had and attach an interval and a p-value to it.
#



# REASON 3: lists are the right container when each pass through a loop
# produces something bigger than a single number. Section 6 is next; come
# back to this after it.

out <- list()                      # start empty with undefined length

for (i in 1:3) {
  out[[i]] <- data.frame(run = i,
                         est = round(rnorm(1), 3))
}

out                                # a list of three data frames
do.call(rbind, out)                # stack them into one data frame

# do.call(rbind, ...) is the base-R way to say "stack all of these." It looks
# strange the first time. tidyverse has a friendlier version




# 6. for loops -----------------------------------------

# Most of statistics is doing something many
# times and looking at the distribution of what comes out.

# A for loop says: for each value in this list, run this block.
for (i in 1:5) {
  print(i)
}

# `i` is just a name; it takes each value in turn. It can walk over anything:
for (city_name in c("Milwaukee", "Madison", "Green Bay")) {
  print(paste("Sending testers to:", city_name))
}

# The useful pattern is: make an empty container, fill it, look at it.
results <- rep(NA, 5)      # five empty slots
results

for (i in 1:5) {
  results[i] <- i * 10     # put something in slot i
}
results


# A summation is a for loop. 
# The sum from i = 1 to 4 of x_i:
x <- c(2, 5, 1, 4)

total <- 0
for (i in 1:length(x)) {
  total <- total + x[i]
  print(total)             # watch it accumulate
}
total
sum(x)                     # same answer




## Conditionals: if and else ----------------------------------------------

# ifelse() from section 4 works on whole vectors. When you need to branch
# once, on a single value -- usually inside a loop -- you want if/else:

roll <- 4
if (roll > 3) {
  print("high")
} else {
  print("low")
}



# Inside a loop:
for (i in 1:6) {
  if (i %% 2 == 0) {       # %% is the remainder after division
    print(paste(i, "is even"))
  } else {
    print(paste(i, "is odd"))
  }
}




# 7. Randomness and simulation --------------------------------------------

# sample() draws from a set of things.
sample(1:6, size = 1)                       # one roll of a die
sample(1:6, size = 10, replace = TRUE)      # ten rolls
?sample                                     # read what `replace` does


yahtzee <- sample(seq(1, 6), 5, replace = T)
yahtzee

if(length(unique(yahtzee)) == 1){
  print("YAHTZEE")
} else {
  print("Roll again")
}



# Random means random -- you get different answers each run. set.seed() fixes
# the starting point so your results reproduce. Use it in anything you turn in.
set.seed(1234)
sample(1:6, size = 10, replace = TRUE)

set.seed(1234)
sample(1:6, size = 10, replace = TRUE)      # identical


# rnorm() draws from a normal distribution instead of from a set:
rnorm(5, mean = 0, sd = 1)
hist(rnorm(10000, mean = 0, sd = 1))


# Now put the loop and the randomness together.
#
# Pager sent 696 applications. Suppose the true callback rate were 16% and
# nothing else were going on. How much would the observed rate bounce around
# from one study to the next, purely by luck?

set.seed(1234)
n_studies      <- 1000
observed_rates <- rep(NA, n_studies)

for (i in 1:n_studies) {
  one_study <- sample(c(0, 1), size = 696, replace = TRUE, prob = c(0.84, 0.16))
  observed_rates[i] <- mean(one_study)
}

hist(observed_rates)
mean(observed_rates)
sd(observed_rates)

# This is a sampling distribution by brute force
#
# Now compare that standard deviation to the textbook standard error:
sqrt(0.16 * 0.84 / 696)

# They agree to three decimal places




# 8. Functions ------------------------------------------------------------

# When you find yourself typing the same thing repeatedly, name it.
# We've already been using a lot of built-in functions
# We'll add lots more of these through packages in the next session

callback_rate <- function(data, condition) {
  mean(data$callback[condition])
}

callback_rate(d, d$crimrec == 1)
callback_rate(d, d$crimrec == 0)
callback_rate(d, d$black == 1 & d$crimrec == 0)

# The anatomy:
#   name <- function(arguments) {  body; the last line is what comes back  }

# Arguments can have defaults, which makes them optional when you call it:
callback_penalty <- function(data, subset_condition = TRUE) {
  sub <- data[subset_condition, ]
  mean(sub$callback[sub$crimrec == 0]) - mean(sub$callback[sub$crimrec == 1])
}

callback_penalty(d)                     # everyone
callback_penalty(d, d$black == 0)       # white testers only
callback_penalty(d, d$black == 1)       # Black testers only






## Writing a function properly: variance from scratch ----------------------

# The variance of a vector is  (1 / (n - 1)) * sum of squared deviations.
# Write it out yourself rather than calling var():

my_var <- function(v) {
  n         <- length(v)
  deviation <- v - mean(v)
  squared   <- deviation^2
  return(sum(squared) / (n - 1))
}

my_var(x)
var(x)          # check yourself against R's version

# Note there is no loop in there. `v - mean(v)` subtracts the mean from every
# element at once. Vectorized code is shorter AND faster than a loop; reach
# for the loop when the steps genuinely depend on each other.




# 9. Build a world (a simulation) -------------------------------

# SIMULATE data where you set the truth yourself, then check whether your
# method recovers it

# What's the probability of rolling a yahtzee?
# Simulated first:

yahtzee <- NA

for(i in 1:10000){
  
  roll <- sample(seq(1:6), 5, replace=T)
  yahtzee[i] <- ifelse(length(unique(roll)) == 1, "yahtzee", "no yahtzee")
  
}

options(scipen = 999)
as.numeric(prop.table(table(yahtzee))[2])

# Analytically?
1 * 1/6 * 1/6 * 1/6 * 1/6

## Why might we want to repeat this simulation repeatedly?


## simulating a more complicated DGP


set.seed(27511)
n <- 1000

# Something real that we cannot measure -- call it motivation.
motivation <- rnorm(n, mean = 0, sd = 1)


# What happens to each person WITHOUT a job-training program, and WITH it.
# Outcome is weeks to employment, so lower is better.
#
# We are declaring the true effect to be exactly -4 weeks. There is no
# uncertainty about this. We made it up.
y0  <- 20 - 3 * motivation + rnorm(n, mean = 0, sd = 2)
y1  <- y0 - 4
tau <- y1 - y0

pop <- data.frame(motivation, y0, y1, tau)
head(pop)
mean(pop$tau)     # -4, as constructed

# Look at what we have that no real researcher ever has: BOTH columns. We can
# see what every person would do under treatment AND under no treatment.




## 9a. Let people choose ---------------------------

# In the real world, motivated people sign up for the program.
pop$t_self <- ifelse(pop$motivation > median(pop$motivation), 1, 0)


# And we only ever observe ONE of y0, y1 per person -- whichever one their
# treatment status reveals. That is the fundamental problem of causal
# inference, and here it is in one line:
pop$y_obs <- ifelse(pop$t_self == 1, pop$y1, pop$y0)


# Now do the obvious: compare the two observed groups.
mean(pop$y_obs[pop$t_self == 1]) - mean(pop$y_obs[pop$t_self == 0])


# That is roughly -9. The truth is -4. We just overstated the program's
# benefit by more than double, using a completely standard comparison, on
# data with no measurement error and a sample of 1,000.
#
# Why? Because we can peek at the column you can't observe in real life --
# what the enrolled group WOULD have done untreated:
mean(pop$y0[pop$t_self == 1]) - mean(pop$y0[pop$t_self == 0])

# The people who enrolled were already going to do better. That is selection bias.

# The decomposition, checked numerically:  naive = ATT + bias
att  <- mean(pop$tau[pop$t_self == 1])
bias <- mean(pop$y0[pop$t_self == 1]) - mean(pop$y0[pop$t_self == 0])
att + bias
mean(pop$y_obs[pop$t_self == 1]) - mean(pop$y_obs[pop$t_self == 0])



## 9b. Now randomize ------------------------------------------------------

set.seed(7)
pop$t_rand    <- sample(c(0, 1), size = n, replace = TRUE)
pop$y_obs_rnd <- ifelse(pop$t_rand == 1, pop$y1, pop$y0)

mean(pop$y_obs_rnd[pop$t_rand == 1]) - mean(pop$y_obs_rnd[pop$t_rand == 0])

# Close to -4. And the bias term:
mean(pop$y0[pop$t_rand == 1]) - mean(pop$y0[pop$t_rand == 0])

# Near zero. Look at why 
mean(pop$motivation[pop$t_self == 1]); mean(pop$motivation[pop$t_self == 0])
mean(pop$motivation[pop$t_rand == 1]); mean(pop$motivation[pop$t_rand == 0])

# Randomization did not remove motivation from the world. It made the two
# groups have the SAME amount of it. T



# EXERCISE 2 ==============================================================
#
# About 10 minutes. You have a world you built, tiem to break it
#
# For each one: PREDICT what will happen before you run it. Write the
# prediction down. Then change the code above, re-run section 9, and see.
#
#
# 1) Change the true treatment effect from -4 to -8 (the y1 line).
#    Re-run 9 and 9a.
#      - Does the naive estimate move?
#      - Does the SELECTION BIAS term move?
#    Explain what that tells you about where bias comes from.
#
#
# 2) Put the effect back to -4. Now change the -3 on motivation in the y0
#    line to 0, so motivation no longer affects the outcome at all --
#    but leave the enrollment rule alone, so motivated people still enroll.
#    Re-run.
#      - What happened to the bias?
#      - State the lesson in one sentence: for a variable to confound your
#        comparison, what does it have to be related to?
#
#
# 3) Put the -3 back. Now change the enrollment rule in 9a so people enroll
#    on a coin flip instead of by motivation:
#        pop$t_self <- sample(c(0, 1), size = n, replace = TRUE)
#    Re-run. What is the bias now, and why?
#
#
# (*) FINISHED EARLY?
#
#   Make enrollment depend on motivation only WEAKLY -- say, people above the
#   80th percentile of motivation enroll with probability 0.7 and everyone
#   else with probability 0.4. (rbinom() or runif() will do it.) Is the bias
#   smaller? Is it gone? What does that suggest about "controlling for"
#   things you can only partly measure?
#
# =========================================================================



# 10. Getting unstuck ------------------------------------------------------
# If time is available

# mean(dd$callback)
#   Error: object 'dd' not found
#   -> you typo'd a name, or you never made that object. Check the
#      Environment pane for what actually exists.

# read.csv("criminalrecord.csv")
#   Error: cannot open file 'criminalrecord.csv': No such file or directory
#   -> almost always the working directory. Run getwd() and list.files().

# mean(d$grup)
#   NULL / NA
#   -> a misspelled COLUMN does not error, it returns NULL. This one is
#      nasty because it fails quietly. names(d) is your friend.

# The debugging loop, in order:
#   1. Read the message. Actually read it -- the useful part is usually the
#      last line, and it usually names the thing that went wrong.
#   2. Look at the object. str() and head(). Most bugs are "this is not the
#      shape I thought it was."
#   3. Run the pieces separately. If f(g(x)) breaks, run g(x) alone.
#   4. ?function_name for the arguments you are getting wrong.
#   5. Search the exact error text, in quotes, minus your variable names.
#   6. Ask a person.




# =========================================================================
# PART B 
# =========================================================================


## B1. One run is not enough ----------------------------------------------

# Section 9 randomized ONCE. That is a single study. The promise of
# randomization is not about a single study, and to see what it is actually
# about you have to run the study many times.
#
# Same container-loop-fill pattern from section 6.

set.seed(555)
estimates <- rep(NA, 1000)

for (i in 1:1000) {
  t_i <- sample(c(0, 1), size = n, replace = TRUE)
  y_i <- ifelse(t_i == 1, pop$y1, pop$y0)
  estimates[i] <- mean(y_i[t_i == 1]) - mean(y_i[t_i == 0])
}

hist(estimates)
abline(v = -4, col = "red", lwd = 2)
mean(estimates)
sd(estimates)

# a) Is any single estimate exactly -4?
# b) Is the AVERAGE of the 1000 estimates close to -4?
# c) Those are different questions. Which one is the promise that
#    randomization actually makes? Two or three sentences.


