dashboardPage(
    dashboardHeader(title='2021 New York City Municipal Elections, Primaries'),
    dashboardSidebar(
        sidebarUserPanel('Julie Hemily'),
        sidebarMenu(
            menuItem("Introduction", tabName = "intro", icon = icon("angle-right")),
            menuItem("Council by District", tabName = "coun", icon = icon("angle-right")),
            menuItem("Mayor's Race", tabName = "mayor", icon = icon("angle-right")),
            menuItem("Conclusion", tabName = "conc", icon = icon("angle-right"))            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = 'intro',
                    fluidPage(
                    fluidRow(column(offset = 2, width = 8, h1(tags$b("NYC Municipal Elections")))),
                        br(),
                    fluidRow(
                            p("The New York City municipal primary elections took place on June 22, 2021.  Because 
                              of term limits, there were a record breaking number of seats available.  In the running 
                              were the positions of Democratic nominee for XXX city council seats.  Eleven of these races 
                              involved an incumbent taking on new challengers.  As well, the role of city Comptroller,
                              Public Advocate, Judiciary Seats, Borough Presidents, and Mayor were all up for grabs."), 
                            p("The Campaign Finance Board keeps detailed records of both contributions and expenditures
                              of all candidates in the race.  The publish all of this data on their website where it 
                              can be downloaded and analysed.  I decided to look into this past election cycle, looking 
                              into what types of considerations should be made for any new potential candidates that 
                              would like to break into NYC municipal politics in the future."),
                            p("The General Election for all of these races will take place in November, 2021.")
                         
                    )
                    )
            ),
            tabItem(tabName = 'coun',
                    fluidPage(
                        fluidRow(column(offset = 2, width = 8, h1(tags$b("Election Results by District")))),
                        br(),
                        fluidRow(
                            column(10, plotOutput('votes'))
                        ),
                        fluidRow(column(offset = 2, width = 8, h1(tags$b("   ")))),
                        selectizeInput(inputId='dist',
                                       label='Select a City Council District',
                                       choices = unique(nyc.results$district[!is.na(nyc.results$district)])
                        ),
                        fluidRow(
                            offset = 0, width = 20,
                            p("Some words, more words, more words, <ul><li>...text...</li><li>, then words"),
                        )
                    ) 
            ),
            tabItem(tabName = 'mayor'
                    #,
                    # fluidPage(
                    #     fluidRow(column(offset = 2, width = 8, h1(tags$b("Election Results by District")))),
                    #     br(),
                    #     fluidRow(
                    #         column(10, plotOutput('votes'))
                    #     ),
                    #     fluidRow(column(offset = 2, width = 8, h1(tags$b("   ")))),
                    #     selectizeInput(inputId='dist',
                    #                    label='Select a City Council District',
                    #                    choices = unique(nyc.results$district[!is.na(nyc.results$district)])
                    #     ),
                    #     fluidRow(
                    #         offset = 0, width = 20,
                    #         p("Some words, more words, more words, <ul><li>...text...</li><li>, then words"),
                    #     )
                    # ) 
            ),
            tabItem(tabName = 'conc',
                    fluidPage(
                        fluidRow(column(offset = 2, width = 8, h1(tags$b("Conclusion")))),
                        br(),
                        fluidRow(
                            offset = 0, width = 20,
                                p("Throughout this work, I looked into the factors that should be 
                                  considered for any potential candidate looking to enter the field as a 
                                  city council candidate.  The biggest result is that proper fundraising 
                                  early in the process is critical to keeping up in the race. However, 
                                  finances alone are not sufficient to wint a race.  There are many other
                                  factors that influence the outcomes.  These are left for future work."),
                                p("Some highlights of the discoveries include: avoiding races with incumbents, securing
                                  strong financing early on, expecting to spend around $200,000 for a city council 
                                  campaign, a large part of which will be dedicated to advertising and wages."),
                                p("Future work should look into the critical points in the campaign period and what 
                                  other factors influence outcomes.  Aligning census data with voting trends and
                                  including polling and qualitative criteria will help with a better understanding of
                                  the contests.")
                        ),
                        fluidRow(
                            column(10, plotOutput('spending'))
                        )
                    ) 
                    
            )
        )
    )
)
# dashboardBody(
#     tabItems(
#         tabItem(tabName = 'plots',
#                 fluidRow(
#                     column(5, plotOutput("count")),
#                     column(7, plotOutput("delay"))
#                 )),
#         tabItem(tabName = 'data', dataTableOutput('table'))
#     )
# )

# dashboardPage(
#     dashboardHeader("Municipal Primaries, June 2021"),
#     dashboardSidebar(
#         # selectizeInput(inputId = "dist",
#         #                label = "City Council District",
#         #                choices = unique(nyc.results$district[!is.na(nyc.results$district)]))
#     ),
#     dashboardBody(
#         # plotOutput("votes")
#     )
# )


# fluidPage(
#   titlePanel("Municipal Primaries, June 2021"),
#   sidebarLayout(
#     sidebarPanel(
#       selectizeInput(inputId = "dist",
#                      label = "City Council District",
#                      choices = unique(nyc.results$district[!is.na(nyc.results$district)]))
#     ),
#     mainPanel(plotOutput("votes"))
#   )
# )



