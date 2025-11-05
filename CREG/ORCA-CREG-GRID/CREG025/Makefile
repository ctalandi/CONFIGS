# Makefile
#
DIR=.
SRCDIR=${DIR}
OBJDIR=${DIR}
BINDIR=${DIR}/bin

export NFCONFIGFLIBS=`nf-config --flibs`
export NFCONFIGFLAGS=`nf-config --fflags`

F90=ifort
FFLAGS= -O3 -assume byterecl -convert big_endian -fp-model precise -O $(NFCONFIGFLAGS) $(NFCONFIGFLIBS) -module ${OBJDIR}

#LDFLAGS  = ${NETCDFF_LDFLAGS}
#LDFLAGS  = -L${NETCDF_LIB} -lnetcdf

all: convert_wrap_orca025_batcoord convert_wrap_orca025_iceini convert_wrap_orca025_chlorophyll convert_wrap_orca025_gridT_Levitus convert_wrap_orca025_gridV convert_wrap_orca025_BioT

convert_wrap_orca025_batcoord:   convert_wrap_orca025_batcoord.f90
	$(F90) convert_wrap_orca025_batcoord.f90 -o $(BINDIR)/convert_wrap_orca025_batcoord $(FFLAGS) $(LDFLAGS)

convert_wrap_orca025_gridT_Levitus:   convert_wrap_orca025_gridT_Levitus.f90
	$(F90) convert_wrap_orca025_gridT_Levitus.f90 -o $(BINDIR)/convert_wrap_orca025_gridT_Levitus $(FFLAGS) $(LDFLAGS)

convert_wrap_orca025_BioT:   convert_wrap_orca025_BioT.f90
  $(F90) convert_wrap_orca025_BioT.f90 -o $(BINDIR)/convert_wrap_orca025_BioT $(FFLAGS) $(LDFLAGS)

convert_wrap_orca025_gridV:   convert_wrap_orca025_gridV.f90
	$(F90) convert_wrap_orca025_gridV.f90 -o $(BINDIR)/convert_wrap_orca025_gridV $(FFLAGS) $(LDFLAGS)

convert_wrap_orca025_iceini:   convert_wrap_orca025_iceini.f90
	$(F90) convert_wrap_orca025_iceini.f90 -o $(BINDIR)/convert_wrap_orca025_iceini $(FFLAGS) $(LDFLAGS)

convert_wrap_orca025_chlorophyll:   convert_wrap_orca025_chlorophyll.f90
	$(F90) convert_wrap_orca025_chlorophyll.f90 -o $(BINDIR)/convert_wrap_orca025_chlorophyll $(FFLAGS) $(LDFLAGS)

clean: 
	rm -f *.o 
