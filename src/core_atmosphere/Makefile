.SUFFIXES: .F .o

PHYSICS=-DDO_PHYSICS
#PHYSICS=

OBJS = mpas_atm_core.o \
       mpas_atm_core_interface.o \
       mpas_atm_dimensions.o \
       mpas_atm_threading.o

all: physcore cmaqcore dycore diagcore atmcore utilities

core_reg:
	$(CPP) $(CPPFLAGS) $(CPPINCLUDES) Registry.xml > Registry_processed.xml

core_input_gen:
	if [ ! -e default_inputs ]; then  mkdir default_inputs; fi
	( cd default_inputs; $(NL_GEN) ../Registry_processed.xml namelist.atmosphere in_defaults=true )
	( cd default_inputs; $(ST_GEN) ../Registry_processed.xml streams.atmosphere stream_list.atmosphere. listed )

gen_includes:
	$(CPP) $(CPPFLAGS) $(CPPINCLUDES) Registry.xml > Registry_processed.xml
	(if [ ! -d inc ]; then mkdir -p inc; fi) # To generate *.inc files
	(cd inc; $(REG_PARSE) < ../Registry_processed.xml )

post_build:
	if [ ! -e $(ROOT_DIR)/default_inputs ]; then mkdir $(ROOT_DIR)/default_inputs; fi
	cp default_inputs/* $(ROOT_DIR)/default_inputs/.
	( cd $(ROOT_DIR)/default_inputs; for FILE in `ls -1`; do if [ ! -e ../$$FILE ]; then cp $$FILE ../.; fi; done )

physcore: mpas_atm_dimensions.o
	( cd physics; $(MAKE) all )
	( mkdir libphys; cd libphys; ar -x ../physics/libphys.a )
	( cd ../..; ln -sf ./src/core_atmosphere/physics/physics_wrf/files/*TBL .)
	( cd ../..; ln -sf ./src/core_atmosphere/physics/physics_wrf/files/*DATA* .)

cmaqcore:
	( cd cmaq; $(MAKE) all )
	( mkdir libcmaq; cd libcmaq; ar -x ../cmaq/libcmaq.a )

dycore: mpas_atm_dimensions.o physcore
	( cd dynamics; $(MAKE) all PHYSICS="$(PHYSICS)" )

diagcore: physcore dycore
	( cd diagnostics; $(MAKE) all )

utilities: physcore
	( cd utils; $(MAKE) all )

atmcore: physcore cmaqcore dycore diagcore $(OBJS)
	ar -ru libdycore.a $(OBJS) libcmaq/*.o dynamics/*.o libphys/*.o diagnostics/*.o

mpas_atm_core_interface.o: mpas_atm_core.o

mpas_atm_core.o: dycore diagcore mpas_atm_threading.o

mpas_atm_dimensions.o:

clean:
	( cd physics; $(MAKE) clean )
	( cd cmaq; $(MAKE) clean )
	( cd dynamics; $(MAKE) clean )
	( cd diagnostics; $(MAKE) clean )
	( cd utils; $(MAKE) clean )
	( cd ../..; rm -f *TBL )
	( cd ../..; rm -f *DATA* )
	$(RM) -r libphys libcmaq
	$(RM) *.o *.mod *.f90 libdycore.a
	$(RM) Registry_processed.xml
	@# Certain systems with intel compilers generate *.i files
	@# This removes them during the clean process
	$(RM) *.i
	$(RM) -r default_inputs

.F.o:
	$(RM) $@ $*.mod
ifeq "$(GEN_F90)" "true"
	$(CPP) $(CPPFLAGS) $(PHYSICS) $(CPPINCLUDES) -I./inc $< > $*.f90
	$(FC) $(FFLAGS) -c $*.f90 $(FCINCLUDES) -I../framework -I../operators -I./physics -I./cmaq -I./dynamics -I./diagnostics -I./physics/physics_wrf -I../external/esmf_time_f90
else
	$(FC) $(CPPFLAGS) $(PHYSICS) $(FFLAGS) -c $*.F $(CPPINCLUDES) $(FCINCLUDES) -I./inc -I../framework -I../operators -I./physics -I./cmaq -I./dynamics -I./diagnostics -I./physics/physics_wrf -I../external/esmf_time_f90
endif
