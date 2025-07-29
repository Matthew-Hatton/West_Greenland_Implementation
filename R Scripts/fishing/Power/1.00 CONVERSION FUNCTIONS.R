landings_convert_to_mMM_m2_y <- function(landings,area){                                                                      # AREA SHOULD BE IN METERS
  example <- data.frame(
    PLANKTIVOROUS = c(349609.761, 358201.8196, 1.713424511, 1.159933629, 0, 1338.310959, 172.8939334, 151.8290908, 5.809130803, 0.73954042, 31.93334073, 0),
    DEMERSAL = c(237.2490461, 571.0016293, 11.42784419, 58238.5794, 25.17682339, 121323.2873, 9176.992184, 268.8695873, 12004.87937, 65.84756175, 10.76285707, 0),
    MIGRATORY = c(185310.9876, 13462.09336, 1037.514481, 50.99165509, 15.71248546, 3911.584154, 28.46007309, 13.76215871, 132.6221401, 79.92412067, 1.968655769, 0),
    BENTH_FD = c(0, 0.900912731, 0.02, 2.930921997, 0, 7.165526687, 1.700909753, 0.029090909, 0.96182116, 8.353653903, 4314.172526, 0),
    BENTH_CS = c(1.04825454, 485.3469732, 7.666147702, 687.1933123, 0.047361136, 1874.581095, 49.64174464, 27123.70919, 16706.21997, 7276.790564, 3.271545488, 0),
    ZOO_CARN = c(0, 0, 0, 0, 0, 0, 0, 0, 1.22E-05, 0, 0, 0),
    MAMMALS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 67)
  )
  if (any(colnames(example) != colnames(landings))) {                                                                         # Check if column names match
    print(paste0("Column should have name ", colnames(example)))
  } else {
    mult <- (16 * 1000 / (106 * 12))
    plank_mMN <- 0.173 * mult
    dem_mMN <- 0.105 * mult
    migfish_mMN <- 0.173 * mult
    suspfiltben_mMN <- 0.06 * mult
    carnben_mMN <- 0.08 * mult
    zoo_carn_mMN <- 0.173 * mult
    mammals_mMN <- 0.06 * mult
    
    df <- data.frame(plank_mMN, dem_mMN, migfish_mMN,
                     suspfiltben_mMN, carnben_mMN, zoo_carn_mMN,
                     mammals_mMN)
    
    colnames(df) <- colnames(landings)
    
    totals <- rbind(sweep(landings,2,as.numeric(df),'*'),((colSums(landings) * df * 1000000) / area))                         # Calculate totals for each column and convert to mMN/m^2/y
    return(totals)                                                                                                            # Returns a dataframe of the converted values - the last row is the totals of the columns in mMN/m2/y
    }
}

discards <- function(landings, proportion_discarded) {
  # Check if the dimensions of the landings and proportion_discarded match
  if (!identical(dim(landings), dim(proportion_discarded))) {
    print("Landings and proportions discarded have different dimensions. Make sure the dimensions are equal.")
  } else {
    # Calculate totals using the formula
    totals <- (landings * proportion_discarded) / (1 - proportion_discarded)
    return(totals)  # Returns a dataframe of the converted values
  }
}


catch <- function(landings,discards,area){ # Give the function a dataframe of landings and proportions discarded - AREA IN METERS
  if (any(dim(landings) != dim(discards))) {                                                                            # Check if column names match
    print(paste0("Landings and discards have different dimensions. Make sure the dimensions are equal."))
  } else {
    totals <- ((landings+discards)*1000*1000)/(area)/365
    return(totals) # Returns a dataframe of the catch in units grammes/m2/day
  }
}

activity <- function(hours_vector,area) { #input is a vector of hours per year per fishing gear 
  total <- (hours_vector*60*60)/area/365
  return(total) #Returns vector of activities in seconds/m2/day
}

relative_power <- function(landings,discards,area,activity_vector) { # calculates relative power per gear per guild. acitivity_vector should be supplied in seconds/m2/day
  mult <- (16 * 1000 / (106 * 12))
  plank_mMN <- 0.173 * mult
  dem_mMN <- 0.105 * mult
  migfish_mMN <- 0.173 * mult
  suspfiltben_mMN <- 0.06 * mult
  carnben_mMN <- 0.08 * mult
  zoo_carn_mMN <- 0.173 * mult
  mammals_mMN <- 0.06 * mult
  conversion <- c(plank_mMN,dem_mMN,migfish_mMN,suspfiltben_mMN,carnben_mMN,zoo_carn_mMN,mammals_mMN) # Creates vector of mMN/gWW
  
  catch_g <- catch(landings,discards,area) %>% 
    sweep(.,2,activity_vector,'/') %>% 
    sweep(.,2,conversion,'*')
  ifelse(all(conversion) == 0,return(0),return(catch_g))
}

relative_effort <- function(activity_vector,relative_power_df) { #takes the activity vector and the relative power df (returned from the previous function)
  total <- sweep(relative_power_df,2,activity_vector,'*')
  return(total) #returns the relative effort per gear per guild in mMN/m2/d
}