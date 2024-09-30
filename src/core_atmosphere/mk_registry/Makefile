#!/bin/csh

  MODEL = creg.x

 FC = ifort
 CC = 

  lib_path   = 

 include_path = -I.

 WARN = 
 FSTD = -traceback -O3 -fno-alias -mp1 -fp-model source -ftz -simd -align all 
 DBG  = -O0 -g -check bounds -check uninit -fpe0 -fno-alias -ftrapuv -traceback

 f_FLAGS   = -fixed -132 $(FSTD) $(include_path)
 f90_FLAGS = -free $(FSTD) $(include_path)

 F_FLAGS   = $(f_FLAGS)
 F90_FLAGS = $(f90_FLAGS)
 C_FLAGS   = -O2 -DFLDMN -I$(LIB)/mpi/include -I.

 LINKER     = $(FC)
 LINK_FLAGS =

 CPP = $(FC)
 cpp_flags =  

# Libraries
LIBRARIES = 

 INCLUDES =  

OBJS = \
get_env_mod.o \
creg.o

.SUFFIXES: .F90 .f90

$(MODEL): $(OBJS)
	$(LINKER) $(LINK_FLAGS) $(OBJS) $(LIBRARIES) -o $@

.F90.o:
	$(FC) -c $(F90_FLAGS) $(CPP_FLAGS) $(INCLUDES) $<

.f90.o:
	$(FC) -c $(F90_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod
