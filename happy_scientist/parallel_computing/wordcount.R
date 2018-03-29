library(foreach)
library(doParallel)

countWords <- function(txt) {
    txt <- gsub("[[:punct:]]+", "", txt)
    txt <- gsub("[[:digit:]]+", "", txt)
    txt <- gsub("[-']", "", txt)
    txt <- trimws(txt, "left")
    allWords <- unlist(strsplit(tolower(txt), "[[:space:]]+"))
    as.list(table(allWords))
}

con <- file("ulysses.txt", open = "r", encoding = "UTF-8")
system.time(wordResults <- foreach(x = ireadLines(con, n = 1000)) %do% {
    countWords(x)
})
close.connection(con)

con <- file("ulysses.txt", open = "r", encoding = "UTF-8")
registerDoParallel(4)
system.time(wordResults <- foreach(x = ireadLines(con, n = 1000)) %dopar% {
    countWords(x)
})
close.connection(con)

finalCount <- aggregate(values ~ ind, stack(unlist(do.call(c, wordResults))), sum)




