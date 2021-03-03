
shinyServer(function(input, output) {

    ### 1) Código para graficar el semáforo COVID ----
    
    data_dpto <- fread("https://raw.githubusercontent.com/geresacusco/dashboard-covid-19/main/data/data_regional.csv", keepLeadingZeros = TRUE)
    data_dpto$fecha <- as.Date(data_dpto$fecha)
    data_dpto <- subset(data_dpto, fecha > as.Date("2020-03-12"))
    data_dpto <- subset(data_dpto, fecha < last(data_dpto$fecha) - 14) #delete last row?
    data_dpto <- subset(data_dpto, fecha < last(data_dpto$fecha) - 14)
    data_dpto <- mutate(data_dpto, xposi=log10(total_positivo), xini = log10(total_inicio))
    data_dpto <- mutate(data_dpto, posi_molecular_percent = posi_molecular*100)  
    
    data_dpto <- data_dpto %>%
        tq_mutate(
            # tq_mutate args
            select     = defunciones,
            mutate_fun = rollapply, 
            # rollapply args
            width      = 7,
            align      = "right",
            FUN        = mean,
            # mean args
            na.rm      = TRUE,
            # tq_mutate args
            col_rename = "mean_7")
    
    date <- select(data_dpto, fecha)
    
    data_dpto2 <- select(data_dpto, defunciones, mean_7)
    
    test_xts <- xts(data_dpto2, order.by = date$fecha)
    
    output$highchart1 <- renderHighchart({
        highchart(type = "stock") %>%
            # hc_add_series(test_xts$defunciones, type = "area",color = "rgb(116, 199, 184, 0.0)", name = "Promedio", id="A") %>%
            hc_add_series(test_xts$mean_7, type = "line",color = "black", name = "Defunciones", id="B") %>%
            hc_xAxis( title = list(text = "Días")) %>%
            hc_yAxis( title = list(text = "Número de defunciones"), opposite = FALSE, minorGridLineDashStyle = "LongDashDotDot") %>%
            hc_tooltip(valueDecimals = 0, borderWidth = 1) %>%
            hc_yAxis(minorGridLineWidth = 0, gridLineWidth = 1,
                     plotBands = list(
                         list(from = 0, to = 6.965, color = "rgb(116, 199, 184, 0.7)",
                              label = list(text = "Bajo")),
                         list(from = 6.965, to = 20.895, color = "rgb(255, 205, 163, 0.7)",
                              label = list(text = "Medio"), zIndex = 1),
                         list(from = 20.895, to = 27.86, color = "rgb(239, 79, 79, 0.7)",
                              label = list(text = "Alto")))) %>%
            hc_caption(
                text = "La curva muestra el promedio movil de defunciones 7 días. ", 
                useHTML = TRUE) 
    })  
    
    ## Código para la tabla
    # https://www.littlemissdata.com/blog/prettytables
    
    datafortable1 <- data_dpto %>%
        select(total_positivo,total_defunciones,positivo, defunciones) %>%
        summarise(last_total_positivo = last(total_positivo),last_total_defunciones = last(total_defunciones), last_positivo = last(positivo), last_defunciones = last(defunciones))
    
    output$table <- renderFormattable({formattable(datafortable1, list())})
    
     ## Código para el semáforo
    
    data_dis <- fread("https://raw.githubusercontent.com/geresacusco/dashboard-covid-19/main/data/data_distrital.csv", keepLeadingZeros = TRUE)
    data_dis$fecha <- as.Date(data_dis$fecha)
    data_dis <- subset(data_dis, fecha > as.Date("2020-03-12") & fecha < Sys.Date() -1)
    data_dis <- subset(data_dis, fecha < last(data_dis$fecha) - 14) #delete last row?
    data_dis <- subset(data_dis, fecha < last(data_dis$fecha) - 14)
    data_dis <- mutate(data_dis, IDDIST = ubigeo)
    data_dis <- mutate(data_dis, posi_molecular_percent = posi_molecular*100)  
    
    
    map_district <- jsonlite::fromJSON("https://raw.githubusercontent.com/geresacusco/dashboard-covid-19/main/data/mapas/districts.geojson", simplifyVector = FALSE)
    
    
    # Casos totales
    
    data_positivo <- data_dis %>% 
        group_by(IDDIST) %>% 
        do(item = list(
            IDDIST = first(.$IDDIST),
            sequence = .$total_positivo,
            total_positivo = first(.$total_positivo))) %>% 
        .$item
    
    output$map_total_positivo <- renderHighchart ({  
        highchart(type = "map") %>%
            hc_add_series(
                data = data_positivo,
                name = "Casos totales",
                mapData = map_district,
                joinBy = 'IDDIST',
                borderWidth = 0.01
            ) %>% 
            hc_mapNavigation(enabled = TRUE) %>%
            hc_colorAxis(minColor = "#06d6a0", maxColor = "#03045e")  %>%
            hc_legend(
                layout = "vertical",
                reversed = TRUE,
                floating = TRUE,
                align = "right"
            ) %>% 
            hc_motion(
                enabled = TRUE,
                autoPlay = TRUE,
                axisLabel = "fecha",
                labels = sort(unique(data_dis$fecha)),
                series = 0,
                updateIterval = 50,
                magnet = list(
                    round = "floor",
                    step = 0.1
                )
            ) %>% 
            hc_chart(marginBottom  = 100)
    })
    
    

})
