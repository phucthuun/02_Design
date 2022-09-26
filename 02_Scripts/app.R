rm(list = ls())

{
  library(rstudioapi)
  library(dplyr)
  library(stringr)
  library(reshape2)
  library(ggplot2)
  library(tidyverse)
}
{
  directory <- dirname(getSourceEditorContext()$path) %>% str_extract(pattern = ".+(?<=Design)")
  datapath <- file.path(directory, "01_Data")
  visualpath <- file.path(directory, "03_Visualization")
  
  Palette_AreaAbs <- c('#363285', '#1e9dca', '#9fd6e5', '#da3893', '#f6897e', '#e32526',
                       '#036b2d', '#3bb54f', '#90f3ab', '#f2de42', '#fd9727', '#8e5412')
}
{
  # Get df and specs
  # Choose file name
  filenames <- c(
    "senspatt.txt","motpatt.txt","auditpatt_CN.txt","artipatt_CN.txt",   
    "senspatt.txt","motpatt.txt","auditpatt_DN.txt","artipatt_DN.txt"
  )
  AreaAbs <- c("V1","M1[L]","A1","M1[i]","V1","M1[L]","A1","M1[i]")
  Type <- rep(c("Category Label", "Proper Name"), each=4)

  df <- data.frame()
  for (i in 1:8) {
    current.df <- read.table(file.path(datapath, filenames[i]), header = F, sep = ";") %>%
      mutate(
        Pattern = paste0(rep(c(letters[1:10]), 3), rep(c(1:3), each = 10)),
        Concept = rep(c(letters[1:10]), 3),
        Type = Type[i],
        AreaAbs = AreaAbs[i],
      ) %>%
      melt(id = c("Concept", "Pattern", "Type", "AreaAbs"), value.name = "CAcell", variable.name = "celltype") %>%
      mutate(Pattern = case_when(
        celltype %in% c("V1", "V2", "V3", "V4", "V5", "V6") & AreaAbs %in% c("V1","M1[L]") ~ "shared",
        celltype %in% c("V7", "V8", "V9", "V10", "V11", "V12") & AreaAbs %in% c("V1","M1[L]") ~ Pattern,
        AreaAbs %in% c("A1","M1[i]") & Type == 'Category Label' ~ "shared",
        AreaAbs %in% c("A1","M1[i]") & Type == 'Proper Name' ~ Pattern
      )) %>%
      select(-celltype)

    df <- rbind(df, current.df)
  }



  a <- t(array(1:625, dim = c(25, 25))) %>% as.data.frame()
  names(a) <- c(1:25)
  a <- a %>%
    rownames_to_column(var = "y")
  b <- melt(a, id.vars = "y", variable.name = "x", value.name = "CAcell") %>%
    mutate(x = as.numeric(x), y = as.numeric(y))

  df <- left_join(df, b, by = "CAcell")%>%
    mutate(AreaAbs=factor(AreaAbs, levels =  c('V1','TO','AT','PF[L]','PM[L]','M1[L]','A1','AB','PB','PF[i]','PM[i]','M1[i]')),
           Concept = as.factor(Concept),
           Type = as.factor(Type)) %>%
    distinct()
  
  df.template <- expand.grid(
    Concept = letters[1:10],
    Pattern = 1:3,
    AreaAbs = factor(c('V1','TO','AT','PF[L]','PM[L]','M1[L]','A1','AB','PB','PF[i]','PM[i]','M1[i]'), 
                     levels =  c('V1','TO','AT','PF[L]','PM[L]','M1[L]','A1','AB','PB','PF[i]','PM[i]','M1[i]')),
    Type = c("Category Label", "Proper Name"),
    CAcell = 1, x=1, y=1) %>%
    mutate(Pattern=paste0(Concept,Pattern))
}


# ui ----
ui = navbarPage(id = 'wholePage',
                # App Title
                # title=div(img(src="LOGO_BLL_long_high-removebg-preview.png", height = "110px",width = "372px")),
                title = '',
                theme = shinytheme("cosmo"),
                
                ## EXPLORE ----
                tabPanel('EXPLORE',
                         fluidRow(class='explore',
                                  column(1), 
                                  column(10, 
                                         p(),
                                         
                                         dashboardPage(
                                           dashboardHeader(disable=T),
                                           dashboardSidebar(disable=T,collapsed=T,width=0.00001),
                                           dashboardBody(
                                             
                                             fluidRow(class='exploreSearch',
                                                      column(3),
                                                      column(6,
                                                             box(title = NULL, solidHeader = TRUE, status = 'warning', width = NULL,
                                                                 sliderTextInput("instance_id","Select instance" , 
                                                                                 choices = 1:3, 
                                                                                 # selected = c("January", "February", "March", "April"), #if you want any default values 
                                                                                 animate = FALSE, grid = FALSE, 
                                                                                 hide_min_max = FALSE, from_fixed = FALSE,
                                                                                 to_fixed = FALSE, from_min = NULL, from_max = NULL, to_min = NULL,
                                                                                 to_max = NULL, force_edges = FALSE, width = NULL, pre = NULL,
                                                                                 post = NULL, dragRange = TRUE),
                                                                 sliderTextInput("concept_id","Select category" , 
                                                                                 # choices = unique(df$Concept),
                                                                                 choices = letters[1:10],
                                                                                 animate = FALSE, grid = FALSE, 
                                                                                 hide_min_max = FALSE, from_fixed = FALSE,
                                                                                 to_fixed = FALSE, from_min = NULL, from_max = NULL, to_min = NULL,
                                                                                 to_max = NULL, force_edges = FALSE, width = NULL, pre = NULL,
                                                                                 post = NULL, dragRange = TRUE),
                                                                 # selectizeInput("concept_id", "Select category", choices = unique(df$Concept), multiple = F)
                                                             )),
                                                      column(3)
                                             ),
                                             
                                             
                                             ### Plot CL ====
                                             fluidRow(
                                               box(title = NULL, solidHeader = T, status = 'warning', width = NULL,
                                                   column(6,
                                                          strong("CATEGORY LABEL", style = "color: #428BCA"),
                                                          plotOutput("illustration_CL")%>% withSpinner(type=4,color="#428BCA")),
                                                   column(6,
                                                          strong("PROPER NAME", style = "color: #428BCA"),
                                                          plotOutput("illustration_PN")%>% withSpinner(type=4,color="#428BCA"))
                                               )
                                             )
                                           )
                                         )
                                  ),
                                  
                                  column(1)
                         )
                ),
                tags$head(
                  tags$style(
                    HTML('
            #about {background-color: #DEDEDE;}
            .navbar {background-color: #428BCA !important;}
            .navbar-default .navbar-brand{background-color: #428BCA; color: white;}
            .navbar-default .navbar-nav > .active > a, 
            .navbar-default .navbar-nav > .active > a:focus,
            .navbar-default .navbar-nav > .active > a:hover {background-color: #00548D;}
            
            .navbar-header { width:100% }
            .navbar-nav > li > a, 
            .navbar-brand {padding-top:4px !important; padding-bottom:0px !important; height: 60px; width: 100%; text-align: right;font-size: 20px;  }
            
            .skin-blue .main-sidebar {background-color:  #eeeeee;}
            .overview{background-color: #eeeeee;}
            .explore{background-color: #eeeeee;}
            
            /* body */
            .content-wrapper, .right-side {background-color: #eeeeee;}
            .content-wrapper, .left-side {background-color: #eeeeee;}
            .skin-blue .left-side, .skin-blue .wrapper {
                        background-color: #eeeeee;
                        }
             
            .overview .box.box-solid.box-warning>.box-header {color:#000000; background:#ffff;}
            .overview .box.box-solid{background: #ffffff; border-bottom-color:#428BCA; border-left-color:#428BCA; border-right-color:#428BCA; border-top-color:#428BCA;}
            
            .explore .box.box-solid.box-warning>.box-header {color:#000000; background:#ffff;}
            .explore .box.box-solid{background: #ffffff; border-bottom-color:#428BCA; border-left-color:#428BCA; border-right-color:#428BCA; border-top-color:#428BCA;}
            
            .exploreSearch .box.box-solid{background: #ffffff !important; border-bottom-color:#ffffff !important; border-left-color:#ffffff !important; border-right-color:#ffffff !important; border-top-color:#ffffff !important;}
            
            
            /* collapse button*/
            .fa, .fas {color: black;}
            
            /*notification/
            .shiny-notification-error {background-color:#428BCA; color: #ffffff} 
            
                 ')))
                
                
                
)


# server ----
server <- function(input, output, session) { 
  
  # Preprocess outputs----
  # Make reactive to store filter criteria
  input.instance_id <- reactive({return(paste0(input$concept_id,input$instance_id))})
  
  # concept_id input
  input.concept_id <- reactive({return(input$concept_id)})
  
  # Make binary df
  df.new.plot <- reactive({ 
    
    
    
    df %>% filter(Concept == input.concept_id()&Pattern %in% c('shared',input.instance_id()))
    
  })
  
  df.template.new.plot <- reactive({ 
    
    df.template %>% filter(Concept == input.concept_id())
    
  })
  
 
  ## PN ----
  ### Display output
  
  # Plot
  output$illustration_PN <- renderPlot({
    
    input.concept_id
    
    # CL
   ( pB=ggplot(df.new.plot() %>% filter(Type=='Proper Name'))+
      geom_point(aes(x=x,y=y, color=Pattern), size = 2.5)+
      geom_point(data=df.template.new.plot()%>% filter(Type=='Proper Name'),
                 aes(x=x,y=y, color=Pattern), size = 2.5, alpha = 0)+
      scale_color_manual(name = 'Training instance', values = c('#FF6F91','#1CB755','#569CFF','black'), drop=F)+
      scale_y_reverse(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
      scale_x_continuous(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
      facet_wrap(~AreaAbs, nrow = 2, labeller=label_parsed)+
      theme(aspect.ratio = 1,
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            legend.position="bottom",
            legend.title=element_text(size=25), 
            legend.text=element_text(size=20),
            strip.text.x = element_text(size = 15),
            strip.text.y = element_text(size = 15)))
    
    gB <- ggplot_gtable(ggplot_build(pB))
    stripr <- which(grepl('strip-t', gB$layout$name))
    fills <- Palette_AreaAbs
    k <- 1
    for (i in stripr) {
      j <- which(grepl('rect', gB$grobs[[i]]$grobs[[1]]$childrenOrder))
      gB$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- fills[k]
      k <- k+1
    }
    
    grid.draw(gB)
    
    
  })
  
  
  ## CL ----
  output$illustration_CL <- renderPlot({
    
    # CL
    pA=ggplot(df.new.plot() %>% filter(Type=='Category Label'))+
      geom_point(aes(x=x,y=y, color=Pattern), size = 2.5)+
      geom_point(data=df.template.new.plot()%>% filter(Type=='Category Label'),
                 aes(x=x,y=y, color=Pattern), size = 2.5, alpha = 0)+
      scale_color_manual(name = 'Training instance', values = c('#FF6F91','#1CB755','#569CFF','black'), drop=F)+
      scale_y_reverse(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
      scale_x_continuous(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
      facet_wrap(~AreaAbs, nrow = 2, labeller=label_parsed)+
      theme(aspect.ratio = 1,
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            legend.position="bottom",
            legend.title=element_text(size=25), 
            legend.text=element_text(size=20),
            strip.text.x = element_text(size = 15),
            strip.text.y = element_text(size = 15))
    
    gA <- ggplot_gtable(ggplot_build(pA))
    stripr <- which(grepl('strip-t', gA$layout$name))
    fills <- Palette_AreaAbs
    k <- 1
    for (i in stripr) {
      j <- which(grepl('rect', gA$grobs[[i]]$grobs[[1]]$childrenOrder))
      gA$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- fills[k]
      k <- k+1
    }
    
    grid.draw(gA)
    
  })
  
  
}


shinyApp(ui, server)
