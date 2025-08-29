## extract air temp

foo <- nc_open("I:/Science/MS-Marine/MA/CNRM_ssp370/ice/CNRM_ssp370_1m_20701201_20701231_icemod_207012-207012.nc")
longnames <- sapply(foo$var, function(x) x$longname)
print(longnames)
