## ui.R
library(shiny)
library(shinydashboard)
library(data.table)
library(shinyRatings)
library(shinyjs)
library(tidyverse)

shinyUI(
  dashboardPage(
    skin ="purple",
    dashboardHeader(title = "Movie Recommendations",
                    titleWidth = 300),
    dashboardSidebar(
      width = 300,
      sidebarMenu(
        # Setting id makes input$tabs give the tabName of currently-selected tab
        id = "tabs",
        menuItem("Recommendations by Genre", tabName = "genre", icon = icon("dashboard")),
        menuItem("Recommendations by Rating", icon = icon("star"), tabName = "rating")
      )
    ),
    dashboardBody(includeCSS("css/movies.css"),
                  tabItems(
                    tabItem(
                      tabName = "genre",
                      fluidRow(
                        box(width = 12, title = "Step 1: Select Your Favorite Genre", status = "info", solidHeader = FALSE, collapsible = TRUE,
                            div(class = "genreitems",
                                uiOutput('genres_dropdown')
                            )
                        )
                      ),
                      fluidRow(
                        useShinyjs(),
                        box(
                          width = 12, status = "info", solidHeader = FALSE,
                          title = "Step 2: Discover movies you may like",
                          br(),
              
                            actionButton("btnGenre", "Click to get your recommendations", class = "btn-success")
                          
                          ,
                          br(),
                          tableOutput("results_by_genre")
                        )
                      )
                    ),
                    tabItem(
                      tabName = "rating",
                      fluidRow(
                        box(width = 12, title = "Step 1: Rate as many movies as possible", status = "info", solidHeader = FALSE, collapsible = TRUE,
                            div(class = "rateitems",
                                uiOutput('ratings')
                            )
                        )
                      ),
                      fluidRow(
                        useShinyjs(),
                        box(
                          width = 12, status = "info", solidHeader = FALSE,
                          title = "Step 2: Discover movies you might like",
                          br(),
                          
                            actionButton("btn", "Click to get your recommendations", class = "btn-success")
                          
                          ,
                          br(),
                          tableOutput("results")
                        )
                      )
                    )
                  )
    )
  )
)