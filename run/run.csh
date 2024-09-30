#!/bin/csh -f

#SBATCH -J mpas_cmaq
#SBATCH -t 2:00:00
#SBATCH -p ord
#SBATCH -o run_%J.log
#SBATCH -e run_%J.log
#SBATCH -n 288


setenv NPROCS 288
set echo

set input_path        = /work/MOD3DEV/jwilliso/aaqms/2017c2_links
set MPAS_path_output    = /work/MOD3DEV/jwilliso/output/release

# Set Start and End Days for looping
 set START_DATE = "2017-01-01"     #> beginning date (July 1, 2016)
 set END_DATE   = "2017-01-01"     #> ending date    (July 14, 2016)
 set cycle      = 0 
 set firstday   = 20160101

####################################################################
limit stacksize unlimited

setenv ncd_64bit_offset .true.
setenv MPAS_PADDING .true.

set MPAS_root        = $cwd/../
set MPAS_path        = $cwd
set MPAS_cmaq_code_path = $MPAS_root/src/core_atmosphere/cmaq

rm -rf ${MPAS_path_output}
mkdir ${MPAS_path_output}

#cp ${MPAS_path}/*.nml ${MPAS_path_output}

#cp ${MPAS_path}/*.DBL ${MPAS_path_output}
#cp ${MPAS_path}/*.TBL ${MPAS_path_output}
cp ${MPAS_path}/file_input*.txt ${MPAS_path_output}


set RUNLEN     = 24

@ temp = $cycle / 10000
set cycle2d = `printf "%2.2d\n" $temp `
set RUNLEN2D = `printf "%2.2d\n" $RUNLEN `
setenv CTM_RUNLEN "${RUNLEN2D}0000"
setenv CTM_TSTEP   10000

set MPASEXE=${MPAS_root}/atmosphere_model
cd ${MPAS_path_output}

ln -s ${MPAS_path}/stream* ${MPAS_path_output}
ln -s ${input_path}/restart.* .

setenv mpas_cmaq_freq  1
setenv run_cmaq_driver T
setenv mpas_diag       T

set mech_name = cracmm2      

setenv gc_matrix_nml ${MPAS_cmaq_code_path}/GC_$mech_name.nml
setenv ae_matrix_nml ${MPAS_cmaq_code_path}/AE_$mech_name.nml
setenv nr_matrix_nml ${MPAS_cmaq_code_path}/NR_$mech_name.nml
setenv tr_matrix_nml ${MPAS_cmaq_code_path}/Species_Table_TR_0.nml
setenv CSQY_DATA     ${MPAS_cmaq_code_path}/CSQY_DATA_$mech_name
setenv OPTICS_DATA   ${MPAS_cmaq_code_path}/PHOT_OPTICS.dat
setenv LAND_SCHEME   NLCD40

#required input files
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/LANDUSE.TBL        LANDUSE.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/VEGPARM.TBL        VEGPARM.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/GENPARM.TBL        GENPARM.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/OZONE_DAT.TBL      OZONE_DAT.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/OZONE_LAT.TBL      OZONE_LAT.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/OZONE_PLEV.TBL     OZONE_PLEV.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/SOILPARM.TBL       SOILPARM.TBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_LW_DATA      RRTMG_LW_DATA
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_LW_DATA.DBL  RRTMG_LW_DATA.DBL
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_SW_DATA      RRTMG_SW_DATA
ln -s ${MPAS_root}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_SW_DATA.DBL  RRTMG_SW_DATA.DBL
ln -s ${MPAS_path}/map/x4.40962.graph.info.part.${NPROCS} x4.40962.graph.info.part.${NPROCS}

setenv mpas_dmap_file ${MPAS_path_output}/x4.40962.graph.info.part.$NPROCS
set nlines = `wc -l  $mpas_dmap_file `
setenv num_mesh_points $nlines[1]
setenv PRINT_PROC_TIME Y           #> Print timing for all science subprocesses to Logfile
                                   #>   [ default: TRUE or Y ]
setenv STDOUT T                    #> Override I/O-API trying to write information to both the processor
                                   #>   logs and STDOUT [ options: T | F ]

#> Synchronization Time Step and Tolerance Options
setenv CTM_MAXSYNC        300    #> max sync time step (sec) [ default: 720 ]
setenv CTM_MINSYNC         60    #> min sync time step (sec) [ default: 60 ]
setenv SIGMA_SYNC_TOP     0.7    #> top sigma level thru which sync step determined [ default: 0.7 ] 
#setenv ADV_HDIV_LIM     0.95    #> maximum horiz. div. limit for adv step adjust [ default: 0.9 ]
setenv CTM_ADV_CFL       0.95    #> max CFL [ default: 0.75]
#setenv RB_ATOL       1.0E-09    #> global ROS3 solver absolute tolerance [ default: 1.0E-07 ] 

#> Science Options
setenv CTM_OCEAN_CHEM Y      #> Flag for ocean halogen chemistry and sea spray aerosol emissions [ default: Y ]
setenv USE_MARINE_GAS_EMISSION N      #> Flag for ocean halogen chemistry and sea spray aerosol emissions [ default: N ]
setenv CTM_WB_DUST Y         #> use inline windblown dust emissions (only for use with PX) [ default: N ]
setenv CTM_LTNG_NO N         #> turn on lightning NOx [ default: N ]
setenv KZMIN Y               #> use Min Kz option in edyintb [ default: Y ], 
                             #>    otherwise revert to Kz0UT
setenv PX_VERSION Y          #> WRF PX LSM
setenv CLM_VERSION N         #> WRF CLM LSM
setenv NOAH_VERSION N        #> WRF NOAH LSM
setenv CTM_ABFLUX N          #> ammonia bi-directional flux for in-line deposition 
                             #>    velocities [ default: N ]
setenv CTM_BIDI_FERT_NH3 F   #> subtract fertilizer NH3 from emissions because it will be handled
                             #>    by the BiDi calculation [ default: Y ]
setenv CTM_HGBIDI N          #> mercury bi-directional flux for in-line deposition 
                             #>    velocities [ default: N ]
setenv CTM_SFC_HONO Y        #> surface HONO interaction [ default: Y ]
                             #> please see user guide (6.10.4 Nitrous Acid (HONO))
                             #> for dependency on percent urban fraction dataset
setenv CTM_GRAV_SETL Y       #> vdiff aerosol gravitational sedimentation [ default: Y ]

#> MEGAN flags (the first one for MPAS only?)
setenv USE_MEGAN_LAI N       #> Uses MEGAN values for its LAI needs
setenv CTM_BIOGEMIS_BE N     #> calculate in-line biogenic emissions with BEIS [ default: N ]
setenv CTM_BIOGEMIS_MG Y     #> turns on MEGAN biogenic emission [ default: N ]
setenv BDSNP_MEGAN Y         #> turns on BDSNP soil NO emissions [ default: N ]

setenv IC_AERO_M2WET F       #> Specify whether or not initial condition aerosol size distribution
                             #>    is wet or dry [  default: F = dry ]
setenv BC_AERO_M2WET F       #> Specify whether or not boundary condition aerosol size distribution
                             #>    is wet or dry [ default: F = dry ]
setenv IC_AERO_M2USE F       #> Specify whether or not to use aerosol surface area from initial
                             #>    conditions [ default: T = use aerosol surface area  ]
setenv BC_AERO_M2USE F       #> Specify whether or not to use aerosol surface area from boundary
                             #>    conditions [ default: T = use aerosol surface area  ]

#> Surface Tiled Aerosol and Gaseous Exchange Options
#> Only active if DepMod=stage at compile time
setenv CTM_MOSAIC N          #> Output landuse specific deposition velocities [ default: N ]
setenv CTM_STAGE_P22 N       #> Pleim et al. 2022 Aerosol deposition model [default: N]
setenv CTM_STAGE_E20 Y       #> Emerson et al. 2020 Aerosol deposition model [default: Y]
setenv CTM_STAGE_S22 N       #> Shu et al. 2022 (CMAQ v5.3) Aerosol deposition model [default: N]

#> Vertical Extraction Options
setenv VERTEXT N
setenv VERTEXT_COORD_PATH ${MPAS_root}/lonlat.csv

#> I/O Controls
setenv IOAPI_LOG_WRITE F     #> turn on excess WRITE3 logging [ options: T | F ]
setenv FL_ERR_STOP N         #> stop on inconsistent input files
setenv PROMPTFLAG F          #> turn on I/O-API PROMPT*FILE interactive mode [ options: T | F ]
setenv IOAPI_OFFSET_64 YES   #> support large timestep records (>2GB/timestep record) [ options: YES | NO ]
setenv IOAPI_CHECK_HEADERS N #> check file headers [ options: Y | N ]
setenv CTM_EMISCHK N         #> Abort CMAQ if missing surrogates from emissions Input files

#> Diagnostic Output Flags
setenv CTM_CKSUM Y           #> checksum report [ default: Y ]
setenv CLD_DIAG N            #> cloud diagnostic file [ default: N ]

setenv CTM_PHOTDIAG Y        #> photolysis diagnostic file [ default: N ]
setenv NLAYS_PHOTDIAG "1"    #> Number of layers for PHOTDIAG2 and PHOTDIAG3 from
                             #>     Layer 1 to NLAYS_PHOTDIAG  [ default: all layers ]

  #> Control Files
  #>
  #> IMPORTANT NOTE
  #>
  #> The DESID control files defined below are an integral part of controlling the behavior of the model simulation.
  #> Among other things, they control the mapping of species in the emission files to chemical species in the model and
  #> several aspects related to the simulation of organic aerosols.
  #> Please carefully review the DESID control files to ensure that they are configured to be consistent with the assumptions
  #> made when creating the emission files defined below and the desired representation of organic aerosols.
  #> For further information, please see:
  #> + AERO7 Release Notes section on 'Required emission updates':
  #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Release_Notes/aero7_overview.md
  #> + CMAQ User's Guide section 6.9.3 on 'Emission Compatability':
  #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/CMAQ_UG_ch06_model_configuration_options.md#6.9.3_Emission_Compatability
  #> + Emission Control (DESID) Documentation in the CMAQ User's Guide:
  #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Appendix/CMAQ_UG_appendixB_emissions_control.md
  #>
  setenv DESID_CTRL_NML ${MPAS_cmaq_code_path}/CMAQ_Control_DESID_c2.nml
  setenv DESID_CHEM_CTRL_NML ${MPAS_cmaq_code_path}/CMAQ_Control_DESID_cracmm2_mpascmaq.nml

  #> The following namelist configures aggregated output (via the Explicit and Lumped
  #> Air Quality Model Output (ELMO) Module), domain-wide budget output, and chemical
  #> family output.
  setenv MISC_CTRL_NML ${MPAS_cmaq_code_path}/CMAQ_Control_Misc.nml
  set month_list = (JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)

setenv STTIME   $cycle       # beginning GMT time (HHMMSS)
setenv NSTEPS   $CTM_RUNLEN  # time duration (HHMMSS) for this run
setenv TSTEP    $CTM_TSTEP   # output time step interval (HHMMSS)

set TODAYG = ${START_DATE}
set TODAYJ = `date -ud "${START_DATE}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ
set START_DAY = ${TODAYJ}
set STOP_DAY = `date -ud "${END_DATE}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

while ($TODAYJ <= $STOP_DAY )  #>Compare dates in terms of YYYYJJJ

  #> Retrieve Calendar day Information
  set today = `date -ud "${TODAYG}" +%Y%m%d`    #> Convert YYYY-MM-DD to YYYYMMDD
  set YYYYMM = `date -ud "${TODAYG}" +%Y%m`     #> Convert YYYY-MM-DD to YYYYMM
  set YYMMDD = `date -ud "${TODAYG}" +%y%m%d`   #> Convert YYYY-MM-DD to YYMMDD

  set year = `date -ud "${today}" +%Y`
  set month = `date -ud "${TODAYG}" +%m`        #> Convert month

  #> Calculate Yesterday's Date
  set YESTERDAY = `date -ud "${TODAYG}-1days" +%Y%m%d` #> Convert YYYY-MM-DD to YYYYJJJ

  setenv CTM_RJ_1 ${MPAS_path_output}/CCTM_RJ_1_${today}.nc
  setenv CTM_RJ_2 ${MPAS_path_output}/CCTM_RJ_2_${today}.nc
  setenv CTM_PMDIAG_1 ${MPAS_path_output}/CCTM_PMDIAG_${today}.nc
  setenv CTM_APMDIAG_1 ${MPAS_path_output}/CCTM_APMDIAG_${today}.nc
  setenv CTM_DRY_DEP_1 ${MPAS_path_output}/CCTM_DRYDEP_${today}.nc
  setenv CTM_DEPV_DIAG ${MPAS_path_output}/CCTM_DEPV_${today}.nc
  setenv CTM_EMIS ${MPAS_path_output}/CCTM_EMIS${today}.nc
  setenv CTM_EMIS2 ${MPAS_path_output}/CCTM_EMIS2_${today}.nc
  setenv CTM_OUT ${MPAS_path_output}/CCTM_OUT${today}.nc
  setenv MEGAN_SOILOUT ${MPAS_path_output}/CCTM_SOILOUT_${today}.nc

  #> Spatial Masks For Emissions Scaling
  setenv CMAQ_MASKS ${input_path}/ocean_file_120_$month_list[$month].nc

  if (-f ${MPAS_path_output}/CCTM_SOILOUT_${YESTERDAY}.nc) then
     setenv IGNORE_SOILINP N
     setenv SOILINP ${MPAS_path_output}/CCTM_SOILOUT_${YESTERDAY}.nc
     setenv BDSNPINP ${MPAS_path_output}/CCTM_BDSNPOUT_${YESTERDAY}.nc
      setenv mio_file_info ${MPAS_path_output}/file_input_c2_bdsnp.txt
  else
     setenv IGNORE_SOILINP Y
     setenv mio_file_info ${MPAS_path_output}/file_input_c2_bdsnp_no_soilinp.txt
  endif

  setenv BDSNPOUT CCTM_BDSNPOUT_${today}.nc
  setenv BDSNP_DIAG CCTM_BDSNPDIAG_${today}.nc

  setenv BDSNP_NFILE  ${input_path}/megan_input.nc
  setenv BDSNP_AFILE  ${input_path}/megan_input.nc
  setenv BDSNP_NAFILE ${input_path}/megan_input.nc
  setenv BDSNP_FFILE ${input_path}/megan_input.nc
  setenv BDSNP_LFILE ${input_path}/megan_input.nc

  setenv EMIS_DIAG CCTM_EMIS_DIAG_${today}.nc
  setenv CTM_MGEM_1 CCTM_OCEAN_DIAG_${today}.nc
  setenv CTM_SSEMIS CCTM_SSEMIS_DIAG_${today}.nc
  setenv CTM_WBDUST CCTM_WBDUST_DIAG_${today}.nc
  setenv CTM_LTNG CCTM_LTNG_DIAG_${today}.nc

  setenv OCEAN_1 ${input_path}/ocean_file_120_$month_list[$month].nc

  setenv CTM_STDATE $TODAYJ
  setenv CTM_STTIME $cycle

# setup gridded emission files
  set emis_master_list = ( g_air_cds     g_one_to_N_map      Y     AIR_CDS     \
	                    	   g_residential g_four_to_N_map     Y     RESIDENTIAL \
                           china_all     g_week_to_N_map     Y     CHINA       \
                           g_fires_merged daily              Y     PTFIRES     \
                           g_air_crs     g_one_to_N_map      Y     AIR_CRS     \
                           g_air_lto     g_one_to_N_map      Y     AIR_LTO     \
                           g_energy      g_four_to_N_map     Y     ENERGY      \
                           g_industry    g_four_to_N_map     Y     INDUSTRY    \
                           g_ships       g_one_to_N_map      Y     SHIPS       \
                           lightning     lightning_one_to_N_map      Y     LIGHTNING   \
                           rwc           daily               Y     RWC         \
                           layer1        daily               Y     LAYER1      \
                           g_transport   g_week_to_N_map     Y     TRANSPORT     \
                           g_ag          g_one_to_N_map      Y     AG      \
                         )

echo "set master list"
  set n_table_cols = 4
  set temp = `echo $emis_master_list | wc -w`
  set n_emis = `expr $temp / $n_table_cols `

  #> Gridded Emissions files 
  setenv N_EMIS_GR $n_emis
  set nn = 0
  set l1 = 1
  set l2 = 2
  set l3 = 3
  set l4 = 4
  @ emtoday = $today #+ 10000
                     # this was for 2015 using 2016 emissions
  while ($nn < $n_emis)
    @ nn++
    set nnn = `printf "%3.3d\n" $nn `

    if ($emis_master_list[$l1] == 'layer1') then
         
          set EMISfile = emis_mole_all_${emtoday}_US_MPAS120x120_nobeis_norwc_P106_2017_equates_mpas_CRACMMv1.nc
          setenv GR_EMIS_${nnn} ${input_path}/${EMISfile}
    else

       if ($emis_master_list[$l2] == daily) then
          set map_day = $emtoday
       else
          # to find out today's mapping corresponding date bases on a mapping table
          set emtoday_c = "${emtoday},"
          set map_file =  ${MPAS_path}/map/$emis_master_list[$l2]_2017
          set temp = `grep -n $emtoday_c $map_file | sed 's/:/ /' `
          set map_day = $temp[3]
        endif

         set EMISfile  = $emis_master_list[$l1]_${map_day}_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.nc
         setenv GR_EMIS_${nnn} ${input_path}/${EMISfile}

       if ($emis_master_list[$l1] == 'rwc') then
          set EMISfile = emis_mole_rwc_${emtoday}_US_MPAS120x120_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.nc
          setenv GR_EMIS_${nnn} ${input_path}/${EMISfile} 
        endif

       if ($emis_master_list[$l1] == 'china_all') then
          set EMISfile = emis_mole_china_all_${map_day}_mpas_120_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.nc
          setenv GR_EMIS_${nnn} ${input_path}/${EMISfile}
        endif
       if ($emis_master_list[$l1] == 'lightning') then
          set EMISfile = lightning_${map_day}_cmaq_cb6_P106_2017_equates_mpas_CB6.nc
            setenv GR_EMIS_${nnn} ${input_path}/${EMISfile}
       endif
    endif

    setenv GR_EMIS_LAB_${nnn} $emis_master_list[$l1]
    setenv GR_EM_DTOVRD_${nnn} F

    setenv GR_EM_SYM_DATE_${nnn} $emis_master_list[$l3] # To change default behaviour please see Users Guide for EMIS_SYM_DATE

    setenv GR_EMIS_LAB_${nnn} $emis_master_list[$l4]

    @ l1 = $l1 + $n_table_cols
    @ l2 = $l2 + $n_table_cols
    @ l3 = $l3 + $n_table_cols
    @ l4 = $l4 + $n_table_cols

  end

  #> In-line point emissions configuration
#                           type          time map            sync  nickname
  set stack_master_list = ( ptnonipm      us_four_to_N_map    Y     POINT_NONEGU     \
                            cmv_c1c2c3    daily               Y     POINT_CMV        \
                            pt_oilgas     us_four_to_N_map    Y     POINT_OILGAS     \
                            ptfire_merged daily               Y     PTFIRES_STK      \
                            ptegu         daily               Y     POINT_EGU        \
                            airports      airports_ten_to_N_map Y AIRPORTS        \
                          )

  set temp = `echo $stack_master_list | wc -w`
  set n_stkgps = `expr $temp / $n_table_cols `
  setenv N_EMIS_PT $n_stkgps          #> Number of elevated source groups

  if ($N_EMIS_PT > 0) then

     set stack_case      = 36US3_2016fc_cb6camx_16j
     set stack_emis_name = 36US3_cmaq_cb6_2016fc_cb6camx_16j

     set nn = 0
     set l1 = 1
     set l2 = 2
     set l3 = 3
     set l4 = 4

     while ($nn < $n_stkgps)
       @ nn++
       set sector = $stack_master_list[$l1]
       set nnn = `printf "%3.3d\n" $nn `

       set IN_PTpath = $input_path 

       if ($sector == cmv_c1c2c3) then
          setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_${sector}_HEMI_108k_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       
       if ($sector == ptegu) then
          setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_ptegu_12US1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       
       if ($sector == pt_oilgas) then
          setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_pt_oilgas_12US1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif

       if ($sector == ptnonipm) then
          setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_ptnonipm_12US1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       
       if ($sector == airports) then
         setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_airports_12US1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       
       if ($sector == ptfire_merged) then
          setenv STK_GRPS_$nnn $IN_PTpath/stack_groups_${sector}_${emtoday}_12US1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif

       if ($stack_master_list[$l2] == daily) then
          set map_day = $emtoday
       else
          # to find out today's mapping corresponding date bases on a mapping table
          set today_c = "${emtoday},"
          set map_file =  ${MPAS_path}/map/$stack_master_list[$l2]_2017
          set temp = `grep -n $emtoday_c $map_file | sed 's/:/ /' `
          set map_day = $temp[3]
       endif

       if ($sector == cmv_c1c2c3) then
         setenv STK_EMIS_$nnn $IN_PTpath/inln_mole_${sector}_${map_day}_HEMI_108k_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.ncf
       else
         setenv STK_EMIS_$nnn $IN_PTpath/inln_mole_${sector}_${map_day}_12US1_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       if ($sector == ptfire_merged) then
         setenv STK_EMIS_$nnn $IN_PTpath/inln_mole_${sector}_${map_day}_12US1_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif
       if ($sector == airports) then
         setenv STK_EMIS_$nnn $IN_PTpath/inln_mole_${sector}_${map_day}_12US1_cmaq_cracmmv1_P106_2017_equates_mpas_CRACMMv1.ncf
       endif

       setenv STK_EM_SYM_DATE_$nnn $stack_master_list[$l3]

       setenv STK_EMIS_LAB_$nnn $stack_master_list[$l4]

       @ l1 = $l1 + $n_table_cols
       @ l2 = $l2 + $n_table_cols
       @ l3 = $l3 + $n_table_cols
       @ l4 = $l4 + $n_table_cols
     end
   endif
      
  #> Lightning NOx configuration
  if ( $CTM_LTNG_NO == 'Y' ) then
     setenv LTNGNO "InLine"    #> set LTNGNO to "Inline" to activate in-line calculation

  endif

         setenv MEGAN_CTS ${input_path}/megan_input.nc
         setenv MEGAN_EFS ${input_path}/megan_input.nc
         setenv MEGAN_LDF ${input_path}/megan_input.nc
         setenv MEGAN_SOILINP ${MPAS_path_output}/CCTM_SOILOUT_${YESTERDAY}.nc
         setenv MEGAN_BDSNP ${input_path}/megan_input.nc
         setenv MEGAN_OUTPUT CCTM_MEGAN_DIAG_${today}.nc
         setenv BDSNPOUT CCTM_BDSNPOUT_${today}.nc
         setenv MEGAN_SOILOUT ${MPAS_path_output}/CCTM_SOILOUT_${today}.nc

   setenv OMI ${input_path}/omi_cmaq_2017.dat
   rm x1.40962.init.20140101.nc   x1.40962.fdda.2014.nc

   ln -s ${input_path}/x1.40962.fdda.2017.nc x1.40962.fdda.2017.nc
   ln -s ${input_path}/x1.40962.ozone.2017.nc x1.40962.ozone.2017.nc
   ln -s ${input_path}/x1.40962.sfc_update.2017.nc x1.40962.sfc_update.2017.nc
   ln -s ${input_path}/x1.40962.soilndg.2017.nc x1.40962.soilndg.2017.nc
   ln -s ${input_path}/x1.40962.init.20170101.nc x1.40962.init.20170101.nc

   set month = `date -ud "${TODAYG}" +%m`        #> Convert month
 
  if ($today == $firstday) then
     set restart_flag = false
     setenv mpas_restart F
     setenv NEW_START T
  else
     set restart_flag = true
     setenv mpas_restart T
     setenv NEW_START F
  endif

  if ( -f namelist.atmosphere ) rm -f namelist.atmosphere # streams.atmosphere

  cat << End_Of_Namelist  > namelist.atmosphere

&nhyd_model
    config_dt = 450
    config_start_time = '${TODAYG}_${cycle2d}:00:00'
    config_run_duration = '00_${RUNLEN2D}:00:00'
    config_split_dynamics_transport = true
    config_number_of_sub_steps = 2
    config_dynamics_split_steps = 3
    config_h_mom_eddy_visc2 = 0.0
    config_h_mom_eddy_visc4 = 0.0
    config_v_mom_eddy_visc2 = 0.0
    config_h_theta_eddy_visc2 = 0.0
    config_h_theta_eddy_visc4 = 0.0
    config_v_theta_eddy_visc2 = 0.0
    config_horiz_mixing = '2d_smagorinsky'
    config_len_disp = 120000.0
    config_visc4_2dsmag = 0.05
    config_w_adv_order = 3
    config_theta_adv_order = 3
    config_scalar_adv_order = 3
    config_u_vadv_order = 3
    config_w_vadv_order = 3
    config_theta_vadv_order = 3
    config_scalar_vadv_order = 3
    config_scalar_advection = true
    config_positive_definite = false
    config_monotonic = true
    config_coef_3rd_order = 0.25
    config_epssm = 0.1
    config_smdiv = 0.1
    config_h_ScaleWithMesh = true
/

&damping
    config_zd = 22000.0
    config_xnutr = 0.2
/

&io
    config_pio_num_iotasks = 0
    config_pio_stride = 1
/

&decomposition
    config_block_decomp_file_prefix = 'x4.40962.graph.info.part.'
/

&restart
    config_do_restart = $restart_flag
/

&printout
    config_print_global_minmax_vel = true
    config_print_detailed_minmax_vel = true
    config_print_global_minmax_sca = true
/

&IAU
    config_IAU_option = 'off'
    config_IAU_window_length_s = 21600.
/

&physics
    config_physics_suite = 'none'
    config_soilndg_update = true
    config_soilndg_interval = '06:00:00'
    config_px_soilndg         = 1 
    config_px_smoisinit       = 1 
    config_px_modis_veg   = 0
    config_frac_landuse = true
    config_sst_update = true
    config_sstdiurn_update = false
    config_deepsoiltemp_update = false
    config_radtlw_interval = '00:16:00'
    config_radtsw_interval = '00:16:00'
    config_bucket_update = 'none'
    config_microp_scheme = 'mp_wsm6'
    config_convection_scheme = 'cu_kain_fritsch'
    config_kfeta_trigger     = 1
    config_cu_rad_feedback   = true
    config_lsm_scheme = 'px'
    config_pbl_scheme = 'bl_acm'
    config_gwdo_scheme = 'off'
    config_radt_cld_scheme = 'cld_fraction'
    config_radt_lw_scheme = 'rrtmg_lw'
    config_radt_sw_scheme = 'rrtmg_sw'
    config_sfclayer_scheme = 'sf_pxsfclay'
    config_fdda_scheme = 'analysis'
    config_fdda_t = true
    config_fdda_t_in_pbl = false
    config_fdda_t_min_layer = 0
    config_fdda_t_coef = 0.0003
    config_fdda_q = true
    config_fdda_q_in_pbl = false
    config_fdda_q_min_layer = 0
    config_fdda_q_coef = 0.00003
    config_fdda_uv = true
    config_fdda_uv_in_pbl = false
    config_fdda_uv_min_layer = 0
    config_fdda_uv_coef = 0.0003
    num_soil_layers          = 2 
    num_land_cat             = 40
    config_landuse_data = 'nlcd40'
    config_frac_seaice = false
/

&soundings
    config_sounding_interval = 'none'
/

End_Of_Namelist

  date '+Started MPAS atmosphere_model at %m/%d/%y %H:%M:%S'
    mpirun -np $NPROCS $MPASEXE
  date '+Completed MPAS atmosphere_model at %m/%d/%y %H:%M:%S%n'
  
  if (! -d ${today}) mkdir $today
  mv CTM* log.* MIO* $today

  #> Increment both Gregorian and Julian Days
  set TODAYG = `date -ud "${TODAYG}+1days" +%Y-%m-%d` #> Add a day for tomorrow
  set TODAYJ = `date -ud "${TODAYG}" +%Y%j` #> Convert YYYY-MM-DD to YYYYJJJ

end          # end of simulation time loop
