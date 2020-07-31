# Packages ----------------------------------------------------------------


if (!require("pacman")) install.packages("pacman")
pacman::p_load(imager, gridExtra, png, grid)


# Functions ---------------------------------------------------------------


# calculate a barcode for all images in a directory
create_barcode <- function(dir = getwd(), width = 1920, height = 1080, hetero = 8) {
  
  # calculate barcode from a single image file
  create_bar <- function(file) {
    image <- imager::load.image(file)
    
    return(imager::resize(image, size_x = 1, size_y = hetero))
  }
  
  barcode_list <- lapply(list.files(dir, pattern = "*.jpg"), 
         function(file) create_bar(file.path(dir, file)))
  
  barcode <- imager::imappend(barcode_list, "x")

  return(imager::resize(barcode, size_x = width, size_y = height, interpolation_type = 3))
}


# run in terminal to create frames:
# ffmpeg -i FILE.mp4 -r FRAMESPERSEC pic%05d.jpg


# Knives Out --------------------------------------------------------------


barcode <- create_barcode(dir = "KnivesOut")

plot(barcode, axes = F) # success!

imager::save.image(barcode, "Barcodes/KnivesOut_Barcode_Hetero.png", quality = 1)


# Harry Potter ------------------------------------------------------------


dirs <- list.dirs("HarryPotter")[-1]

HP_barcodes <- lapply(list(1, 8), function(h){
  lapply(dirs, function(folder) create_barcode(folder, hetero = h))
})

for (i in 1:2) {
  for (j in 1:8) {
    plot(HP_barcodes[[i]][[j]], axes = F)
  }
}

movies <- paste0("HP", 1:8)
types <- c("Uniform", "Hetero")

for (i in 1:2) {
  for (j in 1:8) {
    imager::save.image(HP_barcodes[[i]][[j]], 
                       paste0("Barcodes/", movies[j], "_Barcode_", types[i], ".png"), quality = 1)
  }
}


# averaging barcodes for the whole series

for (file in list.files("Barcodes")) {
  assign(file, imager::load.image(file.path("Barcodes", file)))
}

HPlist <- list(HP1_Barcode_Uniform.png, HP2_Barcode_Uniform.png, HP3_Barcode_Uniform.png, 
               HP4_Barcode_Uniform.png, HP5_Barcode_Uniform.png, HP6_Barcode_Uniform.png, 
               HP7_Barcode_Uniform.png, HP8_Barcode_Uniform.png)

HPbarcode <- imager::average(HPlist)

plot(HPbarcode, axes = F)
