server <- function(input, output, session) {
#WATER SUPPLY TAB ====================================================================================================
  #VALUE BOX FOR MAX DAILY MEAN LAKE LEVEL  --------------------------------------------------------------------------
  output$MaxLevel <- renderValueBox({
    df_daily_mean_filtered <- df_daily_mean %>%
      filter(Year == max(Year))
    
      valueBox(
        value = paste0(round(max(df_daily_mean_filtered$LEVEL), digits = 2), " m"),
        subtitle = paste0("The highest daily mean level recorded for ", max(df_daily_mean_filtered$Year)),
        icon = icon("arrow-down-up-across-line"),
        color = "orange"
      )
  })
  
  #VALUE BOX FOR MIN DAILY MEAN LAKE LEVEL  --------------------------------------------------------------------------
  output$MinLevel <- renderValueBox({
    df_daily_mean_filtered <- df_daily_mean %>%
      filter(Year == max(Year))
    
    valueBox(
      value = paste0(round(min(df_daily_mean_filtered$LEVEL), digits = 2), " m"),
      subtitle = paste0("The lowest daily mean level recorded for ", max(df_daily_mean_filtered$Year)),
      icon = icon("arrow-down-up-across-line"),
      color = "teal"
    )
  })
  
  #YOY MIN LAKE LEVEL ------------------------------------------------------------------------------------------------
  output$YoYMinLevel <- renderValueBox({
    
    current_period <- df_daily_mean %>%
      filter(Year == max(Year))
    
    prev_period <- df_daily_mean %>%
      filter(Year == max(Year) -1)
    
    YoY_change <- (min(current_period$LEVEL, na.rm = TRUE) - min(prev_period$LEVEL, na.rm = TRUE)) * 100
    
    YoY_change <- round(YoY_change, 1)
      
    valueBox(
      value = paste0(
        if (YoY_change > 0) "+" else "", YoY_change, " cm"
      ),
      subtitle = paste0(
        if (YoY_change > 0) paste0("Lowest daily mean level recorded is higher")
        else if (YoY_change < 0) paste0("Lowest daily mean level recorded is lower")
        else paste0("Lowest daily mean level recorded is the same"),
        " from ", max(df_daily_mean$Year) - 1
      ),
      icon = if (YoY_change > 0) icon("arrow-up") else if (YoY_change == 0) icon("minus") else icon("arrow-down"),
      color = "orange"
    )
  })
  
  #VALUE BOX FOR NET INFLOW  --------------------------------------------------------------------------
  output$InflowValueBox <- renderValueBox({
    valueBox(
      value = paste0(scales::comma(current), " ac-ft"),
      subtitle = paste0("Net inflow for the week ending ", format(latest$`Week ending`, "%B %d, %Y")),
      icon = icon("water"),
      color = "teal"
    )
  })
  
  #NET INFLOWS BAR CHART ---------------------------------------------------------------------------------------------
  output$netInflowPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_netInflowPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_long <- df_inflow %>%
      pivot_longer(
        cols = c(`1944-2025 avg (ac-ft)`, `Current (ac-ft)`),
        names_to = "Series",
        values_to = "Inflow") %>%
      mutate(
        Series = recode(
          Series,
          `1944-2025 avg (ac-ft)` = "1944–2025 Average",
          `Current (ac-ft)` = "Current Water Year"
        )
     )
    
    plot <- ggplot(df_long, aes(x = `Week ending`,
                                y = Inflow,
                                fill = Series,
                                text = paste0(
                                  "<b>Week ending: ", `Week ending`, "</b><br>",
                                  Series, "<br>",
                                  "Inflow: ", Inflow, " (ac-ft)",
                                  ifelse(
                                    is.na(`% of average`),
                                    "",
                                    paste0("<br>% of Avg: ", `% of average`)
                                  )
                                )

                   ))+
      
      geom_col(
        position = position_dodge(width = 7),
        width = 7
      ) +
      
      scale_fill_manual(
        values = c(
          "1944–2025 Average" = "#BCB49E",
          "Current Water Year" = "#76ACA9"
        ),
        name = ""
      ) +
      
      scale_x_date(
        date_breaks = if (is_narrow) "2 months" else "1 month",
        date_labels = "%b\n%Y",
        expand = c(0, 0)
      ) +
      
      scale_y_continuous(
        breaks = seq(-10000, 50000, by = 10000),
        labels = function(x) paste0(x / 1000, "K")
      ) +
      
      labs(
        x = "",
        y = "Net Weekly Inflow Volume (acre-feet)"
      ) +
      
      theme(
        axis.title = element_text(size = if (is_narrow) 8 else 14),
        axis.text = element_text(size = if (is_narrow) 8 else 12),
        legend.text = element_text(size = if (is_narrow) 8 else 12),
        legend.position = "top"
      )
   
    ggplotly(plot, tooltip = "text") %>%
      layout(
        hoverlabel = list(
          bgcolor = "#004B55",
          bordercolor = "#004B55",
          font = list(
            color = "white",
            size = 13,
            family = "Arial"
          ),
          align = "left"
        ))%>%
       plotly::config(displayModeBar = FALSE)
  })
  
  #HISTORICAL RANGE FOR DAILY MEAN LAKE LEVEL LINE CHART -------------------------------------------------------------
  output$HistoricalDailyPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_HistoricalDailyPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_daily_historic <- df_daily_mean %>%
      filter(Year >= min(Year),
             Year <= max(Year) -1) %>%
      group_by(DayOfYear) %>%
      summarise(
        Historic_Min = min(LEVEL, na.rm = TRUE),
        Historic_Max = max(LEVEL, na.rm = TRUE),
        Historic_Mean = mean(LEVEL, na.rm = TRUE)
      )
    
    df_current_year <- df_daily_mean %>%
      filter(Year == max(Year))
    
    hist_color <- paste0("Historic Range ", min(df_daily_mean$Year), "-",  max(df_daily_mean$Year) -1)
    current_year <- max(df_current_year$Year)
    current_year_color <- paste0("Recent Year: ", current_year)
    
    plot <- ggplot() +
      
      geom_ribbon(data = df_daily_historic,
                  aes(x = DayOfYear, ymin = Historic_Min, ymax = Historic_Max, fill = "Historic Range", alpha = 0.5), show.legend = FALSE) +
      
      geom_line(data = df_daily_historic, 
                aes(x = DayOfYear, y = Historic_Mean, colour = "Historic Daily Mean"), linewidth = 1.5) +
      
      geom_line(data = df_current_year, aes(x = DayOfYear, y = LEVEL, colour = "Recent Year"),
                linewidth = 1.5) + 
      
      labs(
        x = "Month",
        y = "Daily Mean Water Level (m)"
      ) +
      
      scale_x_continuous(
        breaks = if (is_narrow) c(1, 91, 182, 274) else c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335),
        labels = if (is_narrow) month.abb[c(1, 4, 7, 10)] else month.abb,
        expand = c(0, 0)
      ) +
      
      scale_y_continuous(
        breaks = scales::breaks_pretty(10)) +
      
      scale_fill_manual(
        values = c("Historic Range" = "#76ACA9"),
        name = NULL
      ) +
      
      scale_colour_manual(
        values = c("Historic Daily Mean" = "#004B55", "Recent Year" = "#D11B4A"),
        labels = c("Historic Daily Mean", current_year_color),
        name = NULL
      ) +
      
      guides(
        color = if (is_narrow) guide_legend(ncol = 1) else guide_legend()
      ) +
      
      theme(axis.title = element_text(size = if (is_narrow) 10 else 16),
            axis.text = element_text(size = if (is_narrow) 10 else 12),
            legend.text = element_text(size = if (is_narrow) 8 else 12),
            legend.position = "top"
      )
    
   p <- ggplotly(plot)
   
   # Clean up the legend labels
   for (i in seq_along(p$x$data)) {
     trace <- p$x$data[[i]]
     
     if (!is.null(trace$name)) {
       
       if (grepl("Historic Range", trace$name, fixed = TRUE)) {
         
         p$x$data[[i]]$name <- hist_color
         
         p$x$data[[i]]$hovertemplate <-
           paste0(
             "<b>", hist_color, "</b>",
             "<br>Mean Water Level: %{y:.2f} m",
             "<extra></extra>"
           )
         
       } else if (grepl("Historic Daily Mean", trace$name, fixed = TRUE)) {
         
         p$x$data[[i]]$name <- "Historic Daily Mean"
         
         p$x$data[[i]]$hovertemplate <-
           paste0(
             "<b>Historic Daily Mean</b>",
             "<br>Mean Water Level: %{y:.2f} m",
             "<extra></extra>"
           )
         
       } else if (grepl("Recent Year", trace$name, fixed = TRUE)) {
         
         p$x$data[[i]]$name <- current_year_color
         
         p$x$data[[i]]$hovertemplate <-
           paste0(
             "<b>", current_year_color, "</b>",
             "<br>Mean Water Level: %{y:.2f} m",
             "<extra></extra>"
           )
       }
     }
   }
    p %>% plotly::config(displayModeBar = FALSE)
  })
  
#WATER CONSUMPTION TAB ===============================================================================================
  #VALUE BOX FOR TOTAL VOLUME OF CONSUMPTION  ------------------------------------------------------------------------
  output$TotalVol <- renderValueBox({
    total_consumption<- df_consumption_long %>%
      filter(Year == input$year_consumption) %>%
      summarise(
        total_consumption = sum(Consumption, na.rm = TRUE)
      ) %>%
      pull(total_consumption)

    valueBox(
      value = paste0(scales::comma(total_consumption), " m³"),
      subtitle = paste0("Total consumption for ", input$year_consumption),
      icon = icon("droplet"),
      color = "orange"
    )
  })
  
  #VALUE BOX FOR TOP PROVIDER CONSUMPTION  ---------------------------------------------------------------------------
  output$TopProvider <- renderValueBox({
    df_max_consumption<- df_consumption_long %>%
      filter(Year == input$year_consumption) %>%
      filter(Consumption == max(Consumption, na.rm = TRUE))
    
    valueBox(
      value = paste0(scales::comma(df_max_consumption$Consumption), " m³"),
      subtitle = paste0(df_max_consumption$MUN_NAME, " is the top provider for ", input$year_consumption),
      icon = icon("ranking-star"),
      color = "teal"
    )
  })
  
  #VALUE BOX FOR TOP PROVIDER CONSUMPTION  ---------------------------------------------------------------------------
  output$TopSource <- renderValueBox({
    df_consumption_count <- df_consumption_long %>%
      distinct(MUN_NAME, WATER_SOURCE) %>%
      count(WATER_SOURCE)
    
    valueBox(
      value = paste0(max(df_consumption_count$WATER_SOURCE)),
      subtitle = paste0("Top water source across providers"),
      icon = icon("water"),
      color = "orange"
    )
  })
  
  #COMPARE OKANAGAN PROVIDERS ANNUAL CONSUMPTION BAR CHART -----------------------------------------------------------
  output$ProvidersPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_ProvidersPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    filtered_df_consumption <- df_consumption_long %>%
      dplyr::filter(MUN_NAME %in% input$provider,
                    Year == input$year_consumption)
    
    plot <- ggplot(filtered_df_consumption, aes(x = MUN_NAME, 
                                                y = Consumption, 
                                                text = paste0("<b>", MUN_NAME, "</b><br>",
                                                              scales::comma(Consumption), " m³")
                                                )) +
        geom_col(fill = "#76ACA9", width = 0.5) +
        
        scale_y_continuous(
          breaks = if (is_narrow) scales::breaks_pretty(n = 4) else seq(0, 100000000, by = 2000000),
          labels = function(x) paste0(x / 1e6, "M"),
          expand = expansion(mult = c(0, 0.1))
        )+
        
        labs(
          x = "Provider",
          y = "Consumption (m³)") +
        theme(
          axis.title = element_text(size = if (is_narrow) 10 else 16),
          axis.text = element_text(size = if (is_narrow) 6 else 12),
          axis.text.x = element_text(
            angle = if (is_narrow) 60 else 30,
            hjust = 1,
            size = if (is_narrow) 6 else 10,
            vjust = 1
          )
        )
    
    ggplotly(plot, tooltip = "text") %>%
      layout(
        hoverlabel = list(
          bgcolor = "#004B55",
          bordercolor = "#004B55",
          font = list(
            color = "white",
            size = 13,
            family = "Arial"
          ),
          align = "left"
        ))%>%
      plotly::config(displayModeBar = FALSE)
  })

  #ANNUAL WATER CONSUMPTION BAR CHART --------------------------------------------------------------------------------
  output$ConsumptionPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_ConsumptionPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_consumption_long <- df_consumption_long %>%
      mutate(Year = as.numeric(Year)) %>%  #change Year string to number
      group_by(Year) %>%
      summarise(
        n_total = dplyr::n(), #Number of providers expected each year
        n_reported = sum(!is.na(Consumption)), #Providers with a reported value
        Consumption = sum(Consumption, na.rm = TRUE) #Sum consumption for each year
      )
    
   plot <- ggplot(df_consumption_long, aes(y = factor(Year), x = Consumption))+
         geom_col(fill = "#76ACA9", linewidth = 1.5) +
        
         geom_text(
           aes(label = paste0(round(Consumption / 1e6, 1), "M")),
           nudge_x = if (is_narrow) 30000000 else 7000000,
           nudge_y = 0.15,
           hjust = 0,
           size = if (is_narrow) 3.5 else 5
         ) +
         
         # Reporting count
         geom_text(
           aes(label = paste0(n_reported, "/", n_total, " reporting")),
           nudge_x = if (is_narrow) 30000000 else 7000000,
           nudge_y = -0.15,
           hjust = 0,
           size = if (is_narrow) 2 else 4,
           color = "grey35",
           fontface = "italic"
         ) +
            
        scale_x_continuous(
          breaks = scales::breaks_pretty(n = if (is_narrow) 4 else 6),
          labels = function(x) paste0(x / 1e6, "M"),
          expand = expansion(mult = c(0, 0.3))
          )+
        
        labs(
          y = "Year",
          x = "Consumption (m³)") +
        
        theme(
          axis.title = element_text(size = if (is_narrow) 12 else 18),
          axis.text = element_text(size = if (is_narrow) 8 else 12)
        )
   
     ggplotly(plot) %>%
       style(hoverinfo = 'none') %>%
       plotly::config(displayModeBar = FALSE)
  })
  
  #COMPARE WATER SOURCE DOUGGHNUT CHART ------------------------------------------------------------------------------
  output$WaterSourcePlot <- renderPlot({
    
    df_consumption_count <- df_consumption_long %>%
      distinct(MUN_NAME, WATER_SOURCE) %>%
      count(WATER_SOURCE)
    
    # Create legend labels
    labels <- paste0(df_consumption_count$WATER_SOURCE, " (", df_consumption_count$n, ")")
    
    ggplot(df_consumption_count, aes(x = 2, y = n, fill = WATER_SOURCE)) +
      geom_col(width = 1, color = "white") +
      coord_polar(theta = "y") +
      xlim(0.5, 2.5) +
      scale_fill_manual(
        values = c(
          "Surface Water" = "#76ACA9",
          "Groundwater" = "#D11B4A",
          "Mixed" = "#F6BC1A"
        ),
        labels = labels) +
      theme_void() +
      
      theme(plot.title = element_text(face = 'bold'), legend.title = element_blank(), 
            legend.text =  element_text(size = 18))
  })

#GROUNDWATER WELLS TAB ===============================================================================================  
  #Store selected well - used for Wells map
  selectedWell <- reactiveValues(Well = NULL, type = NULL)

  #MAP OF ACTIVE WELLS ----------------------------------------------------------------------------------------------- 
  output$WellPlot <- renderLeaflet({
    
    well_colors <- c(
      "Confined" = "#F6BC1A",
      "Unconfined" = "#76ACA9",
      "Bedrock" = "#004B55"
    )

    m_base <- leaflet(data = df_map)
    m_tiles <- addTiles(m_base)
    m_bound <- addPolygons(m_tiles,
                           data = df_TO_boundary, #add Thompson Okanagan region bounds
                           fill = FALSE,
                           color = "#D11B4A",
                           weight = 2,
                           opacity = 1
    ) 
    m_markers <- addCircleMarkers(m_bound,
                                  lng = ~longitude,
                                  lat = ~latitude,
                                  layerId = ~Well,
                                  radius = 8,
                                  color = "#333333",
                                  weight = 1,
                                  fillColor = ~unname(well_colors[type]),
                                  stroke = TRUE,
                                  fillOpacity = 0.9,
                                  label = ~paste0(df_map$Well, " - ", df_map$type),
                                  popup = ~paste0( "<b>Well:</b> ", df_map$Well,
                                                 "<br><b>Type:</b> ", df_map$type,
                                                 "<br><br>The average water level is ", ifelse(is.na(df_map$Average_m), "NA", paste0(df_map$Average_m, " m")),
                                                 " observed on ", as.Date(df_map$Start, format = "%Y-%m-%d"),
                                                 "<br>", "<br>", df_map$summary
                                                 )

                                )%>%
      addLegend(
        position = "bottomright",
        color = "#D11B4A",
        label = "Thompson Okanagan Tourism Region",
        opacity = 1
      ) %>%
      addLegend(
        position = "bottomright",
        colors = unname(well_colors),
        labels = names(well_colors),
        title = "Well Type",
        opacity = 1
      )
    setView(m_markers, lng = -119.496, lat = 49.880, zoom = 6)
  })

  #OBSERVE CLICKED MARKER --------------------------------------------------------------------------------------------
  observeEvent(input$WellPlot_marker_click, {
    selectedWell$Well <- input$WellPlot_marker_click$id
  })

  #REACTIVE EVENT ----------------------------------------------------------------------------------------------------
  well_data <- reactive({  
    req(selectedWell$Well)

    url_string <- build_url(selectedWell$Well)
    url_string <- sub("Days7", "Years1", url_string) #gets 1 year worth of data for well change over time chart instead of 7 days
    print(url_string)
    read.csv(url_string, skip = 5)
  })
  
  #CHANGE IN GROUND WATER LEVEL OVER 1 YEAR LINE CHART ---------------------------------------------------------------
  output$ChangeOverTimePlot <- renderPlot({
    
    plot_width <- session$clientData$output_ChangeOverTimePlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_w <- well_data()
    
    names(df_w) <-
    c("Start", "End", "Average_m")
    
    df_w$Start <- as.Date(df_w$Start)

    ggplot(df_w, aes(x = Start, y = Average_m)) +
      
      geom_line(color = "#42817A", linewidth = 1.5) +
      
      geom_smooth(
        method = "lm",
        se = FALSE,
        color = "#D11B4A",
        linewidth = 1
      ) + 
      
      labs(
        title = paste0("Change in Groundwater Level - ",
                            selectedWell$Well),
        x = NULL, 
        y = "Average Water Level Below Ground Surface (m)"
      )+ 
      
      theme(
        plot.title = ggtext::element_markdown(hjust = 0.5, face = "bold", size = if (is_narrow) 10 else 16), 
        plot.subtitle = ggtext::element_markdown(hjust = 0.5, size = if (is_narrow) 10 else 12),
        axis.title = element_text(size = if (is_narrow) 10 else 15),
        axis.text = element_text(size = if (is_narrow) 10 else 16)
      )+
      
      scale_x_date(
        date_breaks = if (is_narrow) "2 month" else "1 month",
        date_labels = "%b\n%Y",
        expand = c(0,0)) +
    
      scale_y_reverse()
  }, res = 96)
  
  #COMPARE WELL TYPES DOUGGHNUT CHART --------------------------------------------------------------------------------
  output$WellTypePlot <- renderPlot({
    
    df_map_count <- df_map%>%
      distinct(Well, type) %>%
      count(type)
    
    # Create legend labels
    labels <- paste0(df_map_count$type, " (", df_map_count$n, ")")
    
    ggplot(df_map_count, aes(x = 2, y = n, fill = type)) +
      geom_col(width = 1, color = "white") +
      coord_polar(theta = "y") +
      xlim(0.5, 2.5) +
      scale_fill_manual(
        values = c(
          "Confined" = "#F6BC1A",
          "Unconfined" = "#76ACA9",
          "Bedrock" = "#D11B4A",
          "Unknown" = "#BCB49E"
        ),
        labels = labels) +
      theme_void() +
      
      theme(plot.title = element_text(face = 'bold'), legend.title = element_blank(), 
            legend.text =  element_text(size = 18))
  })

#DROUGHT TAB ========================================================================================================= 
  #DROUGHT MAP OF THOMPSON OKANAGAN REGION ---------------------------------------------------------------------------
  output$DroughtPlot <- renderLeaflet({

    pal <- colorFactor(
      palette = c(
        "#E5EFBD",  # 0
        "#F0E918",  # 1
        "#F5C361",  # 2
        "#E38A2A",  # 3
        "#D71B22",  # 4
        "#800A0C"   # 5
      ),
      domain = c(0, 1, 2, 3, 4, 5),
    )

    m_base <- leaflet(data = df_drought)

    m_tiles <- addTiles(m_base)

    m_ploy <-  addPolygons(
      m_tiles,
      fillColor = ~pal(DroughtLevel),
      fillOpacity = 0.75,
      weight = 1.5,
      color = "black",
      popup = ~paste0(
        "<b>", BasinName, "</b><br>",
        "Current Drought Level: ", DroughtLevel
      )
    )

     m_legend <- addLegend(
        m_ploy,
        "bottomright",
        pal = pal,
        values = c(0, 1, 2, 3, 4, 5),
        title = "Drought Level",
        opacity = 1
      )
    setView(m_legend, lng = -120.34, lat = 50.98, zoom = 6)
  })
  
  #DROUGHT TABLE -----------------------------------------------------------------------------------------------------
  output$DroughtTable <- renderUI({
    
    tags$table(
      class = "table table-striped table-sm",
      tags$thead(
        tags$tr(
          tags$th("Basin"),
          tags$th("Drought Level"),
          tags$th("Latest Update")
        )
      ),
      
      tags$tbody(
        lapply(seq_len(nrow(df_drought)), function(i) {
          
          tags$tr(
            tags$td(df_drought$BasinName[i]),
            tags$td(df_drought$DroughtLevel[i]),
            tags$td(format(df_drought$Date_Modified[i], "%Y-%m-%d %H:%M %p"))
          )
        })
      )
    )
  })
  
  #DROUGHT HISTORY HEATMAP TABLE -- Data needs to be manually updated in the google sheet ----------------------------
  output$DroughtHistPlot <- renderPlot({
    
    plot_width <- session$clientData$output_DroughtHistPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df <- df_drought_hist %>%
      mutate(
        Date_Label = format(Start_Date, "%d-%b")
      )
    
    df$BasinName <- factor(
      df$BasinName,
      levels = rev(unique(df$BasinName))
    )
    
    # Keep dates in chronological order
    df$Date_Label <- factor(
      df$Date_Label,
      levels = unique(df$Date_Label)
    )
    
    ggplot(
      df,
      aes(
        x = Date_Label,
        y = BasinName,
        fill = factor(DroughtLevel)
      ),
    ) +
      
      # Heatmap cells
      geom_tile(
        color = "black",
        linewidth = 0.25
      ) +
      
      # Numbers inside cells
      geom_text(
        aes(
          label = ifelse(
            DroughtLevel == 6,
            "*",
            DroughtLevel
          )
        ),
        size = 3
      ) +
      
      # Drought colours
      scale_fill_manual(
        values = c(
          "0" = "#E5EFBD",
          "1" = "#F0E918",
          "2" = "#F5C361",
          "3" = "#E38A2A",
          "4" = "#D71B22",
          "5" = "#800A0C",
          "6" = "#BDBDBD" #NA
        ),
        
        labels = c(
          "0" = "0",
          "1" = "1",
          "2" = "2",
          "3" = "3",
          "4" = "4",
          "5" = "5",
          "6" = "Not updated"
        ),
        name = "Drought Levels",
      ) +
      
      labs(
        x = "",
        y = ""
      )+
      
      theme_minimal() +
      
      scale_x_discrete(
        position = "top",
        expand = c(0, 0),
        guide = guide_axis(
          angle = if (is_narrow) 90 else 30,
          check.overlap = TRUE
        )
      ) +
      
      scale_y_discrete(expand = c(0, 0)) +
      
      theme(
        axis.text.x = element_text(
          hjust = 0.5,
          size = if (is_narrow) 9 else 12,
        ),
        
        axis.text.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),

        axis.text.y = element_text(
          size = if (is_narrow) 8 else 12,
          hjust = 1
        ),
        
        panel.grid = element_blank(),
        
        legend.position = if (is_narrow) "bottom" else "top",
        legend.direction = "horizontal",
        legend.location = "plot",
        legend.justification = "left",
        plot.margin = margin(t = 5, r = 5, b = 5, l = 0),
        
        
        legend.title = element_text(
          size = if (is_narrow) 8 else 11
        ),
        
        legend.text = element_text(
          size = if (is_narrow) 8 else 10
        ),
      ) 
  }, res = 96)

#FISH TAB ============================================================================================================
  #VALUE BOX FOR TOTAL STREAM STATION --------------------------------------------------------------------------------
  output$numStations <- renderValueBox({
    valueBox(
      value = length(unique(df_stream_master$station_id)),
      subtitle = "Stream observation stations.",
      icon = icon("temperature-three-quarters"),
      color = "orange"
    )
  })
  
  #VALUE BOX FOR HIGHEST TEMP FOR ------------------------------------------------------------------------------------
  output$highestTemp <- renderValueBox({
    
    df_stream_filtered <- df_stream_master %>%
      filter(year == input$year_stream)

    highest_temp <- df_stream_filtered[which.max(df_stream_filtered$tw_mean_c),]
    
    valueBox(
      value = paste0(format(highest_temp$tw_mean_c, digits = 2), " °C"),
      subtitle = paste0("Highest mean temp ", highest_temp$station_name, ", ", input$year_stream),
      icon = icon("fire"),
      color = "teal"
    )
  })
  
  #VALUE BOX FOR STREAMS OVER 19 DEGREES -----------------------------------------------------------------------------
  output$over19 <- renderValueBox({
    
    df_stream_filtered <- df_stream_master %>%
      filter(year == input$year_stream) %>%
      filter(tw_mean_c >= 19)
    
    valueBox(
      value = paste0(length(unique(df_stream_filtered$station_id)), "/", length(unique(df_stream_master$station_id))),
      subtitle = paste0("Streams with mean at or above 19 °C, ", input$year_stream),
      icon = icon("hashtag"),
      color = "orange"
    )
  })
  
  #STREAM TEMP OVER TIME, EACH STATION, FILTER BY YEAR ---------------------------------------------------------------
  output$StreamLinePlot <- renderPlotly({
    
    plot_width <- session$clientData$output_StreamLinePlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_master <- df_stream_master %>%
      filter(year == input$year_stream)
    
    df_daily_summary <- df_master %>%
      group_by(date) %>%
      summarise(
        mean_temp = mean(tw_mean_c, na.rm = TRUE),
        min_temp = min(tw_mean_c, na.rm = TRUE),
        max_temp = max(tw_mean_c, na.rm = TRUE),
        .groups = "drop"
      )
      
    plot <- ggplot(df_daily_summary, aes(x = as.Date(date))) +
      
        geom_ribbon(
          aes(ymin = min_temp, ymax = max_temp),
          fill = "#76ACA9",
          alpha = 0.3
        ) +
        geom_line(
          aes(y = mean_temp),
          color = "#004B55",
          linewidth = 1
        ) +
        
        scale_x_date(
          date_labels = "%b",
          date_breaks = "1 month",
          expand = c(0, 0.1)
        ) +
        
        scale_y_continuous(
          limits = c(-5, NA),
          labels = function(x) paste0(x, " °C"),
          expand = expansion(mult = c(0, 0.05))
        )+
        
        labs(
          x = "Month", 
          y = "Mean Stream Temp"
        ) +
        
        theme(axis.title = element_text(size = if (is_narrow) 10 else 16),
              axis.text = element_text(size = if (is_narrow) 8 else 12),
              axis.text.x = element_text(angle = if (is_narrow) 60 else 0))
    
    p <- ggplotly(plot, tooltip = NULL)
    
    # Hide default hover on the ribbon and line, then add custom hover data
    p <- plotly::style(
      p,
      hoverinfo = "skip",
      traces = 1
    )
    
    p <- plotly::style(
      p,
      text = paste0(
        "<b>Date: ", format(as.Date(df_daily_summary$date), "%b %d"), "</b>",
        "<br>Max Temp: ", round(df_daily_summary$max_temp, 1), " °C",
        "<br>Min Temp: ", round(df_daily_summary$min_temp, 1), " °C",
        "<br>Mean Temp: ", round(df_daily_summary$mean_temp, 1), " °C"
      ),
      hoverinfo = "text",
      traces = 2
    )
    p <- plotly::config(p, displayModeBar = FALSE)
  })
  
  #DYNAMIC UI STREAM LINE PLOT ---------------------------------------------------------------------------------------
  output$StreamLinePlotBox <- renderUI({
    box(
      title = paste0("Daily Mean Stream Temperature Over Time - ", input$year_stream),
      width = 12,
      solidHeader = TRUE,
      plotlyOutput("StreamLinePlot", height = 500),
      p("Line shows average daily mean water temperature across monitoring stations; shaded ribbon shows the minimum–maximum range of daily mean temperatures."),
    )
  })
  
  #SUMMER TEMPS HEAT MAP ---------------------------------------------------------------------------------------------
  output$SummerTempHeatmap <- renderPlot({
    
    plot_width <- session$clientData$output_SummerTempHeatmap_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_summer <- df_stream_summer %>%
      filter(year > 2023)
    
    station_order <- df_summer %>%
      group_by(station_name) %>%
      summarise(
        mean_temp = mean(julaug_mean_c, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(mean_temp) %>%
      pull(station_name)
    
    ggplot(df_summer, aes(x = year,
                                  y = factor(station_name, levels = station_order),
                                  fill = julaug_mean_c
                                )
            ) +
            
            geom_tile(color = "white", linewidth = 0.2) +
            scale_fill_viridis_c(
              option = "plasma",
              name = "Mean temp (°C)",
              na.value = "grey90"
            ) +
            
            geom_text(
              aes(label = round(julaug_mean_c, digits = 2)),
              size = if (is_narrow) 0 else 7,
              color = "white"
            ) +
            
            scale_x_continuous(
              expand = c(0,0),
              breaks = seq(min(df_summer$year), max(df_summer$year), by = 1),
              guide = guide_axis(
                angle = if (is_narrow) 45 else 0
              )
            ) +
            labs(
              x = NULL,
              y = NULL
            ) +
            # theme_minimal() +
            theme(axis.text = element_text(size = if (is_narrow) 10 else 16),
                  axis.text.x = element_text(hjust = if (is_narrow) 1 else 0.5),
                  legend.text = element_text(size = if (is_narrow) 8 else 14),
                  legend.title = element_text(size = if (is_narrow) 8 else 16))
  })
  
  #RIVER BASIN MAP ---------------------------------------------------------------------------------------------------
  output$RiverPlot <- renderLeaflet({
    
    plot_width <- session$clientData$output_RiverPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_river_sub <- filter(df_river, BASIN == "FRASER" | BASIN == "COLUMBIA1" | BASIN == "COLUMBIA2")
    
    df_basin_labels <- data.frame(
      BASIN = c("FRASER", "COLUMBIA2"),
      lon = c(-122.0, -116.8),
      lat = c(51.5, 49.8),
      label = c(
        "Fraser River Basin",
        "Columbia River Basin"
      )
    )
    
    df_stream_latest <- df_stream_temp %>%
      filter(date == max(date))
    
    df_stream_temp_colors <- df_stream_latest %>%
      mutate(
        temp_color = case_when(
          is.na(water_temp) ~ "#808080",
          water_temp < 5    ~ "#174387",
          water_temp < 10   ~ "#1687D9",
          water_temp < 15   ~ "#00BFC4",
          water_temp < 19   ~ "#FFD92F",
          water_temp < 21   ~ "#F21313",
          TRUE              ~ "#750606"
        )
      )
    
    m_base <- leaflet(data = df_river_sub) %>%
      addProviderTiles(providers$Stadia.AlidadeSmooth)
    
    m_lines <- addPolylines(
      m_base,
      color = "#D11B4A",
      weight = 3,
      opacity = 1,
      label = ~ifelse(BASIN == "FRASER", "Fraser River Basin", "Columbia River Basin")
    )
    
    m_labels <- addLabelOnlyMarkers(
      m_lines,
      data = df_basin_labels,
      lng = ~lon,
      lat = ~lat,
      label = ~label,
      labelOptions = labelOptions(
        noHide = TRUE,
        direction = "center",
        textOnly = TRUE,
        style = list(
          "color" = "#D11B4A",
          "font-size" = "16px",
          "font-weight" = "bold",
          "text-shadow" = "1px 1px 2px white"
        )
      )
    )
    
    m_markers <- addCircleMarkers(m_labels,
                                  data = df_station_meta,
                                  lng = ~lon,
                                  lat = ~lat,
                                  radius = 6.5,
                                  color = df_stream_temp_colors$temp_color,
                                  weight = 1,
                                  fillColor = df_stream_temp_colors$temp_color,
                                  stroke = TRUE,
                                  fillOpacity = 1,
                                  label = ~paste0(df_station_meta$station, " - ", str_to_title(df_station_meta$name)),
                                  popup = ~paste0("<b>Station:</b> ", df_station_meta$station, "<br>",
                                                  "<b>Observed:</b> ", df_stream_temp_colors$date, "<br>",
                                                  "<b>Temp: </b>", format(df_stream_temp_colors$water_temp, digits = 2), ifelse(is.na(df_stream_temp_colors$water_temp), "", " °C"))
                                  
    )%>%
      addLegend(
        position = "bottomright",
        colors = c("#808080",
                   "#174387",
                   "#1687D9",
                   "#00BFC4",
                   "#FFD92F",
                   "#F21313",
                   "#750606"
        ),
        labels = c(
          "NA",
          "-1 – 5",
          "5 – 10",
          "10 – 15",
          "15 – 19",
          "19 – 21",
          "21 – 35"
        ),
        title = "Latest water temp (°C)",
        opacity = 1
      )
    
    if(is_narrow){
      setView(m_markers, lng = -117.8011055, lat = 50.2398537, zoom = 6)
    }else{
      setView(m_markers, lng = -120.34, lat = 50.98, zoom = 7)
    }
  })
  
  #STREAM THERMAL STATE BAR CHART ------------------------------------------------------------------------------------
  output$StreamStatePlot <- renderPlotly({
    
    plot_width <- session$clientData$output_StreamStatePlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_stream_7day <- df_stream_temp %>%
      mutate(date = as.Date(date)) %>%
      group_by(station) %>%
      slice_max(order_by = date, n = 7) %>%
      summarise(
        water_temp = mean(water_temp, na.rm = TRUE),
        start_date = min(date),
        end_date = max(date),
        .groups = "drop"
      )
    
    df_stream_7day <- df_stream_7day %>%
      mutate(
        station = reorder(station, water_temp)
      )
    
    df_stream_7day <- drop_na(df_stream_7day, water_temp)

    date_range <- paste0(
      format(min(df_stream_7day$start_date), "%b %d, %Y"),
      " – ",
      format(max(df_stream_7day$end_date), "%b %d, %Y")
    )

    plot <- ggplot(df_stream_7day, aes(x = water_temp, y = station, text = paste0(format(water_temp, digits = 3), " °C")))+
      geom_col(aes(fill = ifelse(water_temp >= 21, "above", "below")), linewidth = 1) +
      
      geom_vline(
        aes(xintercept = 21,
        colour = "19-21°C threshold"),
        linewidth = 1,
        linetype = "dashed"
      ) +
      
      geom_vline(
        xintercept = 19,
        colour = "black",
        linewidth = 1,
        linetype = "dashed"
      ) +
      
      scale_fill_manual(
        name = NULL,
        values = c(
          "above" = "#D11B4A",
          "below" = "#76ACA9"
        ),
        labels = c(
          "above" = "≥ 21°C",
          "below" = "< 21°C"
        )
      ) +
      
      # Threshold colours
      scale_colour_manual(
        name = NULL,
        values = c(
          "19-21°C threshold" = "black"
        )
      ) +
      
      scale_x_continuous(
        labels = function(x) paste0(x, " C"),
        expand = expansion(mult = c(0, 0.05))
        )+

      labs(
        x = paste0(
          "7-day mean water temperature \n (", date_range, ")"),
        y = "Station"
      )+ 
      
      theme(axis.title = element_text(size = if (is_narrow) 10 else 16),
            axis.text = element_text(size = if (is_narrow) 8 else 12),
            legend.text = element_text(size = if (is_narrow) 8 else 12),
            legend.position = if (is_narrow) "top" else "right"
      )
    
    p <- ggplotly(plot, tooltip = "text")
    
    # Clean up legend labels
    for (i in seq_along(p$x$data)) {
      trace_name <- p$x$data[[i]]$name
      
      if (!is.null(trace_name)) {
        if (grepl("above", trace_name, fixed = TRUE)) {
          p$x$data[[i]]$name <- "≥ 21°C"
        } else if (grepl("below", trace_name, fixed = TRUE)) {
          p$x$data[[i]]$name <- "< 21°C"
        } else if (grepl("19-21°C threshold", trace_name, fixed = TRUE)) {
          p$x$data[[i]]$name <- "19–21°C threshold"
        }
      }
    }
    
    p %>%
      layout(
        hoverlabel = list(
          bgcolor = "#004B55",
          bordercolor = "#004B55",
          font = list(
            color = "white",
            size = 13,
            family = "Arial"
          ),
          align = "left"
        )
      ) %>%
      plotly::config(displayModeBar = FALSE)
  })

  #CLICKABLE LINKS ON HOME PAGE --------------------------------------------------------------------------------------
  observeEvent(input$net_inflow_link, {
    updateTabItems(session, "tabs", "net_inflow")
  })
  
  observeEvent(input$water_consumption_link, {
    updateTabItems(session, "tabs", "water_consumption")
  })
  
  observeEvent(input$lake_level_link, {
    updateTabItems(session, "tabs", "mean_daily_level")
  })
  
  observeEvent(input$groundwater_link, {
    updateTabItems(session, "tabs", "groundwater_wells")
  })
  
  observeEvent(input$drought_link, {
    updateTabItems(session, "tabs", "drought_level")
  })
  
  observeEvent(input$stream_state_link, {
    updateTabItems(session, "tabs", "stream")
  })
}
