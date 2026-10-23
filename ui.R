#THEME ----------------------------------------------------------------------------------------------------------
TOTA_theme <- create_theme( #Set colours
  adminlte_color(
    light_blue = "#004B55",
    yellow = "#BCB49E",
    orange = "#F6BC1A",
    teal = "#76ACA9",
    fuchsia = "#D11B4A"
  )
)

footer_TOTA <- tags$footer( 
  tags$style(HTML("
    @media (max-width: 600px) {
      #footer-logo img {
        min-width: 60px;
      }
      #footer-text p {
        font-size: 12px !important;
      }
      #footer-credit p {
        font-size: 11px !important;
      }
    }
  ")),
  div(
    div(
      tags$img(
        src = "side_bar_logo.png",
        width = "80%",
        style = "display: block; margin: 0 auto;"
      ),
      id = "footer-logo",
      style = "width: 15%; display: flex; align-items: center; justify-content: center;"
    ),
    
    div(
      p("Thompson Okanagan Tourism Association",
        style = "font-weight: bold; margin-bottom: 5px;"
      ),

        tags$a(
          "www.totabc.org",
          href = "https://www.totabc.org/",
          target = "_blank",
          style ="color: white;"
       ),

      
      p("2280-D Leckie Road, Kelowna,",
        style = "margin-bottom: 2px;"
      ),
      
      p("British Columbia, V1X 6G6",
        style = "margin-bottom: 0;"
      ),
      id = "footer-text",
      style = "width: 60%; color: white; display: flex; flex-direction: column; justify-content: center; padding-left: 5%;"
    ),
    
    div(
      tags$p(
        tags$a(
          "Created by Alexis Samp",
          href = "https://ca.linkedin.com/in/alexis-samp-b89678342",
          target = "_blank",
          style ="color: white;"
        ),
        style = "color: white; width: 100%; font-size: 14px; text-align: center; text-decoration: underline;"
      ),
      id = "footer-credit"
    ),
    style = "width: 100%; background-color: #004B55; display: flex; align-items: center; padding: 20px 5%; box-sizing: border-box; color: white;"
  ),
  style = "position: relative; bottom: 0; left: 0; width: 100%; z-index: 9999;"
)

#USER INTERFACE
ui <- dashboardPage(
  dashboardHeader(
    title = "Water Dashboard",
    tags$li(
        class = "dropdown",
        tags$a(
        href = "https://tota-insto-hub.share.connect.posit.cloud/",
        icon("globe"),
        " TOTA INSTO HUB",
        style = "
        color: white;
        font-size: 18px;
        padding: 15px;
        text-decoration: underline;",
      )
    )
  ),
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Overview", tabName = "overview", icon = icon("readme")),
      menuItem("Water Supply", tabName = "net_inflow", icon = icon("square-poll-vertical")),
      menuItem("Water Consumption", tabName = "water_consumption", icon = icon("droplet")),
      menuItem("Groundwater Wells", tabName = "groundwater_wells", icon = icon("map-location")),
      menuItem("Fish", tabName = "stream", icon = icon("fish")),
      menuItem("Back to Hub", tabName = NULL, icon = icon("globe"), href = "https://tota-insto-hub.share.connect.posit.cloud/", newtab = FALSE)
    ),
    
    tags$img(
      src = "side_bar_logo.png",
      width = "85%",
      style = "display: block; margin: 0 auto; padding-top: 40px;"
    ),
    
    tags$img(
      src = "UN_side_bar_logo.png",
      width = "85%",
      style = "display: block; margin: 0 auto; padding-top: 40px;"
    )
  ),
    
  dashboardBody(
    use_theme(TOTA_theme),
    
    tabItems(
      
      tabItem(
        
        tabName = "overview",
        
        tags$img(
          src = "banner.png",
          width = "100%",
          style = "position: relative;"
        ),
        p("Destination BC/Andrew Strain"),
        
        fluidRow(
            width = "100%",
            column(
              width = 12,
              h2("About this Dashboard"),
                
              p("The Okanagan watershed supports communities, agriculture, ecosystems, and the tourism experiences that attract visitors 
                to the Thompson-Okanagan region. As water resources face increasing pressures from drought, population growth, competing demands, 
                and changing environmental conditions, understanding how water is used and how conditions are changing is essential."),
              
              p("This dashboard brings together publicly available data on the Okanagan watershed's water supply, consumption, groundwater, 
                drought levels, and fish habitat conditions to support a more integrated understanding of water across the region."),
              
              p("The Okanagan watershed is being used as a pilot region for the Thompson Okanagan. Water management data can be difficult to collect 
                and standardize across the entire Thompson-Okanagan due to the region's large geographic area, multiple watersheds, and 
                numerous water providers. By focusing initially on the Okanagan watershed, this dashboard can test methods 
                for collecting, organizing, and monitoring water data within a clearly defined watershed."),
              
              p("The purpose of this dashboard is to support TOTA's water management reporting for the ", 
                tags$a(
                  href = "https://www.untourism.int/observatories/thompson-okanagan",
                  "UN Tourism International Network of Sustainable Tourism Observatories (INSTO)",
                  target = "_blank",
                  style ="color: #76ACA9; text-decoration: underline;"
                ), " and contribute to ongoing efforts to better understand the relationship between 
                water and tourism in the Thompson-Okanagan. The pilot approach will also help identify opportunities to expand water monitoring 
                and data collection to other areas of the region in the future."),
              
              p("Understanding how much water is available, how much is being used, and how conditions are changing helps build a clearer 
                picture of the region's water resources and tourism's relationship with them. Tourism depends on reliable water supplies 
                for accommodations, restaurants, wineries, and the lakes,
                streams, and landscapes that are central to the visitor experience."),
            

              br(),
              style = "font-size: 18px;",
              br()
            ),
            
         fluidRow(   
            column(
              tags$head(
                tags$style(HTML(".explore-link {
                                    display: block;
                                    font-size: 18px;
                                    font-weight: 600;
                                    margin-top: 10px;
                                    margin-bottom: 10px;
                                    color: #004B55;
                                    text-decoration: none;
                                  }
                                  .explore-link:hover {
                                    text-decoration: underline;
                                    cursor: pointer;
                                  }
                                "))
              ),
              
              width = 6,
              h2("What Can Be Explored?"),
              
              actionLink(
                "net_inflow_link",
                strong("Water Supply - Is the lake receiving enough water?"),
                class = "explore-link",
                
              ),
              p("View weekly net inflow into Okanagan Lake and compare current conditions with the historical average."),
              
              actionLink(
                "water_consumption_link",
                strong("Water Consumption - How much water are we using?"),
                class = "explore-link"
              ),
              p("Explore annual water consumption by provider and year. Compare providers and examine changes in regional water use."),
              
              actionLink(
                "drought_link",
                strong("Drought Conditions - How dry is the region?"),
                class = "explore-link"
              ),
              p("View current drought conditions across the Thompson Okanagan."),
              
              actionLink(
                "stream_state_link",
                strong("Fish - What is happening in our fish habitats?"),
                class = "explore-link"
              ),
              p("View current stream water temperatures compared to the sockeye migration barrier."),
              
              br(),
              h2("Acknowledgements"),
              p("This project would not have been possible without the support and guidance of the ", 
                tags$a(
                  href = "https://obwb.ca/",
                  "Okanagan Basin Water Board (OBWB)",
                  target = "_blank",
                  style ="color: #76ACA9; text-decoration: underline;"
                ), " and Nelson Jatel. Thank you for sharing your knowledge and providing valuable 
                feedback throughout the development of this dashboard.")
            ),
            
            tags$style(HTML(".explore-link {
                              color: #42817A;
                              font-size: 20px;
                              font-weight: bold;
                              text-decoration: none;
                            }
                          
                            .explore-link:hover {
                              text-decoration: underline;
                            }
                          ")),
            
            column(
              width = 6,
              tags$img(
                src = "basin_map.jpg",
                width = "70%",
                style = "display: block; margin: 0 auto;"
              ),
              
              tags$p(
                "Source: Okanagan Basin Water Board (OBWB). Okanagan Basin Map. Retrieved from https://obwb.ca/basin_map/",
                style = "font-size: 12px; color: #777; text-align: center; padding-top: 2%;"
              )
            ),
            style = "width: 100%; padding: 20px; font-size: 18px;"
         ),
        ),
      ),
      
      tabItem(
        tabName = "net_inflow",
        tags$style(HTML("
          @media (max-width: 600px) {
            #netInflowPlot { height: 350px !important; }
            #HistoricalDailyPlot { height: 350px !important; }
          }
        ")),
        fluidRow(
          
          box(
            title = "Water Supply - Is the lake receiving enough water?",
            solidHeader = TRUE,
            width = 12,
            p("Okanagan Lake is an important water source for communities, ecosystems, and tourism activities within the Thompson-Okanagan region. 
              Although these indicators focus specifically on Okanagan Lake rather than the entire tourism region, they provide insight into water 
              availability in the Okanagan Valley, where water conditions can influence recreational activities, destination appeal, and the sustainability 
              of tourism-dependent communities. Monitoring lake inflows and water levels helps provide context for understanding regional water supply conditions
              and their potential implications for tourism."),
            style = "font-size: 18px;"
          ),
          
          valueBoxOutput("MaxLevel", width = 3),
          valueBoxOutput("MinLevel", width = 3),
          valueBoxOutput("YoYMinLevel", width = 3),
          valueBoxOutput("InflowValueBox", width = 3),

          box(
            title = paste0("Weekly Net Inflow to Okanagan Lake: Current Water Year ", format(min(df_inflow$`Week ending`), "%Y"), "/", format(max(df_inflow$`Week ending`), "%Y")),
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("netInflowPlot", height = 600),
            footer = paste0("Net inflow for the week ending ", format(latest$`Week ending`, "%B %d, %Y"),
                                   " is ", scales::comma(current), " — that's ", scales::comma(round(abs(diff))), " ac-ft ", status,
                                   " than the 1944–2025 historical average (", scales::comma(round(average)),
                                   " ac-ft) for this time of year."),
            style = "font-size: 16px;"
          ),
          
          infoBox(
            title = "Net Inflow",
            width = 12,
            color = "light-blue",
            icon = icon("circle-info"),
            subtitle = "Net inflow measures how much water is added to Okanagan Lake each week after accounting for water released downstream through the Okanagan River at
              Penticton (station 08NM050). Comparing current inflows with the historical average helps identify whether the lake is receiving more or less water than usual. 
              Okanagan Lake levels naturally fluctuate throughout the year in response to snowmelt, precipitation, inflows, outflows, and evaporation. 
              Periods of below-average inflow may signal increased pressure on water resources, particularly during the summer tourism season when demand for water and 
              recreational access to lakes are important.",
            
          ),
          
          box(
            title = "Daily Mean Water Level of Okanagan Lake",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("HistoricalDailyPlot" , height = 600),
            style = "font-size: 16px;"
           ),
          
          infoBox(
            title = "Daily Mean Levels",
            width = 12,
            color = "light-blue",
            icon = icon("circle-info"),
            subtitle = "Daily mean lake levels show how Okanagan Lake's water levels change over time, providing context for current conditions relative to historical years. 
              Low levels can highlight water-supply concerns during periods of high demand. These conditions can have implications for drinking water supplies, ecosystems, 
              agriculture, and tourism activities. Station 08NM083 (Okanagan Lake) uses an assumed datum, meaning its zero point is an arbitrary reference established 
              for the gauge rather than a fixed elevation above sea level. For example, a recorded level of 1.4 m indicates that the water surface is 1.4 metres 
              above the station's reference point."
          ),
          
          box(
            title = "References & Data",
            solidHeader = TRUE,
            width = 12, 
            p("Okanagan Basin Water Board, & Jatel, N. (2026). Okanagan Lake weekly net inflow: 
              current water year versus the 1944–2025 average [Interactive figure]. 
              Retrieved July 20, 2026, from https://okanaganwatersupply.com"),
            p("Data source: Water Survey of Canada, Environment and Climate Change Canada
              (hydrometric stations 08NM083, Okanagan Lake at Kelowna, and 08NM050, Okanagan River at Penticton)."),
            p("Data source: Environment and Climate Change Canada. Daily mean of water level or flow dataset. Government of Canada. Hydrometric Station 08NM083. 
              Retrieved via the MSC GeoMet API: https://api.weather.gc.ca/collections/hydrometric-daily-mean/items?f=json&STATION_NUMBER=08NM083&datetime=1990-01-01/.."),
            p("Data source: Environment and Climate Change Canada. Monitoring Stations dataset. Government of Canada. Hydrometric Station 08NM083. Retrieved via the MSC GeoMet
              API: https://api.weather.gc.ca/collections/hydrometric-stations/items?limit=10&offset=0&STATION_NUMBER=08NM083")
          )
        ),
      ),
      
      tabItem(
        tabName = "water_consumption" ,
        
        tags$style(HTML("
          @media (max-width: 600px) {
            #ConsumptionPlot { height: 350px !important; }
            #WaterSourcePlot { height: 350px !important; }
            #ProvidersPlot { height: 425px !important; }
          }"
        )),
        
        fluidRow(
          box(
            width = 12,
            title = "Water Consumption - How much water are we using?",
            solidHeader = TRUE,
            column(
              width = 10,
              p("The Okanagan watershed serves as a valuable pilot area for 
                understanding water comsumption within the broader Thompson-Okanagan region. While the Thompson-Okanagan is a large and geographically 
                diverse tourism region, the Okanagan provides a clearly defined watershed where communities, water systems, ecosystems, agriculture 
                and tourism are closely connected. Although there are approximately 300 water utilities in the Okanagan,
                the largest 10 utilities supply approximately 90% of the region's water"),
              p("Water entering the Okanagan watershed does not all become available for human use. 80% of precipitation is 
              returned to the atmosphere through evapotranspiration and lake evaporation, while the remaining 20% contributes 
              to groundwater recharge (7%) and surface flows (13%)."),
              p("Communities, businesses, agriculture, ecosystems, and tourism all depend on the region’s limited water supply. 
                Municipal water systems support homes, businesses, accommodations, restaurants, attractions, and other tourism-related services,
                while the region’s lakes, rivers, landscapes, and agricultural areas are themselves important tourism assets. Tracking 
                municipal water consumption helps us understand how much water is being used to support the region’s communities 
                and tourism economy."),
              br(),
              style = "font-size: 18px;"
            ),
            
            column(
              width = 2,
              tags$img(
                src = "precipitation.png",
                width = "100%",
                style = "display: block; margin: 0 auto;",
              ),
              tags$p(
                "Source: Okanagan Basin Water Board (OBWB), Surface Storage and Flow. https://obwb.ca/wsd-index/key-findings/surface-storage-and-flow/",
                style = "font-size: 12px; color: #777; text-align: center; padding-top: 2%;"
              )
            )
          ),
          
          infoBox(
            title = "",
            width = 6,
            color = "light-blue",
            icon = icon("filter"),
            value = div(
              selectInput(
                "year_consumption",
                "Select Year:",
                choices = sort(unique(df_consumption_long$Year)),
                selected = max(df_consumption_long$Year)
              )
            )
          ),
          
          infoBox(
            title = "Data Last Modified",
            width = 6,
            color = "light-blue",
            icon = icon("clock-rotate-left"),
            value = format(file.info("data/cache/consumption.csv")$mtime, "%B %d, %Y"),
            subtitle = "Data Updated Manually by TOTA."
          ),
          
          valueBoxOutput("TotalVol", width = 4),
          valueBoxOutput("TopProvider", width = 4),
          valueBoxOutput("TopSource", width = 4),
          
          box(
            title = "Compare Providers",
            solidHeader = TRUE,
            width = 12,
            selectInput(
                "provider",
                "Select Providers:",
                choices = sort(unique(df_consumption_long$MUN_NAME)),
                multiple = TRUE,
                selected = sort(unique(df_consumption_long$MUN_NAME))
            ),
            plotlyOutput("ProvidersPlot", height = 600)
          ),
          
          box(
            title = "Water Consumption Per Year",
            solidHeader = TRUE,
            width = 12,
            padding = 2,
            plotlyOutput("ConsumptionPlot", height = 500)
          ),
          
          box(
            title = paste0("Water Source Types Across ", count(df_consumption), " Providers"),
            solidHeader = TRUE,
            width = 12,
            plotOutput("WaterSourcePlot")
          ),
          
          box(
            title = "Methodology & Data",
            solidHeader = TRUE,
            width = 12,
            tags$ul(
              tags$li("This dashboard summarizes the best publicly available municipal water consumption data for the Okanagan Watershed."),
              tags$li("Annual water consumption values are based on official utility or municipal reports whenever available."),
              tags$li("Where official annual totals were unavailable, annual values were estimated using publicly available information, including reported monthly water use and publications. Estimates were used only when no official annual total could be identified."),
              tags$li("Missing records indicate that no annual consumption data could be located for that year after reviewing publicly available sources, including annual reports, drinking water reports, council records, and other municipal documents."),
              tags$li("This dashboard currently focuses on the Okanagan watershed, which serves as a pilot study area within the broader Thompson Okanagan region. The Okanagan watershed does not represent the entire Thompson Okanagan region."), 
              tags$li("The Okanagan Watershed was selected because it has the most complete and consistent publicly available data."),
              tags$li("Although there are approximately 300 water utilities in the Okanagan, the largest 10 utilities supply approximately 90% of the region's water. Consequently, the pilot dataset captures the majority of municipal water use despite not including every utility.")
            ),
          ),
          
          box(
            title = "References",
            solidHeader = TRUE,
            width = 12,
            p("Samp, A. (2026). Okanagan Water Consumption dataset for the Okanagan Watershed [Data set]. Unpublished dataset.")
          )
        ),
      ),
      
      tabItem(
        tabName = "groundwater_wells",
        
        tags$style(HTML("
          @media (max-width: 600px) {
            #WellPlot { height: 350px !important; }
            #ChangeOverTimePlot { height: 350px !important; }
            #wellTypePlot { height: 350px !important; }
          }
        ")),
        
        fluidRow(
          box(
            title = "Groundwater - What is happening to water below ground?",
            solidHeader = TRUE,
            width = 12,
            p("Groundwater is important to the Thompson Okanagan tourism economy. Hotels, restaurants, wineries, golf courses and other tourism operations 
              require reliable access to water, while lakes and stream are central to the outdoor experiences that attract visitors to the region.
              Understanding and monitoring groundwater is particularly important for the region because it regularly experiences drought and water scarcity.
              During dry periods, groundwater can play an important role in supporting water supplies and maintaining flows in rivers and streams. 
              Long-term monitoring can help improve our understanding of changing groundwater conditions and the sustainability of this resource."),
            p("More information and detailed well records can be found here ",
              tags$a(
                href = "https://apps.nrs.gov.bc.ca/gwells/",
                tags$button(
                  type = "button",
                  "GWELLS database"
                )
              ), 
            ),
            
            style = "font-size: 17px;"
          ),
          
          box(
            title = "Active Groundwater Wells in the Thompson Okangan Tourism Region",
            solidHeader = TRUE,
            width = 6,
            leafletOutput("WellPlot", height = 640)
          ),
          
          box(
            title = "Selected Well",
            solidHeader = TRUE,
            width = 6,
            plotOutput("ChangeOverTimePlot", height = 600),
            footer = "Select a well."
          ),
          
          box(
            title = paste0("Aquifer Types Across ", count(df_map), " Wells"),
            solidHeader = TRUE,
            width = 12,
            plotOutput("WellTypePlot")
          ),
          
          box(
            title = "References & Data",
            solidHeader = TRUE,
            width = 12,
            p("Data source: Province of British Columbia. Groundwater Level Data Interactive Map (Provincial Groundwater Observation Well Network).
              Retrieved from https://governmentofbc.maps.arcgis.com/apps/webappviewer/index.html?id=b53cb0bf3f6848e79d66ffd09b74f00d"),
            p("Data source: Province of British Columbia. Groundwater Observation Well Network. Data retrieved through the AQUARIUS WebPortal data export tool."),
            p("Data source: Okanagan Basin Water Board. Okanagan Groundwater Risk. Retrieved from https://obwb.shinyapps.io/ok-gw/")
          )
        ),
      ),
      
      tabItem(
        tabName = "stream",
        
        tags$style(HTML("
          @media (max-width: 600px) {
            #StreamStatePlot { height: 450px !important; }
            #RiverPlot { height: 300px !important; margin-top: 24px; }
            #StreamLinePlot { height: 450px !important; }
            #SummerTempHeatmap { height 450px !important; }
          }
        ")),
        
        fluidRow(
          
          box(
            title = "Stream State - What is happening in our fish habitats?",
            width = 12,
            solidHeader = TRUE,
            p("Salmon connect communities, ecosystems and tourism across the Thompson Okanagan. The Okanagan watershed is used as a pilot area 
            to better understand stream state across the whole Thompson Okangan. The Okanagan spans two 
              major watersheds: the Fraser River and Columbia River. Water flowing north of Vernon generally drains 
              toward the Fraser River, while watersheds to the south drain toward the Columbia River. These connected 
              waterways provide important habitat for salmon and support the ecosystems, communities and tourism experiences
              that depend on healthy rivers and lakes."),
            p("Stream temperature is an important indicator of aquatic ecosystem health. 19 °C is the water-quality guideline of BC and 21 °C is the sockeye migration barrier. Streams at or above 21 °C
              form a thermal wall that blocks or kills migrating and rearing salmon."),
            br(),
            h3("Learn More"),
            p(),
            
            p("Explore the current state of the Fraser River."),
              tags$a(
                href = "https://stateofsalmon.psf.ca/region/Fraser",
                tags$button(
              type = "button",
              "FRASER RIVER  "
                )
            ),
            
            p("Explore the current state of the Columbia River."),
            tags$a(
              href = "https://stateofsalmon.psf.ca/region/Columbia",
              tags$button(
                type = "button",
                "COLUMBIA RIVER"
              )
            ),
            br(),
            br(),
            p("The Thompson-Okanagan is located within the traditional and unceded territory of the Syilx
              Okanagan Peoples. Waterways and salmon have sustained Indigenous communities for generations 
              and continue to hold important cultural, ecological, and community significance. The health 
              of rivers, lakes, and fish populations is deeply connected to Indigenous stewardship and 
              knowledge of the land and water."),
            tags$a(
              href = "https://syilx.org/programs-services-and-initiatives/fisheries-and-natural-resources/",
              tags$button(
                type = "button",
                "SYILX OKANAGAN NATION"
              )
            ),
            style = "font-size: 18px;"
          ),
          
          infoBox(
            title = "",
            width = 6,
            color = "light-blue",
            icon = icon("filter"),
            value = div(
              selectInput(
                "year_stream",
                "Select Year:",
                choices = sort(unique(df_stream_master$year)),
                selected = max(df_stream_master$year)
              )
            )
          ),
          
          infoBox(
            title = "Data Freshness",
            width = 6,
            color = "light-blue",
            icon = icon("clock-rotate-left"),
            value = format(max(df_station_meta$last_banked_date), "%B %d, %Y"),
            subtitle = "Updated by Water Survey of Canada."
          ),
          
          valueBoxOutput("numStations", width = 4),
          valueBoxOutput("highestTemp", width = 4),
          valueBoxOutput("over19", width = 4),
          
          uiOutput("StreamLinePlotBox", height = 500),
          
          box(
            title = "July–August Mean Stream Temperatures",
            width = 12,
            solidHeader = TRUE,
            plotOutput("SummerTempHeatmap", height = 600)
          ),
          
          box(
            title = "Okanagan Stream Thermal State",
            width = 12,
            solidHeader = TRUE,
            leafletOutput("RiverPlot", height = 600)
          ),
          
          box(
            title = "Okanagan Weekly Mean Stream Temperature",
            width = 12,
            solidHeader = TRUE,
            plotlyOutput("StreamStatePlot", height = 500),
            style = "font-size: 18px;"
          ),
          
          box(
            title = "References & Data",
            width = 12,
            solidHeader = TRUE,
            p("Jatel, N. and Okanagan Basin Water Board (2026). Okanagan Stream Temperature Dataset. Distributed under CC-BY 4.0. https://temp.stream/.")
          )
        ),
      )
    ),
    footer_TOTA
  )
)

