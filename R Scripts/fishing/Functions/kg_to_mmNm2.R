kg_to_mmNm2 <- function(kg_per_m2,species){
  if(species == "Planktivorous"){
    conv <-  2.037736
  } else if(species == "Demersal"){
    conv <- 1.29559
  } else if(species == "Migratory"){
    conv <- 2.314465
  } else if(species == "Susp"){
    conv <- 0.503145
  } else if(species == "Carn"){
    conv <- 1.006289
  } else if(species == "Pelagic invert"){
    conv <- 1.257862
  } else if(species == "Birds"){
    conv <- 2.515723
  } else if(species == "Seals"){
    conv  <- 2.515723
  } else if(species == "Cetaceans"){
    conv <- 2.515723
  } else if(species == "Kelp"){
    conv  <- 2.07
  } else{
    message("INAVLID.\nPlease enter valid option:\n Planktivorous\n Demersal\n Migratory\n Susp\n Carn\n Pelagic invert\n Birds\n Seals\n Cetaceans\n Kelp")
    stop()
  }

  return(kg_per_m2 * 1000 * conv)
}