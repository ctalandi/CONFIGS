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

all: convert_wrap_orca12_batcoord  convert_wrap_orca12_chlorophyll  convert_wrap_orca12_iceini convert_wrap_orca12_gridT

convert_wrap_orca12_batcoord:   convert_wrap_orca12_batcoord.f90
	$(F90) convert_wrap_orca12_batcoord.f90 -o $(BINDIR)/convert_wrap_orca12_batcoord $(FFLAGS) $(LDFLAGS)

convert_wrap_orca12_chlorophyll:   convert_wrap_orca12_chlorophyll.f90
	$(F90) convert_wrap_orca12_chlorophyll.f90 -o $(BINDIR)/convert_wrap_orca12_chlorophyll $(FFLAGS) $(LDFLAGS)

convert_wrap_orca12_iceini:   convert_wrap_orca12_iceini.f90
	$(F90) convert_wrap_orca12_iceini.f90 -o $(BINDIR)/convert_wrap_orca12_iceini $(FFLAGS) $(LDFLAGS)

convert_wrap_orca12_gridT:   convert_wrap_orca12_gridT.f90
	$(F90) convert_wrap_orca12_gridT.f90 -o $(BINDIR)/convert_wrap_orca12_gridT $(FFLAGS) $(LDFLAGS)

clean: 
	rm -f *.o 
