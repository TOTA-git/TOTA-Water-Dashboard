# Server
server <- function(input, output, session) {
  
  # NET INFLOWS BAR CHART
  output$netInflowPlot <- renderPlot({
    
    plot_width <- session$clientData$output_netInflowPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_long <- df_inflow |>
      tidyr::pivot_longer(
        cols = c(`1944-2025 avg (ac-ft)`, `Current (ac-ft)`),
        names_to = "Series",
        values_to = "Inflow"
      ) |>
      mutate(
        Series = recode(
          Series,
          `1944-2025 avg (ac-ft)` = "1944–2025 Average",
          `Current (ac-ft)` = "Current Water Year"
        )
      )
    
    plot_title <- paste0(
      "Weekly Net Inflow to Okanagan Lake: Current Water Year ",
      format(min(df_inflow$`Week ending`), "%Y"),
      "/",
      format(max(df_inflow$`Week ending`), "%Y")
    )
    
    ggplot(
      df_long,
      aes(
        x = `Week ending`,
        y = Inflow,
        fill = Series
      )
    ) +
      
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
        labels = function(x) paste0(x / 1000, "K"),
      ) +
      
      labs(
        title = stringr::str_wrap(plot_title, width = if (is_narrow) 30 else 80),
        x = "",
        y = "Net Weekly Inflow Volume (acre-feet)"
      ) +
      
      theme(
        plot.title = element_text(size = if (is_narrow) 14 else 22),
        axis.title = element_text(size = if (is_narrow) 12 else 18),
        axis.text = element_text(size = if (is_narrow) 10 else 16),
        legend.title = element_text(size = if (is_narrow) 11 else 20),
        legend.text = element_text(size = if (is_narrow) 8 else 16),
        legend.position = if (is_narrow) "bottom" else "right",
        
      )
  }, res = 96)
  
  #HISTORICAL RANGE FOR DAILY MEAN LAKE LEVEL LINE CHART
  output$HistoricalDailyPlot <- renderPlot({
    
    plot_width <- session$clientData$output_HistoricalDailyPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_daily_historic <- df_daily_mean |>
      filter(Year >= min(Year),
             Year <= max(Year) -1) |>
      group_by(DayOfYear) |>
      summarise(
        Historic_Min = min(LEVEL, na.rm = TRUE),
        Historic_Max = max(LEVEL, na.rm = TRUE),
        Historic_Mean = mean(LEVEL, na.rm = TRUE)
      )
    
    df_current_year <- df_daily_mean |>
      filter(Year == max(Year))
    
    hist_color <- paste0("Historic Range ", min(df_daily_mean$Year), "-",  max(df_daily_mean$Year) -1)
    current_year <- max(df_current_year$Year)
    current_year_color <- paste0("Recent Year: ", current_year)
    
    ggplot() +
      
      geom_ribbon(data = df_daily_historic,
                  aes(x = DayOfYear, ymin = Historic_Min, ymax = Historic_Max, fill = hist_color)) +
      
      geom_line(data = df_current_year, aes(x = DayOfYear, y = LEVEL, colour = "Recent Year"),
                linewidth = 1.5) + 
      
      geom_line(data = df_daily_historic, 
                aes(x = DayOfYear, y = Historic_Mean, colour = "Historic Daily Mean"), linewidth = 1.5) +
      
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
        values = "gray80",
        name = ""
      ) +
      
      scale_colour_manual(
        values = c("Historic Daily Mean" ="#76ACA9", "Recent Year" = "#D11B4A"),
        labels = c("Historic Daily Mean", current_year_color),
        name = NULL
      ) +
      
      guides(
        color = if (is_narrow) guide_legend(ncol = 1) else guide_legend()
      ) +
      
      theme(axis.title = element_text(size = if (is_narrow) 10 else 15),
            axis.text = element_text(size = if (is_narrow) 10 else 16),
            legend.title = element_text(size = if (is_narrow) 11 else 20),
            legend.text = element_text(size = if (is_narrow) 8 else 16),
            legend.position = if (is_narrow) "bottom" else "right"
      )
  }, res = 96)
  
  #COMPARE OKANAGAN PROVIDERS ANNUAL CONSUMPTION BAR CHART
  output$ProvidersPlot <- renderPlot({
    
    plot_width <- session$clientData$output_ProvidersPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    filtered_df_consumption <- df_consumption_long |>
      dplyr::filter(MUN_NAME %in% input$provider,
                    Year == input$year)
    
    ggplot(filtered_df_consumption, aes(x = MUN_NAME, y = Consumption)) +
      geom_col(fill = "#76ACA9", width = 0.25) +
      
      scale_y_continuous(
        breaks = if (is_narrow) scales::breaks_pretty(n = 4) else seq(0, 100000000, by = 2000000),
        labels = function(x) paste0(x / 1e6, "M"),
        expand = c(0, 0))+
      
      theme(
        axis.text.x = element_text(
          angle = if (is_narrow) 60 else 30,
          hjust = 1,
          size = if (is_narrow) 10 else 14,
          vjust = 1
        ))+
      
      labs(
        x = "Provider",
        y = "Consumption (m³)") +
      theme(
        axis.title = element_text(size = if (is_narrow) 14 else 18),
        axis.text.y = element_text(size = if (is_narrow) 10 else 12)
      )
  }, res = 96)
  
  #COMPARE WATER SOURCE DOUGGHNUT CHART
  output$WaterSourcePlot <- renderPlot({
    
    df_consumption_count <- df_consumption_long |>
      distinct(MUN_NAME, WATER_SOURCE) |>
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
  
  #ANNUAL WATER CONSUMPTION BAR CHART
  output$ConsumptionPlot <- renderPlot({
    
    plot_width <- session$clientData$output_ConsumptionPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_consumption_long <- df_consumption_long |>
      mutate(Year = as.numeric(Year)) |>  #change Year string to number
      group_by(Year) |>
      summarise(
        n_total = dplyr::n(), #Number of providers expected each year
        n_reported = sum(!is.na(Consumption)), #Providers with a reported value
        Consumption = sum(Consumption, na.rm = TRUE) #Sum consumption for each year
      )
    
    ggplot(df_consumption_long, aes(y = factor(Year), x = Consumption))+
      geom_col(fill = "#76ACA9", linewidth = 1.5) +
      
      geom_text(
        aes(label = paste0(round(Consumption / 1e6, 1), "M")),
        hjust = -0.1,
        vjust = -0.3,
        size = if (is_narrow) 3.5 else 5
      ) +
      
      # Flag years where not all providers reported, so the shortfall
      # in total consumption isn't mistaken for lower usage
      geom_text(
        aes(label = paste0(n_reported, "/", n_total, " reporting")),
        hjust = -0.1,
        vjust = 1.4,
        size = if (is_narrow) 3.5 else 5,
        color = "grey35",
        fontface = "italic"
      ) +
      
      scale_x_continuous(
        breaks = if (is_narrow) scales::breaks_pretty(n = 4) else seq(0, 1000000000, by = 10000000),
        labels = function(x) paste0(x / 1e6, "M"),
        expand = expansion(mult = c(0, 0.3))
        )+
      
      labs(
        y = "Year",
        x = "Consumption (m³)") +
      
      theme(
        axis.title = element_text(size = if (is_narrow) 14 else 20),
        axis.text = element_text(size = if (is_narrow) 11 else 16)
      )
  }, res = 96)
  
  #Store selected well - used for Wells map
  selectedWell <- reactiveValues(Well = NULL, type = NULL)

  #MAP OF ACTIVE WELLS 
  output$WellPlot <- renderLeaflet({
    
    well_colors <- c(
      "Confined" = "#F6BC1A",
      "Unconfined" = "#76ACA9",
      "Bedrock" = "#D11B4A",
      "Unknown" = "#BCB49E"
    )

    m_base <- leaflet(data = df_map)
    m_tiles <- addTiles(m_base)

    m_markers <- addCircleMarkers(m_tiles,
                                  lng = ~longitude,
                                  lat = ~latitude,
                                  layerId = ~Well,
                                  radius = 8,
                                  color = "#333333",
                                  weight = 1,
                                  fillColor = ~unname(well_colors[type]),
                                  stroke = TRUE,
                                  fillOpacity = 0.8,
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
        colors = unname(well_colors),
        labels = names(well_colors),
        title = "Well Type",
        opacity = 1
      )
    

    setView(m_markers, lng = -119.496, lat = 49.880, zoom = 8)
  })

  observeEvent(input$WellPlot_marker_click, {

    selectedWell$Well <- input$WellPlot_marker_click$id

  })

  well_data <- reactive({  
    req(selectedWell$Well)

    url_string <- build_url(selectedWell$Well)
    url_string <- sub("Days7", "Years1", url_string) #gets 1 year worth of data for well change over time chart instead of 7 days
    print(url_string)
    read.csv(url_string, skip = 5)
  })
  
  #CHANGE IN GROUND WATER LEVEL OVER 1 YEAR LINE CHART
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
  
  #COMPARE WELL TYPES DOUGGHNUT CHART
  output$WellTypePlot <- renderPlot({
    
    df_map_count <- df_map|>
      distinct(Well, type) |>
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
  
  #DROUGHT MAP OF THOMPSON OKANAGAN REGION
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
  
  #DROUGHT TABLE
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
  
  #DROUGHT HISTORY HEATMAP TABLE -- Data needs to be manually updated in the google sheet
  output$DroughtHistPlot <- renderPlot({
    
    plot_width <- session$clientData$output_DroughtHistPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df <- df_drought_hist |>
      mutate(
        Date_Label = format(Start_Date, "%d-%b")
      )
    
    df$`Basin Name` <- factor(
      df$`Basin Name`,
      levels = rev(unique(df$`Basin Name`))
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
        y = `Basin Name`,
        fill = factor(`Drought Level`)
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
            `Drought Level` == 6,
            "*",
            `Drought Level`
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
  
  #STREAM THERMAL STATE BAR CHART
  output$StreamStatePlot <- renderPlot({
    
    plot_width <- session$clientData$output_StreamStatePlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_stream_7day <- df_stream_temp |>
      mutate(date = as.Date(date)) |>
      group_by(station) |>
      slice_max(order_by = date, n = 7) |>
      summarise(
        water_temp = mean(water_temp, na.rm = TRUE),
        start_date = min(date),
        end_date = max(date),
        .groups = "drop"
      )
    
    df_stream_7day <- df_stream_7day |>
      mutate(
        station = reorder(station, water_temp)
      )
    
    df_stream_7day <- drop_na(df_stream_7day, water_temp)

    date_range <- paste0(
      format(min(df_stream_7day$start_date), "%b %d, %Y"),
      " – ",
      format(max(df_stream_7day$end_date), "%b %d, %Y")
    )

    ggplot(df_stream_7day, aes(x = water_temp, y = station))+
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
            axis.text = element_text(size = if (is_narrow) 10 else 16),
            legend.text = element_text(size = if (is_narrow) 8 else 16),
            legend.position = if (is_narrow) "bottom" else "right"
      )
  }, res = 96)
  
  #RIVER BASIN MAP
  output$RiverPlot <- renderLeaflet({
    df_river_sub <- filter(df_river, BASIN == "FRASER" | BASIN == "COLUMBIA1" | BASIN == "COLUMBIA2")
    
    m_base <- leaflet(data = df_river_sub)
    
    m_tiles <- addTiles(m_base)
    
    m_lines <- addPolylines(
      m_tiles,
      color = ~ifelse(BASIN == "FRASER", "#D11B4A", "#76ACA9"),
      weight = 6,
      opacity = 1,
      popup = ~paste0("<b>", BASIN, "</b>")
    )
    
    m_legend <- addLegend(
      m_lines,
      "bottomright",
      colors = c("#D11B4A", "#76ACA9"),
      labels = c("FRASER", "COLUMBIA"),
      title = "River Basin",
      opacity = 1
    )
    setView(m_legend, lng = -120.34, lat = 50.98, zoom = 5)
  })
  
  
  #CLICKABLE LINKS ON HOME PAGE
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
