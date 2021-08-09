# library(shiny)
# library(dplyr)
# library(ggplot2)
# # nyc.results <- read.csv(file = "./project/nyc2021primary/electionApp/data/results.csv")
# nyc.results <- read.csv(file = "./data/results.csv")

function(input, output) {
    # output$votes <- renderPlot(
    #     flights %>%
    #         filter(origin == input$origin & dest == input$dest) %>%
    #         group_by(carrier) %>%
    #         count() %>%
    #         ggplot(aes(x = carrier, y = n)) +
    #         geom_col(fill = "lightblue") +
    #         ggtitle("Number of flights"),
    #     xlab('airlines')
    # )
    output$votes <- renderPlot(
        nyc.results %>%
            filter(district == input$dist) %>%
            dplyr::select(cand, votes_1) %>%
            ggplot(aes(x = cand, y = votes_1, fill= 'dark blue')) + 
            geom_col() +
            coord_flip() + 
            xlab('candidate') + 
            ylab('percentage of round 1 votes')
    )
    output$spending <- renderPlot(
        ggplot(cc.expense.clean) + geom_hline(yintercept = 0, color = "black") + 
            geom_vline(xintercept = 0, color = "black") +
            geom_point(aes(x=spend.diff, y=pc.diff), color='#b1ddf9') +
            labs(x="Spending difference relative to district field ($)", 
                 y="Difference in First Round Vote %", 
                 title="Influence of Overspending or Underspending on Votes attained (%)")
    ) 
    output$myList <- renderUI(HTML("<ul><li>...text...</li><li>...more text...</li></ul>"))
    # output$expenses <- renderPlot(
    #     nyc.results %>%
    #         filter(district == input$dist) %>%
    #         select(cand, votes_1) %>%
    #         ggplot(aes(x = cand, y = votes_1)) + geom_col()
    # )
}

# dist = 35
# arg2 <- nyc.results %>%
#     filter(district == dist) %>%
#     select(cand, votes_1) 
# 
# ggplot(arg2, aes(x = cand, y = votes_1)) + geom_col()

# function(input, output) {
#   output$count <- renderPlot(
#     flights %>%
#       filter(origin == input$origin & dest == input$dest) %>%
#       group_by(carrier) %>%
#       count() %>%
#       ggplot(aes(x = carrier, y = n)) +
#       geom_col(fill = "lightblue") +
#       ggtitle("Number of flights"),
#       xlab('airlines')
#   )
#   output$delay <- renderPlot(
#     flights %>%
#       filter(origin == input$origin_ui & dest == input$dest_ui) %>%
#       group_by(carrier) %>%
#       summarise( n = n() , arrdelay = mean(arr_delay), depdelay=mean(dep_delay)) %>%
#       pivot_longer(c(arrdelay,depdelay),names_to="type",values_to="delay") %>%
#       ggplot(aes(x =carrier,y=delay)) +
#       geom_col(aes(fill=type),position = "dodge")+
#       ggtitle("Avg delay")
#   )
# }